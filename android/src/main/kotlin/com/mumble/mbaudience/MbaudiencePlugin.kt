package com.mumble.mbaudience

import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

import android.location.Location
import com.google.android.gms.location.*

/** MbaudiencePlugin */
class MbaudiencePlugin: FlutterPlugin, MethodCallHandler {
  private lateinit var channel : MethodChannel

  private var locationClient: FusedLocationProviderClient? = null
  private var locationCallback: LocationCallback? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "mbaudience")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "startLocationUpdates" -> startLocationUpdates()
      "stopLocationUpdates" -> stopLocationUpdates()
      else -> result.notImplemented()
    }
  }

  fun startLocationUpdates() {
    if ((locationCallback == null) || (locationClient == null)) {
      locationClient = LocationServices.getFusedLocationProviderClient(context)

      val mLocationRequest = LocationRequest.create()
      mLocationRequest.priority = LocationRequest.PRIORITY_BALANCED_POWER_ACCURACY
      mLocationRequest.setExpirationDuration(4000)

      locationCallback = object : LocationCallback() {
        override fun onLocationResult(locationResult: LocationResult?) {
          if (locationResult != null) {
            var mostAccurate: Location? = null
            for (location in locationResult.locations) {
              if (mostAccurate == null) {
                mostAccurate = location
              } else {
                if (location.accuracy < mostAccurate.accuracy) {
                  mostAccurate = location
                }
              }
            }

            if (mostAccurate != null) {
              val locationMap = HashMap<String, Double>()
              locationMap["latitude"] = mostAccurate.latitude
              locationMap["longitude"] = mostAccurate.longitude
              channel.invokeMethod("locatupdateLocationion", locationMap, null)
            }
          }
        }
      }

      if ((ContextCompat.checkSelfPermission(context, Manifest.permission.ACCESS_COARSE_LOCATION) == PackageManager.PERMISSION_GRANTED) ||
              (ContextCompat.checkSelfPermission(context, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED)) {
        locationClient?.requestLocationUpdates(mLocationRequest, locationCallback, Looper.getMainLooper())
      } else {
        //TODO: request permissions
      }
    }
  }

  fun stopLocationUpdates() {
    locationClient?.removeLocationUpdates(locationCallback)
    locationClient = null
    locationCallback = null
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
