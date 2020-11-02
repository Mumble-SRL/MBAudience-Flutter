import 'package:mbaudience/mbaudience_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Class used to save and retrieve custom id and mobile user id.
/// It used the `shared_preferences` package to save them.
class MBAudienceIdsManager {
  /// The key used to store the customId
  String _customIdKey = 'com.mumble.mburger.audience.customId';
  /// The key used to store the mobileUserId
  String _mobileUserIdKey = 'com.mumble.mburger.audience.mobileUserId';

  //region custom id

  /// Sets and saves a custom id.
  /// @param customId The custom id that will be saved.
  Future<void> setCustomId(String customId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (customId != null) {
      await prefs.setString(_customIdKey, customId);
    } else {
      await prefs.remove(_customIdKey);
    }
    await MBAudienceManager.shared.updateMetadata();
  }

  /// Removes the custom id, if present.
  Future<void> removeCustomId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_customIdKey);
  }

  /// The custom id, if present, otherwise `null`.
  /// @returns A Future that completes with the custom id saved.
  Future<String> getCustomId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String customId = prefs.getString(_customIdKey);
    return customId;
  }
//endregion

//region mobile user id
  /// Sets and saves the mobile user id.
  /// @param mobileUserId The mobile user id that will be saved.
  Future<void> setMobileUserId(int mobileUserId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mobileUserId != null) {
      await prefs.setInt(_mobileUserIdKey, mobileUserId);
    } else {
      await prefs.remove(_mobileUserIdKey);
    }
    await MBAudienceManager.shared.updateMetadata();
  }

  /// Removes the mobile user id, if present.
  Future<void> removeMobileUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_mobileUserIdKey);
  }

  /// The mobile user id, if present, otherwise `null`.
  /// @returns A Future that completes with the mobile user id saved.
  Future<int> getMobileUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int mobileUserId = prefs.getInt(_mobileUserIdKey);
    return mobileUserId;
  }
//endregion
}
