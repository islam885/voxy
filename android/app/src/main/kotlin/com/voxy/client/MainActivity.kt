package com.voxy.client

import android.content.Intent
import android.net.VpnService
import android.os.ParcelFileDescriptor
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.FileInputStream
import java.io.FileOutputStream
import java.net.InetSocketAddress
import java.nio.ByteBuffer
import java.nio.channels.DatagramChannel
import java.nio.channels.SocketChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.voxy.client/vpn"
    private var vpnPendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "prepareVpn" -> {
                    val intent = VpnService.prepare(this)
                    if (intent != null) {
                        vpnPendingResult = result
                        startActivityForResult(intent, 0x0F)
                    } else {
                        result.success(true)
                    }
                }
                "startVpn" -> {
                    val ip = call.argument<String>("ip") ?: ""
                    val port = call.argument<Int>("port") ?: 8080
                    val proto = call.argument<String>("proto") ?: "HTTP"

                    val intent = Intent(this, VoxyVpnService::class.java).apply {
                        action = VoxyVpnService.ACTION_CONNECT
                        putExtra("PROXY_IP", ip)
                        putExtra("PROXY_PORT", port)
                        putExtra("PROXY_PROTO", proto)
                    }
                    startService(intent)
                    result.success(true)
                }
                "stopVpn" -> {
                    val intent = Intent(this, VoxyVpnService::class.java).apply {
                        action = VoxyVpnService.ACTION_DISCONNECT
                    }
                    startService(intent)
                    result.success(true)
                }
                "isRunning" -> {
                    result.success(VoxyVpnService.isRunning)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == 0x0F) {
            if (resultCode == RESULT_OK) {
                vpnPendingResult?.success(true)
            } else {
                vpnPendingResult?.error("DENIED", "VPN Permission was denied by user", null)
            }
            vpnPendingResult = null
        }
    }
}
