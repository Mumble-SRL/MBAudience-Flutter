import 'package:mbaudience/mbaudience_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MBAudienceIdsManager {
  String _customIdKey = 'com.mumble.mburger.audience.customId';
  String _mobileUserIdKey = 'com.mumble.mburger.audience.mobileUserId';

  //region custom id
  Future<void> setCustomId(String customId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (customId != null) {
      await prefs.setString(_customIdKey, customId);
    } else {
      await prefs.remove(_customIdKey);
    }
    await MBAudienceManager.shared.updateMetadata();
  }

  Future<void> removeCustomId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_customIdKey);
  }

  Future<String> getCustomId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String customId = prefs.getString(_customIdKey);
    return customId;
  }
//endregion

//region mobile user id
  Future<void> setMobileUserId(int mobileUserId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mobileUserId != null) {
      await prefs.setInt(_mobileUserIdKey, mobileUserId);
    } else {
      await prefs.remove(_mobileUserIdKey);
    }
    await MBAudienceManager.shared.updateMetadata();
  }

  Future<void> removeMobileUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_mobileUserIdKey);
  }

  Future<int> getMobileUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int mobileUserId = prefs.getInt(_mobileUserIdKey);
    return mobileUserId;
  }
//endregion
}
