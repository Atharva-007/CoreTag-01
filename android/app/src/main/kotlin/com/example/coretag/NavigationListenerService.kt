package com.example.coretag

import android.app.Notification
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log
import io.flutter.plugin.common.EventChannel

class NavigationListenerService : NotificationListenerService() {

    companion object {
        private const val TAG = "NavigationListenerService"
        var eventSink: EventChannel.EventSink? = null
        var instance: NavigationListenerService? = null
    }

    override fun onCreate() {
        super.onCreate()
        instance = this
        Log.d(TAG, "NavigationListenerService created.")
    }

    override fun onDestroy() {
        super.onDestroy()
        instance = null
        Log.d(TAG, "NavigationListenerService destroyed.")
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        super.onNotificationPosted(sbn)
        if (sbn != null) {
            Log.d(TAG, "Notification posted: ${sbn.packageName}, Category: ${sbn.notification.category}, Title: ${sbn.notification.extras.getString(Notification.EXTRA_TITLE)}, Text: ${sbn.notification.extras.getString(Notification.EXTRA_TEXT)}")
            if (isNavigationNotification(sbn)) {
                Log.d(TAG, "Navigation notification identified: ${sbn.packageName}")
                extractAndSendNavigationData(sbn)
            }
        }
    }

    override fun onNotificationRemoved(sbn: StatusBarNotification?) {
        super.onNotificationRemoved(sbn)
        if (sbn != null) {
            Log.d(TAG, "Notification removed: ${sbn.packageName}, Category: ${sbn.notification.category}, Title: ${sbn.notification.extras.getString(Notification.EXTRA_TITLE)}, Text: ${sbn.notification.extras.getString(Notification.EXTRA_TEXT)}")
            if (isNavigationNotification(sbn)) { // Check if it was a navigation notification
                Log.d(TAG, "Navigation notification removed: ${sbn.packageName}")
                // When navigation notification is removed, assume navigation stopped
                sendNavigationStopEvent()
            }
        }
    }

    private fun isNavigationNotification(sbn: StatusBarNotification): Boolean {
        // More permissive heuristic:
        // 1. Check for specific navigation app package names
        val isGoogleMaps = sbn.packageName == "com.google.android.apps.maps"
        val isWaze = sbn.packageName == "com.waze"
        val isMaps = sbn.packageName.contains("maps") // Generic check for other map apps

        // 2. Check notification category
        val isCategoryNavigation = sbn.notification.category == Notification.CATEGORY_NAVIGATION

        // 3. Check for keywords in title or text
        val title = sbn.notification.extras.getString(Notification.EXTRA_TITLE)?.lowercase() // Use lowercase()
        val text = sbn.notification.extras.getString(Notification.EXTRA_TEXT)?.lowercase()   // Use lowercase()

        val hasNavigationKeywords = (title?.contains("turn") == true || title?.contains("exit") == true || title?.contains("route") == true ||
                                     text?.contains("turn") == true || text?.contains("exit") == true || text?.contains("route") == true)

        // Combine all checks
        return (isGoogleMaps || isWaze || isMaps || isCategoryNavigation || hasNavigationKeywords)
    }

    private fun extractAndSendNavigationData(sbn: StatusBarNotification) {
        val extras = sbn.notification.extras
        val title = extras.getString(Notification.EXTRA_TITLE)
        val text = extras.getString(Notification.EXTRA_TEXT)

        // Simple parsing for direction and distance from notification title/text
        var direction = title ?: "Unknown" // Default to title
        var distance = "Unknown"
        var eta = "Unknown" // Assuming ETA might also be in text/title

        // More robust distance extraction using raw string literal for regex
        text?.let {
            val distanceRegex = """(\d+(\.\d+)?)\s*(m|km)""".toRegex() // Using raw string literal
            val match = distanceRegex.find(it)
            if (match != null) {
                distance = match.value
            }
        } ?: title?.let {
            val distanceRegex = """(\d+(\.\d+)?)\s*(m|km)""".toRegex() // Using raw string literal
            val match = distanceRegex.find(it)
            if (match != null) {
                distance = match.value
            }
        }
        
        // Try to get ETA (very basic, might need refinement) using raw string literal for regex
        text?.let {
            val etaRegex = """(\d+)\s*(min|mins|hour|hours)""".toRegex() // Using raw string literal
            val match = etaRegex.find(it)
            if (match != null) {
                eta = match.value
            }
        } ?: title?.let {
            val etaRegex = """(\d+)\s*(min|mins|hour|hours)""".toRegex() // Using raw string literal
            val match = etaRegex.find(it)
            if (match != null) {
                eta = match.value
            }
        }

        val navigationData = mapOf(
            "isNavigating" to true,
            "direction" to direction,
            "distance" to distance,
            "eta" to eta // Include ETA
        )
        Log.d(TAG, "Emitting navigation data: $navigationData")
        eventSink?.success(navigationData)
    }

    private fun sendNavigationStopEvent() {
        val navigationData = mapOf(
            "isNavigating" to false,
            "direction" to "",
            "distance" to "",
            "eta" to ""
        )
        Log.d(TAG, "Emitting navigation stop event: $navigationData")
        eventSink?.success(navigationData)
    }
}
