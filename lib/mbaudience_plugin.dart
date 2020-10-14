import 'dart:async';

import 'package:flutter/services.dart';
import 'package:mbaudience/mbaudience_manager.dart';

class MBAudienceFlutterPlugin {
  static const MethodChannel _channel = const MethodChannel('mbaudience');

  static Future<void> startLocationUpdates() async {
    //TODO: Android start location updates
    await _channel.invokeMethod('startLocationUpdates');
    return;
  }

  static Future<void> stopLocationUpdates() async {
    //TODO: Android stop location updates
    await _channel.invokeMethod('stopLocationUpdates');
    return;
  }

  /// If method call has been initialized or not
  static bool _methodCallInitialized = false;

  /// Initialize the callbacks from the native side to dart
  static Future<void> initializeMethodCall() async {
    if (!_methodCallInitialized) {
      _methodCallInitialized = true;
      _channel.setMethodCallHandler(_mbaudienceHandler);
    }
  }

  static Future<dynamic> _mbaudienceHandler(MethodCall methodCall) async {
    //TODO: Android part update metadata
    if (methodCall.method == 'updateMetadata') {
      MBAudienceManager.shared.updateMetadata();
    } else if (methodCall.method == 'updateLocation' &&
        methodCall.arguments is Map<String, dynamic>) {
      Map<String, dynamic> latLng = methodCall.arguments;
      double latitude = latLng['latitude'];
      double longitude = latLng['longitude'];

      MBAudienceManager.shared.setCurrentLocation(latitude, longitude);
    }
  }
}
