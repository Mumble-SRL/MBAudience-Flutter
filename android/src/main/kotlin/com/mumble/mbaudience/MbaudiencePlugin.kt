package com.mumble.mbaudience

import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.location.Location
import android.os.Looper
import android.util.Log
import androidx.annotation.NonNull
import com.google.android.gms.location.*
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry

/** MbaudiencePlugin */
class MbaudiencePlugin : FlutterPlugin, ActivityAware, PluginRegistry.RequestPermissionsResultListener, MethodCallHandler {

    private val reqPermissionCode = 422

    private lateinit var channel: MethodChannel

    private var locationClient: FusedLocationProviderClient? = null
    private var locationCallback: LocationCallback? = null

    private var applicationContext: Context? = null
    private var activity: Activity? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "mbaudience")
        channel.setMethodCallHandler(this)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        applicationContext = binding.activity.applicationContext
        binding.addRequestPermissionsResultListener(this)
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        applicationContext = binding.activity.applicationContext
        binding.addRequestPermissionsResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
        applicationContext = null
    }

    override fun onDetachedFromActivity() {
        activity = null
        applicationContext = null
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>?, grantResults: IntArray?): Boolean {
        if (requestCode == reqPermissionCode) {
            grantResults?.let {
                if (it.isNotEmpty()) {
                    var allOk = true
                    for (res in it) {
                        if (res == PackageManager.PERMISSION_DENIED) {
                            allOk = false
                        }
                    }

                    if (allOk) {
                        startLocationUpdates()
                    }
                }

                return true
            }
        }

        return false
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "startLocationUpdates" -> startLocationUpdates()
            "stopLocationUpdates" -> stopLocationUpdates()
            else -> result.notImplemented()
        }
    }

    fun startLocationUpdates() {
        if (Utils.checkForLocationPermission(applicationContext!!)) {
            if (((locationCallback == null) || (locationClient == null)) && (applicationContext != null) && (activity != null)) {
                locationClient = LocationServices.getFusedLocationProviderClient(applicationContext!!)

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
                                val locationMap = mutableMapOf<String, Double>()
                                locationMap["latitude"] = mostAccurate.latitude
                                locationMap["longitude"] = mostAccurate.longitude
                                channel.invokeMethod("updateLocation", locationMap, null)
                            }
                        }
                    }
                }

                locationClient?.requestLocationUpdates(mLocationRequest, locationCallback, Looper.getMainLooper())
            }
        } else {
            Utils.askForPermission(activity!!, reqPermissionCode)
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
