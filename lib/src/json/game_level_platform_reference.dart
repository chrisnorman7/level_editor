import 'dart:math';

import 'package:json_annotation/json_annotation.dart';

import 'platform_link.dart';

part 'game_level_platform_reference.g.dart';

/// A platform in a game level.
@JsonSerializable()
class GameLevelPlatformReference {
  /// Create an instance.
  GameLevelPlatformReference({
    required this.id,
    required this.terrainId,
    this.name = 'Untitled Platform',
    this.link,
    this.startX = 0,
    this.startY = 0,
    this.width = 1,
    this.depth = 1,
  });

  /// Create an instance from a JSON object.
  factory GameLevelPlatformReference.fromJson(
    final Map<String, dynamic> json,
  ) =>
      _$GameLevelPlatformReferenceFromJson(json);

  /// The ID of this platform.
  final String id;

  /// The name of this platform.
  String name;

  /// The ID of the terrain this platform uses.
  String terrainId;

  /// Have this platform shadow another platform.
  PlatformLink? link;

  /// The start x coordinate.
  int startX;

  /// The start y coordinate.
  int startY;

  /// The start coordinates.
  Point<int> get start => Point(startX, startY);

  /// The width of this platform.
  int width;

  /// The depth of this platform.
  int depth;

  /// The end x coordinate.
  int get endX => startX + (width - 1);

  /// The end y coordinate.
  int get endY => startY + (depth - 1);

  /// The end coordinates of this platform.
  Point<int> get end => Point(endX, endY);

  /// Convert an instance to JSON.
  Map<String, dynamic> toJson() => _$GameLevelPlatformReferenceToJson(this);
}
