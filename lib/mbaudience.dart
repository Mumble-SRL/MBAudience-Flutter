import 'package:flutter/foundation.dart';

import 'package:mbaudience/mbaudience_manager.dart';
import 'package:mbaudience/mbaudience_plugin.dart';
import 'package:mburger/mb_plugin/mb_plugin.dart';

class MBAudience extends MBPlugin {
  MBAudience() {
    _pluginStartup();
  }

  Future<void> _pluginStartup() async {
    await MBAudienceManager.shared.increaseSession();
    await MBAudienceManager.shared.updateMetadata();
    MBAudienceFlutterPlugin.initializeMethodCall();
  }

//region tags

  Future<void> setTag({
    @required tag,
    @required value,
  }) async {
    return MBAudienceManager.shared.setTag(
      tag: tag,
      value: value,
    );
  }

  Future<void> setTags({@required Map<String, String> tags}) async {
    return MBAudienceManager.shared.setTags(tags: tags);
  }

  Future<void> removeTag(String tag) async {
    return MBAudienceManager.shared.removeTag(tag);
  }

  Future<void> removeTags(List<String> tags) async {
    return MBAudienceManager.shared.removeTags(tags);
  }

//endregion

//region custom id
  Future<void> setCustomId(String customId) {
    return MBAudienceManager.shared.setCustomId(customId);
  }

  Future<void> removeCustomId() {
    return MBAudienceManager.shared.removeCustomId();
  }

  Future<String> getCustomId() {
    return MBAudienceManager.shared.getCustomId();
  }
//endregion

//region mobile user id
  Future<void> setMobileUserId(int mobileUserId) {
    return MBAudienceManager.shared.setMobileUserId(mobileUserId);
  }

  Future<void> removeMobileUserId() {
    return MBAudienceManager.shared.removeMobileUserId();
  }

  Future<int> getMobileUserId() {
    return MBAudienceManager.shared.getMobileUserId();
  }
//endregion

//region location
  Future<void> startLocationUpdates() {
    return MBAudienceFlutterPlugin.startLocationUpdates();
  }

  Future<void> stopLocationUpdates() {
    return MBAudienceFlutterPlugin.stopLocationUpdates();
  }

  Future<void> setCurrentLocation(double latitude, double longitude) {
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
