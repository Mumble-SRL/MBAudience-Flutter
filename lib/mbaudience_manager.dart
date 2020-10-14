import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:mbaudience/managers/mbaudience_ids_manager.dart';
import 'package:mbaudience/managers/mbaudience_session_manager.dart';
import 'package:mbaudience/managers/mbaudience_tags_manager.dart';
import 'package:mburger/mb_manager.dart';
import 'package:package_info/package_info.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:http/http.dart' as http;

class MBAudienceManager extends WidgetsBindingObserver {
  MBAudienceSessionManager _sessionManager = MBAudienceSessionManager();
  MBAudienceTagsManager _tagsManager = MBAudienceTagsManager();
  MBAudienceIdsManager _idsManager = MBAudienceIdsManager();

  MBAudienceManager._privateConstructor() {
    WidgetsBinding.instance.addObserver(this);
  }

  static final MBAudienceManager _shared =
      MBAudienceManager._privateConstructor();

  _MBAudienceLocation _currentLocation;

  /// The singleton that manages all the data sent and received to/from MBurger.
  static MBAudienceManager get shared {
    return _shared;
  }

//region app lifecycle

  Future<void> increaseSession() {
    return _sessionManager.increaseSession();
  }

  Future<int> currentSession() {
    return _sessionManager.currentSession;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      _sessionManager.endSession();
    } else {
      _sessionManager.startSession();
    }
  }
//endregion

//region custom id
  Future<void> setCustomId(String customId) async {
    return _idsManager.setCustomId(customId);
  }

  Future<void> removeCustomId() async {
    return _idsManager.removeCustomId();
  }

  Future<String> getCustomId() async {
    return _idsManager.getCustomId();
  }
//endregion

//region mobile user id
  Future<void> setMobileUserId(int mobileUserId) async {
    return _idsManager.setMobileUserId(mobileUserId);
  }

  Future<void> removeMobileUserId() async {
    return _idsManager.removeMobileUserId();
  }

  Future<int> getMobileUserId() async {
    return _idsManager.getMobileUserId();
  }
//endregion

//region tags
  Future<void> setTag({
    @required tag,
    @required value,
  }) async {
    return _tagsManager.setTag(
      tag: tag,
      value: value,
    );
  }

  Future<void> setTags({@required Map<String, String> tags}) async {
    return _tagsManager.setTags(tags: tags);
  }

  Future<void> removeTag(String tag) async {
    return _tagsManager.removeTag(tag);
  }

  Future<void> removeTags(List<String> tags) async {
    return _tagsManager.removeTags(tags);
  }
//endregion

//region location
  Future<void> setCurrentLocation(double latitude, double longitude) {
    _MBAudienceLocation lastLocation = _currentLocation;
    _MBAudienceLocation newLocation = _MBAudienceLocation(latitude, longitude);
    if (lastLocation == null) {
      _currentLocation = newLocation;
      return _updateLocation();
    } else if (newLocation.distanceFromLocation(lastLocation) > 100) {
      _currentLocation = newLocation;
      return _updateLocation();
    }
    return null;
  }
//endregion

//region api
  Future<void> updateMetadata() async {
    var defaultParameters = await MBManager.shared.defaultParameters();
    var headers = await MBManager.shared.headers(contentTypeJson: true);

    Map<String, dynamic> parameters = Map<String, dynamic>();
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
    parameters['app_version'] = packageInfo.version;

    parameters['sessions'] = await _sessionManager.currentSession;
    parameters['sessions_time'] = await _sessionManager.totalSessionTime;

    int currentSession = await _sessionManager.currentSession;
    if (currentSession != null) {
      DateTime dateTime =
          await _sessionManager.startSessionDateForSession(currentSession);
      if (dateTime != null) {
        parameters['last_session'] = dateTime.millisecondsSinceEpoch ~/ 1000.0;
      } else {
        parameters['last_session'] = 0;
      }
    } else {
      parameters['last_session'] = 0;
    }

    int mobileUserId = await _idsManager.getMobileUserId();
    if (mobileUserId != null) {
      parameters['mobile_user_id'] = mobileUserId;
    }

    String customId = await _idsManager.getCustomId();
    if (customId != null) {
      parameters['custom_id'] = customId;
    }

    if (_currentLocation != null) {
      parameters['latitude'] = _currentLocation.latitude;
      parameters['longitude'] = _currentLocation.longitude;
    }

    List<Map<String, String>> savedTags =
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

  Future<void> _updateLocation() async {
    print("Update location");
    try {
      if (_currentLocation == null) {
        return;
      }
      var defaultParameters = await MBManager.shared.defaultParameters();
      var headers = await MBManager.shared.headers(contentTypeJson: true);

      Map<String, dynamic> parameters = Map<String, dynamic>();

      parameters.addAll(defaultParameters);
      parameters['latitude'] = _currentLocation.latitude;
      parameters['longitude'] = _currentLocation.longitude;

      var uri = Uri.https(MBManager.shared.endpoint, 'api/locations');
      var response = await http.post(
        uri,
        headers: headers,
        body: json.encode(parameters),
      );
      MBManager.checkResponse(response.body, checkBody: false);
    } catch (e) {
      print(e);
    }
  }
//endregion
}

class _MBAudienceLocation {
  final double latitude;
  final double longitude;

  _MBAudienceLocation(this.latitude, this.longitude);

  //Distance in meters
  double distanceFromLocation(_MBAudienceLocation location) {
    double lat1 = location.latitude;
    double lon1 = location.longitude;
    double lat2 = this.latitude;
    double lon2 = this.longitude;
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
