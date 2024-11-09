import 'dart:io';

import 'package:backstreets_widgets/extensions.dart';
import 'package:backstreets_widgets/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_games/flutter_audio_games.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import 'levels_screen.dart';
import 'terrains_screen.dart';

/// Context for a level editor.
class LevelEditorContext extends InheritedWidget {
  /// Create an instance.
  const LevelEditorContext({
    required this.levelsDirectory,
    required this.terrainsFilename,
    required this.defaultSoundType,
    required this.wallSound,
    required this.footstepSounds,
    required super.child,
    super.key,
  });

  /// Never update listeners.
  @override
  bool updateShouldNotify(covariant final InheritedWidget oldWidget) => false;

  /// The directory where game levels are stored.
  final String levelsDirectory;

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
}

/// The main screen for the level editor.

class LevelEditorScreen extends ConsumerWidget {
  /// Create an instance.
  const LevelEditorScreen({
    required this.wallSound,
    required this.footstepSounds,
    this.levelsDirectory = 'levels/levels',
    this.terrainsFilename = 'levels/terrains.json',
    this.defaultSoundType,
    super.key,
  }) : assert(
          footstepSounds.length > 0,
          'You must provide at least one footstep sound.',
        );

  /// The directory where game levels are stored.
  final String levelsDirectory;

  /// The file where terrains are saved.
  final String terrainsFilename;

  /// The wall sound to use.
  final Sound wallSound;

  /// The lists of footstep sounds to use.
  final Map<String, List<String>> footstepSounds;

  /// The default type of all sounds in the editor.
  ///
  /// If [defaultSoundType] is `null`, then the type of [wallSound] will be used
  /// instead.
  final SoundType? defaultSoundType;

  /// Build the widget.
  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final levels = ref.watch(gameLevelsProvider(levelsDirectory));
    final terrains = ref.watch(terrainsProvider(terrainsFilename));
    return LevelEditorContext(
      levelsDirectory: levelsDirectory,
      terrainsFilename: terrainsFilename,
      defaultSoundType: defaultSoundType ?? wallSound.soundType,
      wallSound: wallSound,
      footstepSounds: footstepSounds,
      child: SimpleScaffold(
        title: 'Level Editor',
        body: Builder(
          builder: (final builderContext) => ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                autofocus: terrains.isNotEmpty,
                title: const Text('Levels'),
                subtitle: Text('${levels.length}'),
                onTap: () {
                  if (terrains.isEmpty) {
                    builderContext.showMessage(
                      message: 'You must create at least 1 terrain first.',
                    );
                  } else {
                    builderContext.pushWidgetBuilder(
                      (final _) => const LevelsScreen(),
                    );
                  }
                },
              ),
              ListTile(
                autofocus: terrains.isEmpty,
                title: const Text('Terrains'),
                subtitle: Text('${terrains.length}'),
                onTap: () => builderContext.pushWidgetBuilder(
                  (final innerContext) => const TerrainsScreen(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
