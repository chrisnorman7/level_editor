import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'json/game_level_reference.dart';
import 'json/game_level_terrain_reference.dart';
import 'json/game_level_terrains.dart';

part 'providers.g.dart';

/// Provide the terrains from [filename].
@riverpod
List<GameLevelTerrainReference> terrains(
  final Ref ref,
  final String filename,
) {
  final file = File(filename);
  final parent = file.parent;
  if (!parent.existsSync()) {
    parent.createSync(recursive: true);
  }
  if (!file.existsSync()) {
    return [];
  }
  final source = file.readAsStringSync();
  final map = jsonDecode(source) as Map<String, dynamic>;
  return GameLevelTerrains.fromJson(map).terrains;
}

/// Provide a single terrain with the given [id] from the terrains file at
/// [filename].
@riverpod
GameLevelTerrainReference terrain(
  final Ref ref,
  final String filename,
  final String id,
) {
  final terrains = ref.watch(terrainsProvider(filename));
  return terrains.firstWhere((final terrain) => terrain.id == id);
}

/// Provide all game levels loaded from the directory at [path].
@riverpod
List<GameLevelReference> gameLevels(final Ref ref, final String path) {
  final directory = Directory(path);
  if (!directory.existsSync()) {
    directory.createSync(recursive: true);
  }
  final files = directory.listSync().whereType<File>();
  return files.map((final file) {
    final source = file.readAsStringSync();
    final json = jsonDecode(source) as Map<String, dynamic>;
    return GameLevelReference.fromJson(json);
  }).toList();
}

/// Provide a single game level reference with the given [id].
@riverpod
GameLevelReference gameLevel(
  final Ref ref,
  final String path,
  final String id,
) {
  final levels = ref.watch(gameLevelsProvider(path));
  return levels.firstWhere((final level) => level.id == id);
}
