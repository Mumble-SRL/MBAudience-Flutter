import CoreLocation
import Flutter
import UIKit

public class MbaudiencePlugin: NSObject, FlutterPlugin {
    private static var staticChannel: FlutterMethodChannel?
    private var locationManager: CLLocationManager?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "mbaudience", binaryMessenger: registrar.messenger())
        let instance = MbaudiencePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.addApplicationDelegate(instance)
        staticChannel = channel
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "startLocationUpdates":
            startLocationUpdates()
            result(true)
        case "endLocationUpdates":
            stopLocationUpdates()
            result(true)
        default:
            result(FlutterMethodNotImplemented)
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

    public func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        MbaudiencePlugin.staticChannel?.invokeMethod("updateMetadata", arguments: nil)
    }
}

extension MbaudiencePlugin: CLLocationManagerDelegate {
    public func locationManager(
        _ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]
    ) {
        if let lastLocation = locations.last {
            let arguments: [String: Any] = [
                "latitude": lastLocation.coordinate.latitude,
                "longitude": lastLocation.coordinate.longitude,
            ]
            MbaudiencePlugin.staticChannel?.invokeMethod(
                "updateLocation",
                arguments: arguments)
        }
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    }
}
