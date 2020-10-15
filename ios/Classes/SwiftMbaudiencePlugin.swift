import Flutter
import UIKit
import CoreLocation

public class SwiftMbaudiencePlugin: NSObject, FlutterPlugin {
    private static var staticChannel: FlutterMethodChannel?
    private var locationManager: CLLocationManager?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "mbaudience", binaryMessenger: registrar.messenger())
        let instance = SwiftMbaudiencePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.addApplicationDelegate(instance)
        staticChannel = channel
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "startLocationUpdates" {
            startLocationUpdates()
            result(true)
        } else if call.method == "endLocationUpdates" {
            stopLocationUpdates()
            result(true)
        }
    }

    public func startLocationUpdates() {
        if locationManager == nil {
            locationManager = CLLocationManager()
            locationManager?.requestAlwaysAuthorization()
            locationManager?.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager?.delegate = self
            locationManager?.startMonitoringSignificantLocationChanges()
        } else {
            locationManager?.startMonitoringSignificantLocationChanges()
        }
    }

    func stopLocationUpdates() {
        if let locationManager = locationManager {
            locationManager.stopMonitoringSignificantLocationChanges()
        }
    }

    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        SwiftMbaudiencePlugin.staticChannel?.invokeMethod("updateMetadata", arguments: nil)
    }
}

extension SwiftMbaudiencePlugin: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastLocation = locations.last {
            let arguments: [String: Any] = ["latitude": lastLocation.coordinate.latitude,
                                            "longitude": lastLocation.coordinate.longitude]
            SwiftMbaudiencePlugin.staticChannel?.invokeMethod("updateLocation",
                                                              arguments: arguments)
        }
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    }
}
