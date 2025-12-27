import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/device_state.dart';
import 'package:permission_handler/permission_handler.dart';

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  static const MethodChannel _channel = MethodChannel('com.example.coretag/navigation');
  static const EventChannel _eventChannel = EventChannel('com.example.coretag/navigation_stream');

  final _navigationController = StreamController<NavigationState>.broadcast();
  Stream<NavigationState> get navigationStream => _navigationController.stream;

  NavigationState _currentState = const NavigationState();
  StreamSubscription? _navigationSubscription;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _requestPermissions();
      _startNavigationListener();
      _isInitialized = true;
    } catch (e) {
      debugPrint('Navigation service initialization error: $e');
    }
  }

  Future<void> _requestPermissions() async {
    try {
      await Permission.location.request();
      await Permission.activityRecognition.request();
      
      // Check if notification listener permission is granted
      final bool? hasPermission = await _channel.invokeMethod('checkPermission');
      if (hasPermission == false) {
        // Request notification listener permission
        await _channel.invokeMethod('requestPermission');
      }
    } catch (e) {
      debugPrint('Permission request error: $e');
    }
  }

  void _startNavigationListener() {
    _navigationSubscription = _eventChannel.receiveBroadcastStream().listen(
      (dynamic event) {
        try {
          if (event is Map) {
            final isNavigating = event['isNavigating'] as bool? ?? false;
            final ridingMode = event['ridingMode'] as bool? ?? false;
            
            _currentState = NavigationState(
              ridingMode: ridingMode,
              isNavigating: isNavigating,
              direction: event['direction']?.toString() ?? '',
              distance: event['distance']?.toString() ?? '',
              eta: event['eta']?.toString() ?? '',
              currentStreet: event['currentStreet']?.toString(),
              nextTurn: event['nextTurn']?.toString(),
              currentSpeed: event['currentSpeed'] as double?,
              destination: event['destination']?.toString(),
            );
            
            _navigationController.add(_currentState);
          }
        } catch (e) {
          debugPrint('Navigation event parsing error: $e');
        }
      },
      onError: (error) {
        debugPrint('Navigation stream error: $error');
      },
    );
  }

  NavigationState get currentState => _currentState;

  void dispose() {
    _navigationSubscription?.cancel();
    _navigationController.close();
    _isInitialized = false;
  }
}
