package com.example.coretag

import android.content.ComponentName
import android.content.Intent
import android.os.Bundle
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.coretag/music"
    private val EVENT_CHANNEL = "com.example.coretag/music_stream"
    private val NAV_CHANNEL = "com.example.coretag/navigation"
    private val NAV_EVENT_CHANNEL = "com.example.coretag/navigation_stream"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Method Channel for requesting permissions
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "requestPermission" -> {
                    val intent = Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS)
                    startActivity(intent)
                    result.success(true)
                }
                "checkPermission" -> {
                    val enabled = isNotificationServiceEnabled()
                    result.success(enabled)
                }
                "refreshMusic" -> {
                    // Manually trigger music update
                    NotificationListener.instance?.let {
                        // Force refresh
                        android.os.Handler(android.os.Looper.getMainLooper()).post {
                            try {
                                val method = it.javaClass.getDeclaredMethod("updateMediaControllers")
                                method.isAccessible = true
                                method.invoke(it)
                            } catch (e: Exception) {
                                e.printStackTrace()
                            }
                        }
                    }
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        // Event Channel for music updates
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    NotificationListener.eventSink = events
                    // Trigger immediate update
                    NotificationListener.instance?.let {
                        android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                            try {
                                val method = it.javaClass.getDeclaredMethod("updateMediaControllers")
                                method.isAccessible = true
                                method.invoke(it)
                            } catch (e: Exception) {
                                e.printStackTrace()
                            }
                        }, 500)
                    }
                }

                override fun onCancel(arguments: Any?) {
                    NotificationListener.eventSink = null
                }
            }
        )

        // Navigation Method Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, NAV_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "requestPermission" -> {
                    val intent = Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS)
                    startActivity(intent)
                    result.success(true)
                }
                "checkPermission" -> {
                    val enabled = isNotificationServiceEnabled()
                    result.success(enabled)
                }
                else -> result.notImplemented()
            }
        }

        // Navigation Event Channel
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, NAV_EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    NotificationListener.navigationEventSink = events
                    // Trigger immediate update
                    NotificationListener.instance?.let {
                        android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                            try {
                                val method = it.javaClass.getDeclaredMethod("checkNavigationNotifications")
                                method.isAccessible = true
                                method.invoke(it)
                            } catch (e: Exception) {
                                e.printStackTrace()
                            }
                        }, 500)
                    }
                }

                override fun onCancel(arguments: Any?) {
                    NotificationListener.navigationEventSink = null
                }
            }
        )
    }

    private fun isNotificationServiceEnabled(): Boolean {
        val pkgName = packageName
        val flat = Settings.Secure.getString(contentResolver, "enabled_notification_listeners")
        if (!flat.isNullOrEmpty()) {
            val names = flat.split(":")
            for (name in names) {
                val cn = ComponentName.unflattenFromString(name)
                if (cn != null && cn.packageName == pkgName) {
                    return true
                }
            }
        }
        return false
    }
}
