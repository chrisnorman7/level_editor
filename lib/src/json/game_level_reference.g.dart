// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_level_reference.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameLevelReference _$GameLevelReferenceFromJson(Map<String, dynamic> json) =>
    GameLevelReference(
      id: json['id'] as String,
      filename: json['filename'] as String,
      platforms: (json['platforms'] as List<dynamic>)
          .map((e) =>
              GameLevelPlatformReference.fromJson(e as Map<String, dynamic>))
          .toList(),
      name: json['name'] as String? ?? 'Untitled Level',
    );

Map<String, dynamic> _$GameLevelReferenceToJson(GameLevelReference instance) =>
    <String, dynamic>{
      'id': instance.id,
      'filename': instance.filename,
      'name': instance.name,
      'platforms': instance.platforms,
    };
