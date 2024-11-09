import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

import '../extensions.dart';
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

/// The JSON encoder to use.
const indentedJsonEncoder = JsonEncoder.withIndent('  ');

/// Save [terrains] to disk.
void saveTerrains({
  required final WidgetRef ref,
  required final List<GameLevelTerrainReference> terrains,
}) {
  final source = indentedJsonEncoder.convert(GameLevelTerrains(terrains));
  final filename = ref.context.levelEditor.terrainsFilename;
  ref.context.levelEditor.terrainsFile.writeAsStringSync(source);
  ref.invalidate(TerrainsProvider(filename));
}

/// Save [level].
void saveLevel({
  required final WidgetRef ref,
  required final GameLevelReference level,
}) {
  final source = indentedJsonEncoder.convert(level);
  final editor = ref.context.levelEditor;
  File(path.join(editor.levelsDirectory, level.filename))
      .writeAsStringSync(source);
  ref.invalidate(GameLevelsProvider(editor.levelsDirectory));
}
