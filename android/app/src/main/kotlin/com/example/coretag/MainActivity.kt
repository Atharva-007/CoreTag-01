package com.example.coretag

import android.content.ComponentName
import android.content.Intent
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import android.util.Log // Import Log

class MainActivity : FlutterActivity() {
    private val MUSIC_CHANNEL = "com.example.coretag/music"
    private val MUSIC_EVENT_CHANNEL = "com.example.coretag/music_stream"
    private val NAVIGATION_CHANNEL = "com.example.coretag/navigation" // New MethodChannel for navigation
    private val NAVIGATION_EVENT_CHANNEL = "com.example.coretag/new_navigation_stream"


    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // MUSIC Method Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, MUSIC_CHANNEL).setMethodCallHandler { call, result ->
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
                    NotificationListener.instance?.updateMediaControllers()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        // MUSIC Event Channel
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, MUSIC_EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    NotificationListener.eventSink = events
                    // Trigger immediate update
                    NotificationListener.instance?.updateMediaControllers()
                }

                override fun onCancel(arguments: Any?) {
                    NotificationListener.eventSink = null
                }
            }
        )

        // NAVIGATION Method Channel (New)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, NAVIGATION_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "requestPermission" -> {
                    val intent = Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS)
                    startActivity(intent)
                    result.success(true)
                }
                "checkPermission" -> {
                    val enabled = isNotificationServiceEnabled() // Notification permission covers navigation too
                    result.success(enabled)
                }
                else -> result.notImplemented()
            }
        }

        // NAVIGATION Event Channel
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, NAVIGATION_EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    NavigationListenerService.eventSink = events
                    // Start the service if it's not already running
                    val serviceIntent = Intent(applicationContext, NavigationListenerService::class.java)
                    applicationContext.startService(serviceIntent)
                }

                override fun onCancel(arguments: Any?) {
                    NavigationListenerService.eventSink = null
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
