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
      'ambiance': instance.ambiance,
      'approachDistance': instance.approachDistance,
    };
