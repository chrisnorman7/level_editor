import 'dart:io';

import 'package:backstreets_widgets/extensions.dart';
import 'package:backstreets_widgets/screens.dart';
import 'package:backstreets_widgets/shortcuts.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_audio_games/flutter_audio_games.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:path/path.dart' as path;

import '../constants.dart';
import '../json/game_level_reference.dart';
import '../providers.dart';
import 'edit_level_screen.dart';

/// The screen to edit levels.
class LevelsScreen extends ConsumerWidget {
  /// Create an instance.
  const LevelsScreen({
    super.key,
  });

  /// Build the widget.
  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final editor = ref.watch(levelEditorContextProvider);
    final levelsDirectory = editor.levelsDirectoryName;
    final levels = ref.watch(gameLevelsProvider);
    final Widget child;
    if (levels.isEmpty) {
      child = const CenterText(
        text: 'There are no levels to show.',
        autofocus: true,
      );
    } else {
      child = ListView.builder(
        itemBuilder: (final context, final index) {
          final level = levels[index];
          return MaybePlaySoundSemantics(
            sound: level.music?.asSound(
              destroy: false,
              soundType: editor.defaultSoundType,
              loadMode: LoadMode.disk,
              looping: true,
            ),
            child: Builder(
              builder: (final builderContext) => PerformableActionsListTile(
                actions: [
                  PerformableAction(
                    name: 'Rename',
                    activator: CrossPlatformSingleActivator(
                      LogicalKeyboardKey.keyR,
                    ),
                    invoke: () {
                      builderContext
                        ..stopPlaySoundSemantics()
                        ..pushWidgetBuilder(
                          (final getTextBuilder) => GetText(
                            onDone: (final value) {
                              Navigator.pop(getTextBuilder);
                              level.name = value;
                              saveLevel(ref: ref, level: level);
                            },
                            labelText: 'Level name',
                            text: level.name,
                            title: 'Rename Level',
                          ),
                        );
                    },
                  ),
                  PerformableAction(
                    name: 'Delete',
                    activator: deleteShortcut,
                    invoke: () {
                      builderContext.stopPlaySoundSemantics();
                      context.confirm(
                        message:
                            // ignore: lines_longer_than_80_chars
                            'Are you sure you want to delete the ${level.name} level?',
                        title: 'Confirm Delete',
                        yesCallback: () {
                          Navigator.pop(context);
                          levels.removeWhere((final l) => l.id == level.id);
                          File(path.join(levelsDirectory, level.filename))
                              .deleteSync(
                            recursive: true,
                          );
                          ref.invalidate(gameLevelsProvider);
                        },
                      );
                    },
                  ),
                ],
                autofocus: index == 0,
                title: Text(level.name),
                onTap: () => builderContext
                  ..stopPlaySoundSemantics()
                  ..pushWidgetBuilder(
                    (final _) => EditLevelScreen(
                      levelId: level.id,
                    ),
                  ),
              ),
            ),
          );
        },
        itemCount: levels.length,
        shrinkWrap: true,
      );
    }
    return Cancel(
      child: CommonShortcuts(
        newCallback: () => newLevel(ref),
        child: SimpleScaffold(
          title: 'Levels',
          body: child,
          floatingActionButton: NewButton(
            onPressed: () => newLevel(ref),
            tooltip: 'New Level',
          ),
        ),
      ),
    );
  }

  /// Create a new level.
  void newLevel(final WidgetRef ref) {
    final id = newId();
    final level = GameLevelReference(
      id: id,
      filename: '$id.json',
      platforms: [],
      objects: [],
    );
    saveLevel(ref: ref, level: level);
    ref.context.pushWidgetBuilder(
      (final _) => EditLevelScreen(
        levelId: id,
      ),
    );
  }
}
