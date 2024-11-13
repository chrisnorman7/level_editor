import 'package:json_annotation/json_annotation.dart';

import 'game_level_object_reference.dart';
import 'game_level_platform_reference.dart';
import 'sound_reference.dart';

part 'game_level_reference.g.dart';

/// A serializable game level.
@JsonSerializable()
class GameLevelReference {
  /// Create an instance.
  GameLevelReference({
    required this.id,
    required this.filename,
    required this.platforms,
    required this.objects,
    this.name = 'Untitled Level',
    this.music,
  });

  /// Create an instance from a JSON object.
  factory GameLevelReference.fromJson(final Map<String, dynamic> json) =>
      _$GameLevelReferenceFromJson(json);

  /// The ID of this level.
  final String id;

  /// The filename where this level will be saved.
  String filename;

  /// The name of this level.
  String name;

  /// The platforms on this level.
  final List<GameLevelPlatformReference> platforms;

  /// The objects in this level.
  final List<GameLevelObjectReference> objects;

  /// The music for this level.
  SoundReference? music;

  /// Convert an instance to JSON.
  Map<String, dynamic> toJson() => _$GameLevelReferenceToJson(this);
}
