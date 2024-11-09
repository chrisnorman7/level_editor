/// A level editor which can be added to an existing game.
///
/// To add a level editor, push the [LevelEditorScreen] widget. You must also
/// provide your own [ProviderScope].
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/screens/level_editor_screen.dart';

export 'src/constants.dart';
export 'src/exceptions.dart';
export 'src/json/game_level_platform_reference.dart';
export 'src/json/game_level_reference.dart';
export 'src/json/game_level_terrain_reference.dart';
export 'src/json/game_level_terrains.dart';
export 'src/json/platform_link.dart';
export 'src/screens/edit_level_screen.dart';
export 'src/screens/edit_terrain_screen.dart';
export 'src/screens/level_editor_screen.dart';
export 'src/screens/levels_screen.dart';
export 'src/screens/terrains_screen.dart';
export 'src/widgets/level_editor.dart';
