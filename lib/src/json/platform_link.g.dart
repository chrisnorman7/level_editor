// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_link.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlatformLink _$PlatformLinkFromJson(Map<String, dynamic> json) => PlatformLink(
      platformId: json['platformId'] as String,
      move: json['move'] as bool? ?? false,
      resize: json['resize'] as bool? ?? false,
    );

Map<String, dynamic> _$PlatformLinkToJson(PlatformLink instance) =>
    <String, dynamic>{
      'platformId': instance.platformId,
      'move': instance.move,
      'resize': instance.resize,
    };
