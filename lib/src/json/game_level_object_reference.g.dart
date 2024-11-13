// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_level_object_reference.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameLevelObjectReference _$GameLevelObjectReferenceFromJson(
        Map<String, dynamic> json) =>
    GameLevelObjectReference(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Untitled Object',
      x: (json['x'] as num?)?.toInt() ?? 0,
      y: (json['y'] as num?)?.toInt() ?? 0,
      ambiance: json['ambiance'] == null
          ? null
          : SoundReference.fromJson(json['ambiance'] as Map<String, dynamic>),
      approachDistance: (json['approachDistance'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$GameLevelObjectReferenceToJson(
        GameLevelObjectReference instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'x': instance.x,
      'y': instance.y,
      'ambiance': instance.ambiance,
      'approachDistance': instance.approachDistance,
    };
