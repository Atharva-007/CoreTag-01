import 'dart:async';
import 'package:flutter/services.dart';

class MusicListenerService {
  static const platform = MethodChannel('com.example.coretag/music');
  static const eventChannel = EventChannel('com.example.coretag/music_stream');

  static Stream<Map<String, dynamic>>? _musicStream;

  static Stream<Map<String, dynamic>> get musicStream {
    _musicStream ??= eventChannel.receiveBroadcastStream().map((event) {
      return Map<String, dynamic>.from(event as Map);
    });
    return _musicStream!;
  }

  static Future<bool> requestPermission() async {
    try {
      final result = await platform.invokeMethod('requestPermission');
      return result as bool;
    } catch (e) {
      print('Error requesting permission: $e');
      return false;
    }
  }

  static Future<bool> checkPermission() async {
    try {
      final result = await platform.invokeMethod('checkPermission');
      return result as bool;
    } catch (e) {
      print('Error checking permission: $e');
      return false;
    }
  }

  static Future<void> refreshMusic() async {
    try {
      await platform.invokeMethod('refreshMusic');
    } catch (e) {
      print('Error refreshing music: $e');
    }
  }
}
