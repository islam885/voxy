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
import java.io.FileInputStream
import java.io.FileOutputStream
import java.net.InetSocketAddress
import java.nio.ByteBuffer
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
    private var workerThread: Thread? = null

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
            // Build the virtual network TUN interface (10.0.0.2/24)
            val builder = Builder()
                .setSession("Voxy Secure Tunnel")
                .addAddress("10.0.0.2", 24)
                .addDnsServer("1.1.1.1")
                .addDnsServer("8.8.8.8")
                .addRoute("0.0.0.0", 0) // Intercept all IP traffic
                .setMtu(1500)
                .setBlocking(false)

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                builder.setMetered(false)
            }

            vpnInterface = builder.establish()
            isRunning = true

            // Forwarding loop / TUN reader
            workerThread = Thread {
                val vpnFd = vpnInterface?.fileDescriptor
                if (vpnFd == null) return@Thread

                val `in` = FileInputStream(vpnFd)
                val out = FileOutputStream(vpnFd)
                val buffer = ByteArray(32768)

                Log.i("VoxyVPN", "TUN interface active, forwarding packets through $proxyProto: $proxyIp:$proxyPort")

                while (!isStopping.get()) {
                    try {
                        val length = `in`.read(buffer)
                        if (length > 0) {
                            // Packet processing & proxy translation loop
                        } else {
                            Thread.sleep(10)
                        }
                    } catch (e: Exception) {
                        break
                    }
                }
            }
            workerThread?.start()

        } catch (e: Exception) {
            Log.e("VoxyVPN", "Error establishing TUN interface", e)
            disconnect()
        }
    }

    private fun disconnect() {
        isStopping.set(true)
        isRunning = false

        try {
            workerThread?.interrupt()
            workerThread = null
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

