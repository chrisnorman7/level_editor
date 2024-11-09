// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_level_terrains.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameLevelTerrains _$GameLevelTerrainsFromJson(Map<String, dynamic> json) =>
    GameLevelTerrains(
      (json['terrains'] as List<dynamic>)
          .map((e) =>
              GameLevelTerrainReference.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GameLevelTerrainsToJson(GameLevelTerrains instance) =>
    <String, dynamic>{
      'terrains': instance.terrains,
    };
