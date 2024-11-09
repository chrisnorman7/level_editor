import 'package:json_annotation/json_annotation.dart';

import 'game_level_terrain_reference.dart';

part 'game_level_terrains.g.dart';

/// A list of [terrains].
@JsonSerializable()
class GameLevelTerrains {
  /// Create an instance.
  const GameLevelTerrains(this.terrains);

  /// Create an instance from a JSON object.
  factory GameLevelTerrains.fromJson(final Map<String, dynamic> json) =>
      _$GameLevelTerrainsFromJson(json);

  /// The terrains to use.
  final List<GameLevelTerrainReference> terrains;

  /// Convert an instance to JSON.
  Map<String, dynamic> toJson() => _$GameLevelTerrainsToJson(this);
}
