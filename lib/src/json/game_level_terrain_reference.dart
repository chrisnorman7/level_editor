import 'package:json_annotation/json_annotation.dart';

part 'game_level_terrain_reference.g.dart';

/// A terrain for use with a game level.
@JsonSerializable()
class GameLevelTerrainReference {
  /// Create an instance.
  GameLevelTerrainReference({
    required this.id,
    required this.footstepSounds,
    this.name = 'Untitled Terrain',
    this.footstepSoundsGain = 0.7,
    this.footstepInterval = const Duration(milliseconds: 500),
  });

  /// Create an instance from a JSON object.
  factory GameLevelTerrainReference.fromJson(final Map<String, dynamic> json) =>
      _$GameLevelTerrainReferenceFromJson(json);

  /// The ID of this terrain.
  final String id;

  /// The name of this terrain.
  String name;

  /// The list of footstep sounds for this terrain.
  final String footstepSounds;

  /// The gain of the [footstepSounds].
  double footstepSoundsGain;

  /// How often the player can move on surfaces with this terrain.
  Duration footstepInterval;

  /// Convert an instance to JSON.
  Map<String, dynamic> toJson() => _$GameLevelTerrainReferenceToJson(this);
}
