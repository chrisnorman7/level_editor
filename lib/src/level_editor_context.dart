import 'dart:convert';
import 'dart:io';

import 'package:flutter_audio_games/flutter_audio_games.dart';

/// Context for a level editor.
class LevelEditorContext {
  /// Create an instance.
  const LevelEditorContext({
    required this.levelsDirectoryName,
    required this.terrainsFilename,
    required this.defaultSoundType,
    required this.wallSound,
    required this.footstepSounds,
    required this.jsonEncoder,
  });

  /// The name of the directory where game levels are stored.
  final String levelsDirectoryName;

  /// The directory where game levels are stored.
  Directory get levelsDirectory => Directory(levelsDirectoryName);

  /// The name of the file where terrains are saved.
  final String terrainsFilename;

  /// The file where terrains are stored.
  File get terrainsFile => File(terrainsFilename);

  /// The wall sound to use.
  final Sound wallSound;

  /// The lists of footstep sounds to use.
  final Map<String, List<String>> footstepSounds;

  /// The default type of all sounds in the editor.
  final SoundType defaultSoundType;

  /// The JSON encoder to use.
  final JsonEncoder jsonEncoder;
}
