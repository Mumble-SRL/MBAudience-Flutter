import 'dart:convert';

import 'package:mbaudience/mbaudience_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbaudience/mbaudience_tag.dart';

/// The class that manages tags, it saves, delete and retrieve them.
class MBAudienceTagsManager {
  /// Set the tag with a key and a value, if a tag with that key already exists its value is replaced by the new value.
  /// @param tag The tag.
  /// @param value The value of the tag.
  Future<void> setTag({
    required String tag,
    required String value,
  }) async {
    return setTags(tags: {tag: value});
  }

  /// Set multiple tags with a Map, the keys of the map are the tags, the values the values for the corresponding tag.
  /// Tags are converted to `MBAudienceTag` classes and saved with `_saveNewTags`.
  /// @param tags The map of tags and values.
  Future<void> setTags({required Map<String, String> tags}) async {
    List<MBAudienceTag> newTags = (await _getTags()) ?? [];
    for (String key in tags.keys) {
      String? value = tags[key];
      if (value != null) {
        int index = newTags.indexWhere((t) => t.tag == key);
        if (index != -1) {
          MBAudienceTag tag = newTags[index];
          tag.value = value;
          newTags[index] = tag;
        } else {
          newTags.add(MBAudienceTag(key, value));
        }
      }
    }
    await _saveNewTags(newTags);
    await MBAudienceManager.shared.updateMetadata();
  }

  /// Removes the tag with the provided key and saves the new array of tags.
  /// @param tag The key of the tag that needs to be removed.
  Future<void> removeTag(String tag) async {
    await removeTags([tag]);
  }

  /// Removes a list of tags and saves the new array of tags.
  /// @param tags The keys of the tags that need to be removed.
  Future<void> removeTags(List<String> tags) async {
    List<MBAudienceTag> newTags = (await _getTags()) ?? [];
    for (String tag in tags) {
      int index = newTags.indexWhere((t) => t.tag == tag);
      if (index != -1) {
        newTags.removeAt(index);
      }
    }
    await _saveNewTags(newTags);
    await MBAudienceManager.shared.updateMetadata();
  }

  /// Saves to shared preference an array of `MBAudienceTag`, after converting them to `Map`s
  /// @param tags The array of tags that will be saved.
  Future<void> _saveNewTags(List<MBAudienceTag> tags) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Map<String, String>> tagsDictionaries =
        tags.map((t) => t.toDictionary()).toList();
    String jsonString = json.encode(tagsDictionaries);
    await prefs.setString('com.mumble.mburger.audience.tags', jsonString);
  }

  /// Returns the tags saved.
  /// @return A future that completes with the list of `MBAudienceTag` saved.
  Future<List<MBAudienceTag>?> _getTags() async {
    List<Map<String, String>>? dictionaries = await getTagsAsDictionaries();
    if (dictionaries == null) {
      return null;
    }
    return dictionaries.map((e) => MBAudienceTag.fromDictionary(e)).toList();
  }

  /// Returns the tags saved as dictionaries/maps.
  /// @return A future that completes with the list of tags saved, as dictionaries/maps, ready to be sent to the APIs.
  Future<List<Map<String, String>>?> getTagsAsDictionaries() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tags = prefs.getString('com.mumble.mburger.audience.tags');
    if (tags == null) {
      return null;
    }
    List tagsList = json.decode(tags);
    List<Map<String, String>> tagsToReturn = [];
    for (dynamic tagDynamic in tagsList) {
      if (tagDynamic is Map<String, dynamic>) {
        tagsToReturn.add(
          Map.castFrom<String, dynamic, String, String>(tagDynamic),
        );
      }
    }
    return tagsToReturn;
  }
}
