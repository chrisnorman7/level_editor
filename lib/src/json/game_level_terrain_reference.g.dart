// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_level_terrain_reference.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameLevelTerrainReference _$GameLevelTerrainReferenceFromJson(
        Map<String, dynamic> json) =>
    GameLevelTerrainReference(
      id: json['id'] as String,
      footstepSounds: json['footstepSounds'] as String,
      name: json['name'] as String? ?? 'Untitled Terrain',
      footstepSoundsGain:
          (json['footstepSoundsGain'] as num?)?.toDouble() ?? 0.7,
      footstepInterval: json['footstepInterval'] == null
          ? const Duration(milliseconds: 500)
          : Duration(microseconds: (json['footstepInterval'] as num).toInt()),
    );

Map<String, dynamic> _$GameLevelTerrainReferenceToJson(
        GameLevelTerrainReference instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'footstepSounds': instance.footstepSounds,
      'footstepSoundsGain': instance.footstepSoundsGain,
      'footstepInterval': instance.footstepInterval.inMicroseconds,
    };
