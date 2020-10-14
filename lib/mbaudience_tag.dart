import 'dart:core';

class MBAudienceTag {
  final String tag;
  String value;

  MBAudienceTag(this.tag, this.value);

  factory MBAudienceTag.fromDictionary(Map<String, String> dictionary) {
    String tag = dictionary['tag'] ?? '';
    String value = dictionary['value'] ?? '';
    return MBAudienceTag(tag, value);
  }

  Map<String, String> toDictionary() => {'tag': tag, 'value': value};
}
