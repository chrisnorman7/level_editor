// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_level_platform_reference.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameLevelPlatformReference _$GameLevelPlatformReferenceFromJson(
        Map<String, dynamic> json) =>
    GameLevelPlatformReference(
      id: json['id'] as String,
      terrainId: json['terrainId'] as String,
      name: json['name'] as String? ?? 'Untitled Platform',
      link: json['link'] == null
          ? null
          : PlatformLink.fromJson(json['link'] as Map<String, dynamic>),
      startX: (json['startX'] as num?)?.toInt() ?? 0,
      startY: (json['startY'] as num?)?.toInt() ?? 0,
      width: (json['width'] as num?)?.toInt() ?? 1,
      depth: (json['depth'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$GameLevelPlatformReferenceToJson(
        GameLevelPlatformReference instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'terrainId': instance.terrainId,
      'link': instance.link,
      'startX': instance.startX,
      'startY': instance.startY,
      'width': instance.width,
      'depth': instance.depth,
    };
