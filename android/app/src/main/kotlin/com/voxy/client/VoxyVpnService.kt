package com.voxy.client

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Intent
import android.net.VpnService
import android.os.Build
import android.os.ParcelFileDescriptor
import android.util.Log
import hev.htproxy.TProxyService
import java.io.File
import java.io.FileOutputStream
import java.util.concurrent.atomic.AtomicBoolean

class VoxyVpnService : VpnService() {

    companion object {
        const val ACTION_CONNECT = "com.voxy.client.START"
        const val ACTION_DISCONNECT = "com.voxy.client.STOP"
        const val NOTIFICATION_CHANNEL_ID = "voxy_vpn_channel"
        const val NOTIFICATION_ID = 1001

        var isRunning = false
    }

    private var vpnInterface: ParcelFileDescriptor? = null
    private val isStopping = AtomicBoolean(false)

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val action = intent?.action
        if (action == ACTION_DISCONNECT) {
            disconnect()
            return START_NOT_STICKY
        }

        val proxyIp = intent?.getStringExtra("PROXY_IP") ?: ""
        val proxyPort = intent?.getIntExtra("PROXY_PORT", 8080) ?: 8080
        val proxyProto = intent?.getStringExtra("PROXY_PROTO") ?: "HTTP"

        createNotificationChannel()
        startForeground(NOTIFICATION_ID, buildNotification("Routing via $proxyProto ($proxyIp:$proxyPort)"))

        connect(proxyIp, proxyPort, proxyProto)
        return START_STICKY
    }

    private fun connect(proxyIp: String, proxyPort: Int, proxyProto: String) {
        if (isRunning) return
        isStopping.set(false)

        try {
            // 1. Establish Virtual TUN interface
            val builder = Builder()
                .setSession("Voxy Secure Tunnel")
                .addAddress("10.0.0.2", 24)
                .addDnsServer("1.1.1.1")
                .addDnsServer("8.8.8.8")
                .addRoute("0.0.0.0", 0) // Capture all IPv4 traffic
                .setMtu(1500)
                .setBlocking(false)

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                builder.setMetered(false)
            }

            vpnInterface = builder.establish()
            val tunFd = vpnInterface?.fd ?: -1

            if (tunFd < 0) {
                Log.e("VoxyVPN", "Failed to get valid TUN file descriptor")
                disconnect()
                return
            }

            // 2. Generate hev-socks5-tunnel yaml configuration
            val configFile = File(cacheDir, "tun2socks.yml")
            val configContent = """
tunnel:
  name: tun0
  mtu: 1500
  ipv4: 10.0.0.2

socks5:
  port: $proxyPort
  address: '$proxyIp'
  udp: 'tcp'

misc:
  task-stack-size: 81920
  connect-timeout: 5000
  read-write-timeout: 60000
  log-level: 'warn'
""".trimIndent()

            FileOutputStream(configFile).use { it.write(configContent.toByteArray()) }

            // 3. Start native tun2socks C/Go core
            Thread {
                try {
                    Log.i("VoxyVPN", "Starting native TProxyService engine with fd=$tunFd and config=${configFile.absolutePath}")
                    TProxyService.TProxyStartService(configFile.absolutePath, tunFd)
                } catch (t: Throwable) {
                    Log.e("VoxyVPN", "TProxyService native engine error", t)
                }
            }.start()

            isRunning = true

        } catch (e: Exception) {
            Log.e("VoxyVPN", "Error establishing TUN interface", e)
            disconnect()
        }
    }

    private fun disconnect() {
        isStopping.set(true)
        isRunning = false

        try {
            TProxyService.TProxyStopService()
        } catch (t: Throwable) {
            Log.e("VoxyVPN", "Error stopping native TProxy engine", t)
        }

        try {
            vpnInterface?.close()
            vpnInterface = null
        } catch (e: Exception) {
            Log.e("VoxyVPN", "Error closing VPN interface", e)
        }

        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    override fun onDestroy() {
        disconnect()
        super.onDestroy()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                NOTIFICATION_CHANNEL_ID,
                "Voxy VPN Service",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Shows Voxy VPN tunnel active connection status"
            }
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    private fun buildNotification(statusText: String): Notification {
        val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
        val pendingIntent = PendingIntent.getActivity(
            this, 0, launchIntent,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0
        )

        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, NOTIFICATION_CHANNEL_ID)
        } else {
            Notification.Builder(this)
        }

        return builder
            .setContentTitle("Voxy • Tunnel Active")
            .setContentText(statusText)
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .build()
    }
}
