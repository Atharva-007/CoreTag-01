import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart'; // For SnackBar and Context

/// A service for detecting and streaming currently playing music information
/// using platform channels (e.g., Android NotificationListenerService).
class MusicService {
  /// EventChannel for receiving music playback events from the native side.
  static const musicEventChannel = EventChannel('com.example.coretag/music_stream');
  
  /// MethodChannel for invoking methods on the native side, like permission checks.
  static const musicMethodChannel = MethodChannel('com.example.coretag/music');
  
  StreamSubscription? _musicStreamSubscription;

  /// Callback function to update UI or state management with new music data.
  /// Parameters: track title, artist name, playing status, and album art path.
  final Function(String title, String artist, bool isPlaying, String? albumArt)? onMusicDataUpdated;
  
  /// Callback function to notify about notification permission denials.
  final Function(String message)? onPermissionDenied;

  /// Constructor for MusicService.
  MusicService({this.onMusicDataUpdated, this.onPermissionDenied});

  /// Starts music detection by checking and requesting notification listener permission,
  /// then listening to the music event stream.
  ///
  /// Displays a SnackBar via [onPermissionDenied] if permission is not granted.
  Future<void> startMusicDetection(BuildContext context) async {
    try {
      print('Music Info: Starting music detection...');
      // Check if notification listener permission is granted
      final bool hasPermission = await musicMethodChannel.invokeMethod('checkPermission');
      print('Music Info: Has notification permission: $hasPermission');
      
      if (!hasPermission) {
        // Request permission if not granted
        await musicMethodChannel.invokeMethod('requestPermission');
        onPermissionDenied?.call('Please grant notification access to use the music listener.');
        print('Music Error: Notification permission denied. Requesting...');
        return;
      }
      
      // Listen to music stream for playback events
      _musicStreamSubscription = musicEventChannel.receiveBroadcastStream().listen(
        (dynamic event) {
          if (event is Map) {
            final title = event['title'] ?? 'Unknown Track';
            final artist = event['artist'] ?? 'Unknown Artist';
            final isPlaying = event['isPlaying'] ?? false;
            final albumArt = event['albumArt'] as String?; // Extract albumArt
            print('Music Event: Title=$title, Artist=$artist, Playing=$isPlaying, AlbumArt=$albumArt');
            onMusicDataUpdated?.call(title, artist, isPlaying, albumArt);
          }
        },
        onError: (error) {
          print('Music Stream Error: $error');
          onPermissionDenied?.call('Music stream error: $error'); // Use onPermissionDenied for general errors too
        },
        onDone: () {
          print('Music Stream: Done.');
        },
      );
      print('Music Info: Music stream listener started.');
    } catch (e) {
      print('Music Initialization Error: $e');
      onPermissionDenied?.call('Failed to start music detection: $e'); // Use onPermissionDenied for general errors too
    }
  }

  /// Stops listening to the music detection stream.
  void stopMusicDetection() {
    _musicStreamSubscription?.cancel();
    _musicStreamSubscription = null;
    print('Music Info: Music detection stopped.');
  }

  /// Disposes of the stream subscription to prevent memory leaks.
  void dispose() {
    stopMusicDetection();
    print('Music Info: MusicService disposed.');
  }
}