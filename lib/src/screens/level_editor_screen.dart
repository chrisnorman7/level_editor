import 'dart:convert';

import 'package:backstreets_widgets/extensions.dart';
import 'package:backstreets_widgets/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_games/flutter_audio_games.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import 'levels_screen.dart';
import 'terrains_screen.dart';

/// The main screen for the level editor.

class LevelEditorScreen extends ConsumerWidget {
  /// Create an instance.
  const LevelEditorScreen({
    required this.wallSound,
    required this.footstepSounds,
    required this.musicSounds,
    required this.ambianceSounds,
    this.levelsDirectory = 'levels/levels',
    this.terrainsFilename = 'levels/terrains.json',
    this.defaultSoundType,
    this.jsonEncoder = const JsonEncoder.withIndent('  '),
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

  /// The possible music tracks.
  final List<String> musicSounds;

  /// The possible ambiances.
  final List<String> ambianceSounds;

  /// The default type of all sounds in the editor.
  ///
  /// If [defaultSoundType] is `null`, then the type of [wallSound] will be used
  /// instead.
  final SoundType? defaultSoundType;

  /// The JSON encoder to use.
  final JsonEncoder jsonEncoder;

  /// Build the widget.
  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final editor = ref.watch(levelEditorContextNotifierProvider);
    if (editor == null) {
      Future(() {
        ref.read(levelEditorContextNotifierProvider.notifier).setContext(
              wallSound: wallSound,
              footstepSounds: footstepSounds,
              musicSounds: musicSounds,
              ambianceSounds: ambianceSounds,
              levelsDirectory: levelsDirectory,
              terrainsFilename: terrainsFilename,
              defaultSoundType: defaultSoundType ?? wallSound.soundType,
              jsonEncoder: jsonEncoder,
            );
      });
      return const LoadingScreen();
    }
    final levels = ref.watch(gameLevelsProvider);
    final terrains = ref.watch(terrainsProvider);
    return SimpleScaffold(
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
    );
  }
}
