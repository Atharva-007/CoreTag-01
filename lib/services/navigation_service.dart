import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart'; // For SnackBar and Context

/// A service for detecting and streaming navigation information
/// using platform channels (e.g., Android NotificationListenerService for Google Maps).
class NavigationService {
  /// EventChannel for receiving navigation updates from the native side.
  static const navEventChannel = EventChannel('com.example.coretag/new_navigation_stream');
  
  /// MethodChannel for invoking methods on the native side, like permission checks.
  static const navMethodChannel = MethodChannel('com.example.coretag/navigation');
  
  StreamSubscription? _navigationStreamSubscription;

  /// Callback function to update UI or state management with new navigation data.
  /// Parameters: isNavigating (boolean), current instruction direction,
  /// distance to next instruction, and BuildContext for showing SnackBars.
  final Function(bool isNavigating, String direction, String distance, BuildContext context)? onNavigationDataUpdated;
  
  /// Callback function to notify about notification permission denials.
  final Function(String message)? onPermissionDenied;

  /// Constructor for NavigationService.
  NavigationService({this.onNavigationDataUpdated, this.onPermissionDenied});

  /// Starts navigation detection by checking and requesting notification listener permission,
  /// then listening to the navigation event stream.
  ///
  /// Displays a SnackBar via [onPermissionDenied] if permission is not granted.
  Future<void> startNavigationDetection(BuildContext context) async {
    try {
      print('Navigation Info: Starting navigation detection...');
      // Check if notification listener permission is granted
      final bool hasPermission = await navMethodChannel.invokeMethod('checkPermission');
      print('Navigation Info: Has notification permission: $hasPermission');
      
      if (!hasPermission) {
        // Request permission if not granted
        await navMethodChannel.invokeMethod('requestPermission');
        onPermissionDenied?.call('Please grant notification access to use the navigation listener.');
        print('Navigation Error: Notification permission denied. Requesting...');
        return;
      }
      
      // Listen to navigation stream for updates
      _navigationStreamSubscription = navEventChannel.receiveBroadcastStream().listen(
        (dynamic event) {
          if (event is Map) {
            final isNavigating = event['isNavigating'] ?? false;
            final direction = event['direction'] ?? '';
            final distance = event['distance'] ?? '';
            print('Navigation Event: isNavigating=$isNavigating, Direction=$direction, Distance=$distance');
            onNavigationDataUpdated?.call(isNavigating, direction, distance, context);
          }
        },
        onError: (error) {
          print('Navigation Stream Error: $error');
          onPermissionDenied?.call('Navigation stream error: $error'); // Use onPermissionDenied for general errors too
        },
        onDone: () {
          print('Navigation Stream: Done.');
        },
      );
      print('Navigation Info: Navigation stream listener started.');
    } catch (e) {
      print('Navigation Initialization Error: $e');
      onPermissionDenied?.call('Failed to start navigation detection: $e'); // Use onPermissionDenied for general errors too
    }
  }

  /// Stops listening to the navigation detection stream.
  void stopNavigationDetection() {
    _navigationStreamSubscription?.cancel();
    _navigationStreamSubscription = null;
    print('Navigation Info: Navigation detection stopped.');
  }

  /// Disposes of the stream subscription to prevent memory leaks.
  void dispose() {
    stopNavigationDetection();
    print('Navigation Info: NavigationService disposed.');
  }
}