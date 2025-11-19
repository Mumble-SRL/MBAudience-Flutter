import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:mbaudience/managers/mbaudience_ids_manager.dart';
import 'package:mbaudience/managers/mbaudience_session_manager.dart';
import 'package:mbaudience/managers/mbaudience_tags_manager.dart';
import 'package:mburger/mb_manager.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

/// Main singleton that manages the state of MBAudience and communication with MBurger APIs.
class MBAudienceManager extends WidgetsBindingObserver {
  /// Class that manages start and end od sessions and session number
  final MBAudienceSessionManager _sessionManager = MBAudienceSessionManager();

  /// Class that manages tags, saving and retrival of them
  final MBAudienceTagsManager _tagsManager = MBAudienceTagsManager();

  /// Class that manages custom ids andd MBurger ids.
  final MBAudienceIdsManager _idsManager = MBAudienceIdsManager();

  /// Initializes the singleton, initializing the `WidgetsBinding` callback.
  MBAudienceManager._privateConstructor() {
    WidgetsBinding.instance.addObserver(this);
  }

  /// Private singleton instance.
  static final MBAudienceManager _shared =
      MBAudienceManager._privateConstructor();

  /// Current location, saved to send location updates only if they are distant at least 100m
  _MBAudienceLocation? _currentLocation;

  /// The singleton that manages all the data sent and received to/from MBurger.
  static MBAudienceManager get shared {
    return _shared;
  }

//region app lifecycle

  /// Increases the session using the `MBAudienceSessionManager class.
  Future<void> increaseSession() {
    return _sessionManager.increaseSession();
  }

  /// Used to prevent event burst when paused/resumed were called constantly
  DateTime? _lastResumedDate;

  /// Function called when the app changes the lifecycle state.
  /// @param state The new app state.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      _sessionManager.endSession();
    } else {
      bool shouldStartSession = _lastResumedDate == null;
      if (_lastResumedDate != null) {
        shouldStartSession = DateTime.now().difference(_lastResumedDate!) >
            const Duration(seconds: 30);
      }

      if (shouldStartSession) {
        _lastResumedDate = DateTime.now();
        _sessionManager.startSession().then(
              (_) => updateMetadata(),
            );
      }
    }
  }

//endregion

//region custom id
  /// Set a custom id in the `MBAudienceIdsManager` instance.
  /// @param customId The custom id.
  Future<void> setCustomId(String customId) async {
    return _idsManager.setCustomId(customId);
  }

  /// Removes the custom id in the `MBAudienceIdsManager` instance.
  Future<void> removeCustomId() async {
    return _idsManager.removeCustomId();
  }

  /// The custom id in the `MBAudienceIdsManager` instance.
  /// @returns a Future that completes with the saved custom id.
  Future<String?> getCustomId() async {
    return _idsManager.getCustomId();
  }

//endregion

//region mobile user id
  /// Set the mobile user id in the `MBAudienceIdsManager` instance.
  /// @param mobileUserId The mobile user id.
  Future<void> setMobileUserId(int mobileUserId) async {
    return _idsManager.setMobileUserId(mobileUserId);
  }

  /// Removes the mobile user in the `MBAudienceIdsManager` instance.
  Future<void> removeMobileUserId() async {
    return _idsManager.removeMobileUserId();
  }

  /// The current saved mobile user id in the `MBAudienceIdsManager` instance.
  /// @returns a Future that completes with the current saved mobile user id.
  Future<int?> getMobileUserId() async {
    return _idsManager.getMobileUserId();
  }

//endregion

//region tags
  /// Sets a tag in the `MBAudienceTagsManager` instance.
  /// @param tag The tag.
  /// @param value The value of the tag.
  Future<void> setTag({
    required String tag,
    required String value,
  }) async {
    return _tagsManager.setTag(
      tag: tag,
      value: value,
    );
  }

  /// Sets n tags in the `MBAudienceTagsManager` instance.
  /// @param tags a map of tags and values.
  Future<void> setTags({required Map<String, String> tags}) async {
    return _tagsManager.setTags(tags: tags);
  }

  /// Removes the tag with the specified key in the `MBAudienceTagsManager` instance.
  /// @param tag The tag that needs to be removed.
  Future<void> removeTag(String tag) async {
    return _tagsManager.removeTag(tag);
  }

  /// Removes an array of tags in the `MBAudienceTagsManager` instance.
  /// @param tags An array of tags that will be removed.
  Future<void> removeTags(List<String> tags) async {
    return _tagsManager.removeTags(tags);
  }

//endregion

//region location

  /// Sets the current location and updates MBAudience data if the distance is > 100m from the last location
  /// @param latitude The new latitude.
  /// @param longitude The new longitude.
  Future<void> setCurrentLocation(double latitude, double longitude) async {
    _MBAudienceLocation? lastLocation = _currentLocation;
    _MBAudienceLocation newLocation = _MBAudienceLocation(latitude, longitude);
    if (lastLocation == null) {
      _currentLocation = newLocation;
      return _updateLocation();
    } else if (newLocation.distanceFromLocation(lastLocation) > 100) {
      _currentLocation = newLocation;
      return _updateLocation();
    }
  }

//endregion

//region Session management
  /// The current session retrieved from the `MBAudienceSessionManager class.
  /// @returns The current session number.
  Future<int> currentSession() {
    return _sessionManager.currentSession;
  }

  /// The date of start of a session.
  /// @param session The index of the session.
  /// @return The date when the session with the index has started, if no session is found this function returns `null`.
  Future<DateTime?> startSessionDateForSession(int session) {
    return _sessionManager.startSessionDateForSession(session);
  }

//endregion

//region api
  /// Function to update the data in MBurger.
  Future<void> updateMetadata() async {
    var defaultParameters = await MBManager.shared.defaultParameters();
    var headers = await MBManager.shared.headers(contentTypeJson: true);

    Map<String, dynamic> parameters = <String, dynamic>{};
    parameters.addAll(defaultParameters);
    if (Platform.isIOS) {
      PermissionStatus pushPermission = await Permission.notification.status;
      parameters['push_enabled'] =
          pushPermission == PermissionStatus.granted ? 1 : 0;
    } else {
      parameters['push_enabled'] = 1;
    }

    PermissionStatus locationPermission = await Permission.location.status;
    parameters['location_enabled'] =
        locationPermission == PermissionStatus.granted ? 1 : 0;

    parameters['locale'] = Platform.localeName;

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    if (Platform.isIOS) {
      parameters['app_version'] = packageInfo.version;
    } else {
      parameters['app_version'] = packageInfo.buildNumber;
    }

    parameters['sessions'] = await _sessionManager.currentSession;
    parameters['sessions_time'] = await _sessionManager.totalSessionTime;

    int currentSession = await _sessionManager.currentSession;
    DateTime? dateTime =
        await _sessionManager.startSessionDateForSession(currentSession);
    if (dateTime != null) {
      parameters['last_session'] = dateTime.millisecondsSinceEpoch ~/ 1000.0;
    } else {
      parameters['last_session'] = 0;
    }

    int? mobileUserId = await _idsManager.getMobileUserId();
    if (mobileUserId != null) {
      parameters['mobile_user_id'] = mobileUserId;
    }

    String? customId = await _idsManager.getCustomId();
    if (customId != null) {
      parameters['custom_id'] = customId;
    }

    if (_currentLocation != null) {
      parameters['latitude'] = _currentLocation!.latitude;
      parameters['longitude'] = _currentLocation!.longitude;
    }

    List<Map<String, String>>? savedTags =
        await _tagsManager.getTagsAsDictionaries();
    if (savedTags != null) {
      parameters['tags'] = savedTags;
    }

    if (Platform.isIOS) {
      parameters['platform'] = 'ios';
    } else if (Platform.isAndroid) {
      parameters['platform'] = 'android';
    }

    var uri = Uri.https(MBManager.shared.endpoint, 'api/devices');
    var response = await http.post(
      uri,
      headers: headers,
      body: json.encode(parameters),
    );
    MBManager.checkResponse(response.body, checkBody: false);
  }

  /// Calls the API to updates location data in MBurger.
  /// It used the value stored in `_currentLocation`, if it's null the API isn't called.
  Future<void> _updateLocation() async {
    try {
      if (_currentLocation == null) {
        return;
      }
      var defaultParameters = await MBManager.shared.defaultParameters();
      var headers = await MBManager.shared.headers(contentTypeJson: true);

      Map<String, dynamic> parameters = <String, dynamic>{};

      parameters.addAll(defaultParameters);
      parameters['latitude'] = _currentLocation!.latitude;
      parameters['longitude'] = _currentLocation!.longitude;

      var uri = Uri.https(MBManager.shared.endpoint, 'api/locations');
      var response = await http.post(
        uri,
        headers: headers,
        body: json.encode(parameters),
      );
      MBManager.checkResponse(response.body, checkBody: false);
    } catch (e) {
      debugPrint(e.toString());
    }
  }
//endregion
}

/// An object to represent a location
class _MBAudienceLocation {
  /// The latitude of the location
  final double latitude;

  /// The longitude of the location
  final double longitude;

  /// Initializes a new location with latitude and longitude
  /// @param latitude The latitude of the location
  /// @param longitude The longitude of the location
  _MBAudienceLocation(this.latitude, this.longitude);

  /// Calculates the distance from this location and another instance of `_MBAudienceLocation`.
  /// @param location The other location.
  /// @returns the distance in meters.
  double distanceFromLocation(_MBAudienceLocation location) {
    double lat1 = location.latitude;
    double lon1 = location.longitude;
    double lat2 = latitude;
    double lon2 = longitude;
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    double distance = (12742 * asin(sqrt(a))).abs();
    double distanceInMeters = distance * 1000;
    return distanceInMeters;
  }
}
