import 'dart:ui';

import 'package:json_annotation/json_annotation.dart';

import 'sound_reference.dart';

part 'game_level_object_reference.g.dart';

/// An object in a game level.
@JsonSerializable()
class GameLevelObjectReference {
  /// Create an instance.
  GameLevelObjectReference({
    required this.id,
    this.name = 'Untitled Object',
    this.ambiance,
    this.approachDistance = 1,
    this.onApproach,
    this.onLeave,
  });

  /// Create an instance from a JSON object.
  factory GameLevelObjectReference.fromJson(final Map<String, dynamic> json) =>
      _$GameLevelObjectReferenceFromJson(json);

  /// The ID of this object.
  final String id;

  /// The name of this object.
  String name;

  /// The ambiance of this object.
  SoundReference? ambiance;

  /// The distance when [onApproach] will be called.
  int approachDistance;

  /// The function to call when this object is approached.
  @JsonKey(
    includeFromJson: false,
    includeToJson: false,
  )
  VoidCallback? onApproach;

  /// The function to be called when this object is left alone.
  @JsonKey(
    includeFromJson: false,
    includeToJson: false,
  )
  VoidCallback? onLeave;

  /// Convert an instance to JSON.
  Map<String, dynamic> toJson() => _$GameLevelObjectReferenceToJson(this);
}
