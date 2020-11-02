import 'dart:async';

import 'package:flutter/services.dart';
import 'package:mbaudience/mbaudience_manager.dart';

/// MBAudience flutter plugin class to interact with native APIs
class MBAudienceFlutterPlugin {
  /// The method channel used to interact with native APIs.
  static const MethodChannel _channel = const MethodChannel('mbaudience');

  /// Starts location updates and retuns the result.
  static Future<void> startLocationUpdates() async {
    await _channel.invokeMethod('startLocationUpdates');
    return;
  }

  /// Stop location updates and retuns the result.
  static Future<void> stopLocationUpdates() async {
    await _channel.invokeMethod('stopLocationUpdates');
    return;
  }

  /// If method call has been initialized or not
  static bool _methodCallInitialized = false;

  /// Initialize the callbacks from the native side to dart.
  /// It's used to send location data from the native APIs to dart
  /// and to inform MBAudience that should update metadata, in response to events
  /// (e.g. when the notification permission changes).
  static Future<void> initializeMethodCall() async {
    if (!_methodCallInitialized) {
      _methodCallInitialized = true;
      _channel.setMethodCallHandler(_mbaudienceHandler);
    }
  }

  /// Handles calls from native code to dart, used to:
  /// - update metadta when something happen (e.g. when the notification permission changes).
  /// - inform MBAudience that new location data is available
  static Future<dynamic> _mbaudienceHandler(MethodCall methodCall) async {
    print("method " + methodCall.method);
    if (methodCall.method == 'updateMetadata') {
      MBAudienceManager.shared.updateMetadata();
    } else if (methodCall.method == 'updateLocation' &&
        methodCall.arguments is Map) {
      print("arguments " + methodCall.arguments.toString());
      Map<String, dynamic> latLng = Map.castFrom<dynamic, dynamic, String, dynamic>(methodCall.arguments);
      double latitude = latLng["latitude"];
      double longitude = latLng["longitude"];

      MBAudienceManager.shared.setCurrentLocation(latitude, longitude);
    }
  }
}
