package com.example.coretag

import android.app.Notification
import android.content.ComponentName
import android.content.Intent
import android.graphics.Bitmap
import android.media.MediaMetadata
import android.media.session.MediaController
import android.media.session.MediaSessionManager
import android.media.session.PlaybackState
import android.os.Handler
import android.os.Looper
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Base64
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.FileOutputStream

class NotificationListener : NotificationListenerService() {
    companion object {
        var eventSink: EventChannel.EventSink? = null
        var navigationEventSink: EventChannel.EventSink? = null
        var activeControllers = mutableListOf<MediaController>()
        var instance: NotificationListener? = null
    }

    private lateinit var mediaSessionManager: MediaSessionManager
    private val handler = Handler(Looper.getMainLooper())
    private val sessionCallback = object : MediaSessionManager.OnActiveSessionsChangedListener {
        override fun onActiveSessionsChanged(controllers: MutableList<MediaController>?) {
            updateMediaControllers()
        }
    }
    
    override fun onCreate() {
        super.onCreate()
        instance = this
        try {
            mediaSessionManager = getSystemService(MEDIA_SESSION_SERVICE) as MediaSessionManager
            val componentName = ComponentName(this, NotificationListener::class.java)
            mediaSessionManager.addOnActiveSessionsChangedListener(sessionCallback, componentName)
            updateMediaControllers()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        super.onNotificationPosted(sbn)
        
        // Try to extract music info from notification
        sbn?.notification?.let { notification ->
            extractMusicFromNotification(sbn.packageName, notification)
        }
        
        // Check for navigation notifications
        sbn?.let { checkNavigationNotification(it) }
        
        // Also update media controllers
        handler.postDelayed({ updateMediaControllers() }, 100)
    }

    override fun onNotificationRemoved(sbn: StatusBarNotification?) {
        super.onNotificationRemoved(sbn)
        handler.postDelayed({ updateMediaControllers() }, 100)
    }

    private fun extractMusicFromNotification(packageName: String, notification: Notification) {
        try {
            val extras = notification.extras
            var title: String? = null
            var artist: String? = null
            var albumArtPath: String? = null
            
            // Try to get media info from notification extras
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.LOLLIPOP) {
                title = extras.getCharSequence(Notification.EXTRA_TITLE)?.toString()
                val text = extras.getCharSequence(Notification.EXTRA_TEXT)?.toString()
                val subText = extras.getCharSequence(Notification.EXTRA_SUB_TEXT)?.toString()
                
                // Try to parse artist from text or subtext
                artist = subText ?: text
                
                // Try to get album art from notification
                val largeIcon = notification.getLargeIcon()
                if (largeIcon != null) {
                    try {
                        val bitmap = largeIcon.loadDrawable(this)?.let { drawable ->
                            if (drawable is android.graphics.drawable.BitmapDrawable) {
                                drawable.bitmap
                            } else {
                                null
                            }
                        }
                        if (bitmap != null) {
                            albumArtPath = saveBitmapToFile(bitmap)
                        }
                    } catch (e: Exception) {
                        e.printStackTrace()
                    }
                }
                
                // Check if this is likely a media notification
                val isMusicApp = packageName.contains("music", ignoreCase = true) ||
                        packageName.contains("spotify", ignoreCase = true) ||
                        packageName.contains("youtube", ignoreCase = true) ||
                        packageName.contains("soundcloud", ignoreCase = true) ||
                        packageName.contains("chrome", ignoreCase = true) ||
                        packageName.contains("browser", ignoreCase = true) ||
                        packageName.contains("firefox", ignoreCase = true)
                
                if (isMusicApp && !title.isNullOrEmpty()) {
                    val musicData = mutableMapOf<String, Any>(
                        "title" to (title ?: "Unknown"),
                        "artist" to (artist ?: packageName.split(".").lastOrNull() ?: "Unknown"),
                        "isPlaying" to true
                    )
                    
                    if (albumArtPath != null) {
                        musicData["albumArt"] = albumArtPath
                    }
                    
                    eventSink?.success(musicData)
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun saveBitmapToFile(bitmap: Bitmap): String? {
        try {
            val file = File(cacheDir, "album_art_${System.currentTimeMillis()}.jpg")
            FileOutputStream(file).use { out ->
                bitmap.compress(Bitmap.CompressFormat.JPEG, 85, out)
            }
            return file.absolutePath
        } catch (e: Exception) {
            e.printStackTrace()
            return null
        }
    }

    private fun updateMediaControllers() {
        try {
            val componentName = ComponentName(this, NotificationListener::class.java)
            val controllers = mediaSessionManager.getActiveSessions(componentName)
            activeControllers.clear()
            activeControllers.addAll(controllers)
            
            if (controllers.isNotEmpty()) {
                // Try all controllers to find one with metadata
                for (controller in controllers) {
                    val metadata = controller.metadata
                    val playbackState = controller.playbackState
                    
                    if (metadata != null) {
                        val title = metadata.getString(MediaMetadata.METADATA_KEY_TITLE) 
                            ?: metadata.getString(MediaMetadata.METADATA_KEY_DISPLAY_TITLE)
                        val artist = metadata.getString(MediaMetadata.METADATA_KEY_ARTIST)
                            ?: metadata.getString(MediaMetadata.METADATA_KEY_ALBUM_ARTIST)
                            ?: metadata.getString(MediaMetadata.METADATA_KEY_DISPLAY_SUBTITLE)
                        
                        if (!title.isNullOrEmpty()) {
                            val isPlaying = playbackState?.state == PlaybackState.STATE_PLAYING
                            
                            val musicData = mutableMapOf<String, Any>(
                                "title" to title,
                                "artist" to (artist ?: "Unknown"),
                                "isPlaying" to isPlaying
                            )
                            
                            // Try to get album art
                            val albumArt = metadata.getBitmap(MediaMetadata.METADATA_KEY_ALBUM_ART)
                                ?: metadata.getBitmap(MediaMetadata.METADATA_KEY_ART)
                            
                            if (albumArt != null) {
                                val albumArtPath = saveBitmapToFile(albumArt)
                                if (albumArtPath != null) {
                                    musicData["albumArt"] = albumArtPath
                                }
                            }
                            
                            eventSink?.success(musicData)
                            return // Found music, exit
                        }
                    }
                }
            }
            
            // No music found, send default
            eventSink?.success(mapOf(
                "title" to "No Music Playing",
                "artist" to "Unknown",
                "isPlaying" to false
            ))
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    override fun onListenerConnected() {
        super.onListenerConnected()
        updateMediaControllers()
    }

    override fun onDestroy() {
        super.onDestroy()
        try {
            mediaSessionManager.removeOnActiveSessionsChangedListener(sessionCallback)
            // Clean up old album art files
            cacheDir.listFiles()?.filter { it.name.startsWith("album_art_") }?.forEach { it.delete() }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        instance = null
    }

    private fun checkNavigationNotification(sbn: StatusBarNotification) {
        try {
            val packageName = sbn.packageName
            
            // Check if this is from Google Maps or other navigation apps
            val isNavigationApp = packageName == "com.google.android.apps.maps" ||
                    packageName == "com.waze" ||
                    packageName.contains("navigation", ignoreCase = true) ||
                    packageName.contains("maps", ignoreCase = true)
            
            if (!isNavigationApp) return
            
            val notification = sbn.notification
            val extras = notification.extras
            
            // Extract navigation data from notification
            val title = extras.getCharSequence(Notification.EXTRA_TITLE)?.toString()
            val text = extras.getCharSequence(Notification.EXTRA_TEXT)?.toString()
            val subText = extras.getCharSequence(Notification.EXTRA_SUB_TEXT)?.toString()
            val infoText = extras.getCharSequence(Notification.EXTRA_INFO_TEXT)?.toString()
            
            // Parse navigation information
            var direction: String? = null
            var distance: String? = null
            var eta: String? = null
            var currentStreet: String? = null
            var nextTurn: String? = null
            var destination: String? = null
            
            // Try to extract direction from title (e.g., "Turn right in 350m")
            title?.let {
                when {
                    it.contains("turn right", ignoreCase = true) -> direction = "Turn Right"
                    it.contains("turn left", ignoreCase = true) -> direction = "Turn Left"
                    it.contains("continue", ignoreCase = true) -> direction = "Continue"
                    it.contains("straight", ignoreCase = true) -> direction = "Go Straight"
                    it.contains("roundabout", ignoreCase = true) -> direction = "Roundabout"
                    it.contains("exit", ignoreCase = true) -> direction = "Take Exit"
                    it.contains("merge", ignoreCase = true) -> direction = "Merge"
                    it.contains("u-turn", ignoreCase = true) -> direction = "U-Turn"
                }
                
                // Extract distance (e.g., "350m", "1.2km", "500 ft")
                val distanceRegex = Regex("(\\d+\\.?\\d*)\\s?(m|km|ft|mi)")
                distanceRegex.find(it)?.let { match ->
                    distance = match.value
                }
            }
            
            // ETA might be in subText or infoText
            (subText ?: infoText)?.let {
                // Extract ETA (e.g., "12 min", "1h 30min")
                val etaRegex = Regex("(\\d+)\\s?(min|hour|hr|h)")
                etaRegex.find(it)?.let { match ->
                    eta = match.value
                }
            }
            
            // Text might contain street name or next turn
            text?.let {
                nextTurn = it
            }
            
            // If we found navigation data, send it
            if (direction != null || distance != null || eta != null) {
                val navData = mutableMapOf<String, Any>(
                    "isNavigating" to true,
                    "ridingMode" to true,
                    "direction" to (direction ?: "Continue"),
                    "distance" to (distance ?: "Calculating..."),
                    "eta" to (eta ?: "Calculating...")
                )
                
                if (nextTurn != null) navData["nextTurn"] = nextTurn!!
                if (currentStreet != null) navData["currentStreet"] = currentStreet!!
                if (destination != null) navData["destination"] = destination!!
                
                navigationEventSink?.success(navData)
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    fun checkNavigationNotifications() {
        try {
            val activeNotifications = activeNotifications ?: return
            
            // Check all active notifications for navigation info
            for (sbn in activeNotifications) {
                val packageName = sbn.packageName
                if (packageName == "com.google.android.apps.maps" ||
                    packageName.contains("navigation", ignoreCase = true) ||
                    packageName.contains("maps", ignoreCase = true)) {
                    checkNavigationNotification(sbn)
                    return // Found navigation, exit
                }
            }
            
            // No navigation found
            navigationEventSink?.success(mapOf(
                "isNavigating" to false,
                "ridingMode" to false,
                "direction" to "",
                "distance" to "",
                "eta" to ""
            ))
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}
