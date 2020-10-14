import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:mbaudience/mbaudience_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbaudience/mbaudience_tag.dart';

class MBAudienceTagsManager {
  Future<void> setTag({
    @required tag,
    @required value,
  }) async {
    return setTags(tags: {tag: value});
  }

  Future<void> setTags({@required Map<String, String> tags}) async {
    List<MBAudienceTag> newTags = (await _getTags()) ?? [];
    for (String key in tags.keys) {
      String value = tags[key];
      int index = newTags.indexWhere((t) => t.tag == key);
      if (index != null && index != -1) {
        MBAudienceTag tag = newTags[index];
        tag.value = tags[key];
        newTags[index] = tag;
      } else {
        newTags.add(MBAudienceTag(key, value));
      }
    }
    await _saveNewTags(newTags);
    await MBAudienceManager.shared.updateMetadata();
  }

  Future<void> removeTag(String tag) async {
    await removeTags([tag]);
  }

  Future<void> removeTags(List<String> tags) async {
    List<MBAudienceTag> newTags = (await _getTags()) ?? [];
    for (String tag in tags) {
      int index = newTags.indexWhere((t) => t.tag == tag);
      if (index != null && index != -1) {
        newTags.removeAt(index);
      }
    }
    await _saveNewTags(newTags);
    await MBAudienceManager.shared.updateMetadata();
  }

  Future<void> _saveNewTags(List<MBAudienceTag> tags) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Map<String, String>> tagsDictionaries =
        tags.map((t) => t.toDictionary()).toList();
    String jsonString = json.encode(tagsDictionaries);
    await prefs.setString('com.mumble.mburger.audience.tags', jsonString);
  }

  Future<List<MBAudienceTag>> _getTags() async {
    List<Map<String, String>> dictionaries = await getTagsAsDictionaries();
    if (dictionaries == null) {
      return null;
    }
    return dictionaries.map((e) => MBAudienceTag.fromDictionary(e)).toList();
  }

  Future<List<Map<String, String>>> getTagsAsDictionaries() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String tags = prefs.getString('com.mumble.mburger.audience.tags');
    if (tags == null) {
      return null;
    }
    List tagsList = json.decode(tags);
    List<Map<String, String>> tagsToReturn = [];
    for (dynamic tagDynamic in tagsList) {
      if (tagDynamic is Map) {
        tagsToReturn
            .add(Map.castFrom<String, dynamic, String, String>(tagDynamic));
      }
    }
    return tagsToReturn;
  }
}
