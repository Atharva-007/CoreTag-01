package com.example.coretag

import android.app.Notification
import android.content.ComponentName
import android.content.Context
import android.graphics.Bitmap
import android.media.MediaMetadata
import android.media.session.MediaController
import android.media.session.MediaSessionManager
import android.media.session.PlaybackState
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log
import io.flutter.plugin.common.EventChannel
import java.io.File
import java.io.FileOutputStream
import java.io.IOException
import java.lang.ref.WeakReference

class NotificationListener : NotificationListenerService() {

    companion object {
        private const val TAG = "NotificationListener"
        var eventSink: EventChannel.EventSink? = null
        var instance: NotificationListener? = null
    }

    private var mediaSessionManager: MediaSessionManager? = null
    private var activeMediaControllers = mutableListOf<MediaController>()

    override fun onCreate() {
        super.onCreate()
        instance = this
        mediaSessionManager = getSystemService(Context.MEDIA_SESSION_SERVICE) as MediaSessionManager
        Log.d(TAG, "NotificationListener created.")
    }

    override fun onDestroy() {
        super.onDestroy()
        instance = null
        Log.d(TAG, "NotificationListener destroyed.")
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        super.onNotificationPosted(sbn)
        if (sbn != null && isMediaNotification(sbn)) {
            Log.d(TAG, "Media notification posted: ${sbn.packageName}")
            updateMediaControllers()
        }
    }

    override fun onNotificationRemoved(sbn: StatusBarNotification?) {
        super.onNotificationRemoved(sbn)
        if (sbn != null && isMediaNotification(sbn)) {
            Log.d(TAG, "Media notification removed: ${sbn.packageName}")
            updateMediaControllers()
        }
    }

    private fun isMediaNotification(sbn: StatusBarNotification): Boolean {
        return sbn.notification.category == Notification.CATEGORY_TRANSPORT ||
               sbn.notification.extras.containsKey(Notification.EXTRA_MEDIA_SESSION)
    }

    // This method will be called to update music info
    fun updateMediaControllers() {
        Log.d(TAG, "Updating media controllers...")
        activeMediaControllers.clear()
        mediaSessionManager?.getActiveSessions(ComponentName(this, this.javaClass))?.forEach { controller ->
            activeMediaControllers.add(controller)
        }

        if (activeMediaControllers.isNotEmpty()) {
            val latestController = activeMediaControllers.first() // Get the most recent one
            val metadata = latestController.metadata
            val playbackState = latestController.playbackState

            val title = metadata?.getString(MediaMetadata.METADATA_KEY_TITLE)
            val artist = metadata?.getString(MediaMetadata.METADATA_KEY_ARTIST)
            val isPlaying = playbackState?.state == PlaybackState.STATE_PLAYING

            var albumArtPath: String? = null
            metadata?.getBitmap(MediaMetadata.METADATA_KEY_ALBUM_ART)?.let { bitmap ->
                albumArtPath = saveBitmapToFile(bitmap)
            } ?: metadata?.getString(MediaMetadata.METADATA_KEY_ALBUM_ART_URI)?.let { uri ->
                albumArtPath = uri // Use URI directly if available
            }

            val musicData = mapOf(
                "title" to (title ?: "Unknown Track"),
                "artist" to (artist ?: "Unknown Artist"),
                "isPlaying" to isPlaying,
                "albumArt" to albumArtPath
            )
            Log.d(TAG, "Emitting music data: $musicData")
            eventSink?.success(musicData)
        } else {
            // No active media sessions, emit default state
            val musicData = mapOf(
                "title" to "No Music",
                "artist" to "Unknown",
                "isPlaying" to false,
                "albumArt" to null
            )
            Log.d(TAG, "No active media controllers. Emitting default data: $musicData")
            eventSink?.success(musicData)
        }
    }

    private fun saveBitmapToFile(bitmap: Bitmap): String? {
        val cachePath = File(externalCacheDir, "album_art")
        cachePath.mkdirs()
        val file = File(cachePath, "album_art_${System.currentTimeMillis()}.png")
        return try {
            FileOutputStream(file).use { out ->
                bitmap.compress(Bitmap.CompressFormat.PNG, 100, out)
            }
            file.absolutePath
        } catch (e: IOException) {
            Log.e(TAG, "Error saving bitmap to file: ${e.message}")
            null
        }
    }
}
