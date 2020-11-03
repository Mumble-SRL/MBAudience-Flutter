import 'package:flutter/foundation.dart';

import 'package:mbaudience/mbaudience_manager.dart';
import 'package:mbaudience/mbaudience_plugin.dart';
import 'package:mburger/mb_plugin/mb_plugin.dart';
import 'package:mburger/mb_plugin/mb_plugins_manager.dart';

/// This is the plugin class for MBurger that implements the audience functionality,
/// you can use this to target content to specific users or groups of users, based on their in app behavior.
/// Audience data are updated at every startup, and when the app enters foreground, using the `WidgetsBindingObserver` protocol
/// when application state becomes `AppLifecycleState.resumed`
class MBAudience extends MBPlugin {
  /// Defaults initializer, starts the plugin and method calls to native inteface
  MBAudience() {
    _pluginStartup();
  }

  /// Asyncronous plugin startup function.
  Future<void> _pluginStartup() async {
    await MBAudienceFlutterPlugin.initializeMethodCall();
  }

//region plugin

  /// The order of startup for this plugin, in MBurger
  int order = 1;

  /// The function run at startup by MBurger, initializes the plugin and do the startup work.
  /// It increments the session number and updates the metadata.
  Future<void> startupBlock() async {
    await MBAudienceManager.shared.increaseSession();
    await MBAudienceManager.shared.updateMetadata();
  }

//endregion

//region tags

  /// Set the tag with a key and a value, if a tag with that key already exists its value is replaced by the new value.
  /// After setting the new tag the new audience data are sent to the server.
  /// @param tag The tag.
  /// @param value The value of the tag.
  static Future<void> setTag({
    @required tag,
    @required value,
  }) async {
    MBPluginsManager.tagChanged(tag, value: value);
    return MBAudienceManager.shared.setTag(
      tag: tag,
      value: value,
    );
  }

  /// Set multiple tags with a Map, the keys of the map are the tags, the values the values for the corresponding tag.
  /// After setting the new tags the new audience data are sent to the server.
  /// @param tags The map of tags and values.
  static Future<void> setTags({@required Map<String, String> tags}) async {
    return MBAudienceManager.shared.setTags(tags: tags);
  }

  /// Removes the tag with the specified key and syncs audience data with the server.
  /// @param tag The key of the tag that needs to be removed.
  static Future<void> removeTag(String tag) async {
    return MBAudienceManager.shared.removeTag(tag);
  }

  /// Removes the tags with the specified keys and syncs audience data with the server.
  /// @param tags The keys of the tags that need to be removed.
  static Future<void> removeTags(List<String> tags) async {
    return MBAudienceManager.shared.removeTags(tags);
  }

//endregion

//region custom id
  /// Set a custom id that will be sent with the audience data, this can be used if  you want to target users coming from different platforms from `MBurger`.
  /// After setting this id the new audience data are sent to the server.
  /// @param customId The custom id, this value is saved and will be sent until `removeCustomId` is called.
  static Future<void> setCustomId(String customId) {
    return MBAudienceManager.shared.setCustomId(customId);
  }

  /// Removes the custom id saved and sync audience data to the server.
  static Future<void> removeCustomId() {
    return MBAudienceManager.shared.removeCustomId();
  }

  /// Retrieves the current saved custom id.
  /// @returns a Future that completes with the current saved custom id.
  static Future<String> getCustomId() {
    return MBAudienceManager.shared.getCustomId();
  }
//endregion

//region mobile user id
  /// Set the mobile user id of the user currently logged in MBurger.
  /// After setting this id the new audience data are sent to the server.
  ///
  /// NOTE: The mobile user id is not sent automatically when a user log in/log out with MBAuth. It will be implemented in the future but at the moment you have to set and remove it manually.
  /// @param mobileUserId The mobile user id, this value is saved and will be sent until `removeMobileUserId` is called.
  static Future<void> setMobileUserId(int mobileUserId) {
    return MBAudienceManager.shared.setMobileUserId(mobileUserId);
  }

  /// Removes the mobile user id saved and sync audience data to the server.
  static Future<void> removeMobileUserId() {
    return MBAudienceManager.shared.removeMobileUserId();
  }

  /// Retrieves the current saved mobile user id.
  /// @returns a Future that completes with the current saved mobile user id.
  static Future<int> getMobileUserId() {
    return MBAudienceManager.shared.getMobileUserId();
  }
//endregion

//region location
  /// Start collecting location data and to send it to the server.
  /// iOS: MBAudience uses `startMonitoringSignificantLocationChanges` of CoreLocation
  /// with an accuracy of `kCLLocationAccuracyHundredMeters`.
  /// To stop collecting location data call `stopLocationUpdates`.
  /// Android: MBAudience let you track and target user based on their location,
  /// the framework uses a foreground `FusedLocationProviderClient` with priority `PRIORITY_BALANCED_POWER_ACCURACY`
  /// which is killed the moment the app goes in background.
  /// If you wish to track user position while app is in background you need to implement your own location service,
  /// then when you have a new location you can use this API to send it to the framework: `setCurrentLocation(latitude, longitude)`
  static Future<void> startLocationUpdates() {
    return MBAudienceFlutterPlugin.startLocationUpdates();
  }

  /// Stop collecting location data.
  static Future<void> stopLocationUpdates() {
    return MBAudienceFlutterPlugin.stopLocationUpdates();
  }

  //TODO: Customize the min distance value (now constant at 100m)
  /// Updates current user location with the parameters passed and calls the api to update the device data.
  /// Note: a new location is sent to MBurger only if it's distant at least 100m from the last location seen.
  /// @param latitude Current latitude.
  /// @param longitude Current longitude.
  static Future<void> setCurrentLocation(double latitude, double longitude) {
    MBPluginsManager.locationDataUpdated(latitude, longitude);
    return MBAudienceManager.shared.setCurrentLocation(latitude, longitude);
  }
//endregion

//region sessions

  /// Returns the current session tracked by `MBAudience`
  static Future<int> get currentSession async {
    return MBAudienceManager.shared.currentSession();
  }

  /// The date of the last session
  static Future<DateTime> startSessionDateForSession(int session) async {
    return startSessionDateForSession(session);
  }
//endregion
}
