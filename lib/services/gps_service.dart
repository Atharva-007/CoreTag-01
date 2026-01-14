import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:flutter/material.dart'; // For SnackBar and Context

/// A service for managing GPS tracking, including permission handling,
/// position updates, and calculation of speed and distance.
class GpsService {
  StreamSubscription<Position>? _positionStreamSubscription;
  Position? _lastPosition;
  double _currentSpeed = 0.0;
  double _totalDistance = 0.0;
  String _nextTurn = 'Continue straight';
  double _nextTurnDistance = 0.5; // km
  double _remainingDistance = 5.2; // km

  /// Callback function to update UI or state management with new GPS data.
  /// Parameters: speed (km/h), totalDistance (meters), nextTurn instruction,
  /// remainingDistance (km), and current direction.
  final Function(double speed, double totalDistance, String nextTurn, double remainingDistance, String direction)? onGpsDataUpdated;

  /// Callback function to notify about GPS permission denials.
  final Function(String message)? onPermissionDenied;

  /// Constructor for GpsService.
  GpsService({this.onGpsDataUpdated, this.onPermissionDenied});

  /// Starts GPS tracking after checking and requesting necessary permissions.
  ///
  /// Displays a SnackBar via [onPermissionDenied] if location services are
  /// disabled or permissions are denied.
  Future<void> startGPSTracking(BuildContext context) async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      // Check if location services are enabled
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        onPermissionDenied?.call('Please enable location services');
        print('GPS Error: Location services are disabled.');
        return;
      }

      // Check and request location permissions
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        print('GPS Info: Requesting location permissions...');
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          onPermissionDenied?.call('Location permission denied');
          print('GPS Error: Location permission denied by user.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        onPermissionDenied?.call('Location permission permanently denied. Enable in settings.');
        print('GPS Error: Location permission permanently denied.');
        return;
      }

      // Configure location settings for position updates
      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // Update every 5 meters
      );

      // Start listening to position updates
      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen((Position position) {
        _updateGPSData(position);
      }, onError: (error) {
        print('GPS Stream Error: $error');
        onPermissionDenied?.call('GPS stream error: $error');
      });
      print('GPS Info: GPS tracking started successfully.');
    } catch (e) {
      print('GPS Initialization Error: $e');
      onPermissionDenied?.call('Failed to start GPS tracking: $e');
    }
  }

  /// Stops GPS tracking and resets related data.
  void stopGPSTracking() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    _lastPosition = null;
    _totalDistance = 0.0;
    print('GPS Info: GPS tracking stopped.');
  }

  /// Updates GPS data based on the new [position].
  ///
  /// Calculates speed, accumulated distance, and simulates next turn and
  /// remaining distance updates. Calls [onGpsDataUpdated] with the new data.
  void _updateGPSData(Position position) {
    double speed = position.speed * 3.6; // Convert m/s to km/h
    
    // Calculate distance if a previous position exists
    if (_lastPosition != null) {
      double distanceInMeters = Geolocator.distanceBetween(
        _lastPosition!.latitude,
        _lastPosition!.longitude,
        position.latitude,
        position.longitude,
      );
      _totalDistance += distanceInMeters;
      
      // Simulate decreasing remaining distance
      if (_remainingDistance > 0) {
        _remainingDistance -= (distanceInMeters / 1000);
        if (_remainingDistance < 0) _remainingDistance = 0;
      }
      
      // Simulate next turn instruction and distance
      if (_nextTurnDistance > 0) {
        _nextTurnDistance -= (distanceInMeters / 1000);
        if (_nextTurnDistance < 0.05) {
          _nextTurnDistance = 0.8 + (DateTime.now().millisecond % 5) * 0.2;
           final turns = ['Turn right', 'Turn left', 'Continue straight', 'Take exit', 'Keep right'];
          _nextTurn = turns[DateTime.now().second % turns.length];
        }
      }
    }

    _lastPosition = position;
    _currentSpeed = speed;

    // Determine cardinal direction from heading
    String direction = _getDirectionFromHeading(position.heading);

    onGpsDataUpdated?.call(_currentSpeed, _totalDistance, _nextTurn, _remainingDistance, direction);
    // print('GPS Data: Speed=$_currentSpeed km/h, TotalDistance=$formattedDistance, Direction=$direction, NextTurn=$_nextTurn');
  }

  /// Converts a [heading] (in degrees) to a cardinal direction string.
  String _getDirectionFromHeading(double heading) {
    if (heading < 0) return 'Unknown'; // Heading not available

    if (heading >= 337.5 || heading < 22.5) return 'North';
    if (heading >= 22.5 && heading < 67.5) return 'Northeast';
    if (heading >= 67.5 && heading < 112.5) return 'East';
    if (heading >= 112.5 && heading < 157.5) return 'Southeast';
    if (heading >= 157.5 && heading < 202.5) return 'South';
    if (heading >= 202.5 && heading < 247.5) return 'Southwest';
    if (heading >= 247.5 && heading < 292.5) return 'West';
    if (heading >= 292.5 && heading < 337.5) return 'Northwest';
    
    return 'Unknown';
  }

  /// Disposes of the stream subscription to prevent memory leaks.
  void dispose() {
    _positionStreamSubscription?.cancel();
    print('GPS Info: GpsService disposed.');
  }
}