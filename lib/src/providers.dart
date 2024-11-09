import 'dart:convert';
import 'dart:io';

import 'package:flutter_audio_games/flutter_audio_games.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:recase/recase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'constants.dart';
import 'json/game_level_reference.dart';
import 'json/game_level_terrain_reference.dart';
import 'json/game_level_terrains.dart';
import 'level_editor_context.dart';

part 'providers.g.dart';

/// Provide the terrains that have been created.
@riverpod
List<GameLevelTerrainReference> terrains(final Ref ref) {
  final context = ref.watch(levelEditorContextProvider);
  final file = File(context.terrainsFilename);
  final parent = file.parent;
  if (!parent.existsSync()) {
    parent.createSync(recursive: true);
  }
  if (!file.existsSync()) {
    final footstepSounds = ref.read(footstepSoundsProvider);
    return footstepSounds.keys
        .map(
          (final footstepSound) => GameLevelTerrainReference(
            id: newId(),
            footstepSounds: footstepSound,
            name: footstepSound.titleCase,
          ),
        )
        .toList();
  }
  final source = file.readAsStringSync();
  final map = jsonDecode(source) as Map<String, dynamic>;
  return GameLevelTerrains.fromJson(map).terrains
    ..sort(
      (final a, final b) =>
          a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
}

/// Provide the terrain with the given [id].
@riverpod
GameLevelTerrainReference terrain(
  final Ref ref,
  final String id,
) {
  final terrains = ref.watch(terrainsProvider);
  return terrains.firstWhere((final terrain) => terrain.id == id);
}

/// Provide all the created game levels.
@riverpod
List<GameLevelReference> gameLevels(final Ref ref) {
  final context = ref.watch(levelEditorContextProvider);
  final directory = context.levelsDirectory;
  if (!directory.existsSync()) {
    directory.createSync(recursive: true);
  }
  final files = directory.listSync().whereType<File>();
  return files.map((final file) {
    final source = file.readAsStringSync();
    final json = jsonDecode(source) as Map<String, dynamic>;
    return GameLevelReference.fromJson(json);
  }).toList()
    ..sort(
      (final a, final b) =>
          a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
}

/// Provide a single game level reference with the given [id].
@riverpod
GameLevelReference gameLevel(
  final Ref ref,
  final String id,
) {
  final levels = ref.watch(gameLevelsProvider);
  return levels.firstWhere((final level) => level.id == id);
}

/// Provide a level editor context.
@riverpod
class LevelEditorContextNotifier extends _$LevelEditorContextNotifier {
  /// Build the value.
  @override
  LevelEditorContext? build() => null;

  /// Set [state].
  void setContext({
    required final Sound wallSound,
    required final Map<String, List<String>> footstepSounds,
    required final String levelsDirectory,
    required final String terrainsFilename,
    required final SoundType defaultSoundType,
    required final JsonEncoder jsonEncoder,
  }) =>
      state = LevelEditorContext(
        levelsDirectoryName: levelsDirectory,
        terrainsFilename: terrainsFilename,
        defaultSoundType: defaultSoundType,
        wallSound: wallSound,
        footstepSounds: footstepSounds,
        jsonEncoder: jsonEncoder,
      );
}

/// Ensure [levelEditorContextNotifierProvider] is not `null`.
@riverpod
LevelEditorContext levelEditorContext(final Ref ref) {
  final value = ref.watch(levelEditorContextNotifierProvider);
  if (value == null) {
    throw StateError('No level editor context found.');
  }
  return value;
}

/// Provide all the footstep sounds.
@riverpod
Map<String, List<String>> footstepSounds(final Ref ref) {
  final context = ref.watch(levelEditorContextProvider);
  return context.footstepSounds;
}

/// Provide a list of footstep sounds from the given [key].
@riverpod
List<Sound> footsteps(
  final Ref ref, {
  required final String key,
  required final bool destroy,
  final LoadMode loadMode = LoadMode.memory,
  final bool looping = false,
  final Duration loopingStart = Duration.zero,
  final bool paused = false,
  final SoundPosition position = unpanned,
  final double volume = 0.7,
}) {
  final editor = ref.watch(levelEditorContextProvider);
  final sounds = ref.watch(footstepSoundsProvider);
  final filenames = sounds[key];
  if (filenames == null) {
    throw StateError('No such foot step sound: $key.');
  }
  return filenames
      .map(
        (final filename) => filename.asSound(
          destroy: destroy,
          soundType: editor.defaultSoundType,
          loadMode: loadMode,
          looping: looping,
          loopingStart: loopingStart,
          paused: paused,
          position: position,
          volume: volume,
        ),
      )
      .toList();
}
