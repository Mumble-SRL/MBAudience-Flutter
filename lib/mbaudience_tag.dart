import 'dart:core';

/// A tag of `MBAudience`
class MBAudienceTag {
  /// The identifier of the tag
  final String tag;

  /// The value of the tag
  String value;

  /// Initializes a new tag with a tag and a value
  /// @param tag The identifier of the tag
  /// @paramt value The value of the tag
  MBAudienceTag(this.tag, this.value);

  /// Initializes a tag frm a dictionary saved
  /// @param dictionary the dictionary saved
  factory MBAudienceTag.fromDictionary(Map<String, String> dictionary) {
    String tag = dictionary['tag'] ?? '';
    String value = dictionary['value'] ?? '';
    return MBAudienceTag(tag, value);
  }

  /// Converts the tag to a dictionary
  /// @returns The dictionary representation of the tag
  Map<String, String> toDictionary() => {'tag': tag, 'value': value};
}
