import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

import 'json/game_level_reference.dart';
import 'json/game_level_terrain_reference.dart';
import 'json/game_level_terrains.dart';
import 'providers.dart';

/// The minimum volume to use.
const minVolume = 0.0;

/// The maximum volume to use.
const maxVolume = 4.0;

/// The UUID generator to use.
const uuid = Uuid();

/// Get a new id from [uuid].
String newId() => uuid.v4();

/// Save [terrains] to disk.
void saveTerrains({
  required final WidgetRef ref,
  required final List<GameLevelTerrainReference> terrains,
}) {
  final context = ref.read(levelEditorContextProvider);
  final source = context.jsonEncoder.convert(GameLevelTerrains(terrains));
  context.terrainsFile.writeAsStringSync(source);
  ref.invalidate(terrainsProvider);
}

/// Save [level].
void saveLevel({
  required final WidgetRef ref,
  required final GameLevelReference level,
}) {
  final context = ref.read(levelEditorContextProvider);
  final source = context.jsonEncoder.convert(level);
  File(path.join(context.levelsDirectoryName, level.filename))
      .writeAsStringSync(source);
  ref.invalidate(gameLevelsProvider);
}
