import 'dart:async';
import 'dart:collection';

import 'package:flutter/services.dart';
import 'package:mbaudience/mbaudience_manager.dart';

class MBAudienceFlutterPlugin {
  static const MethodChannel _channel = const MethodChannel('mbaudience');

  static Future<void> startLocationUpdates() async {
    await _channel.invokeMethod('startLocationUpdates');
    return;
  }

  static Future<void> stopLocationUpdates() async {
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
