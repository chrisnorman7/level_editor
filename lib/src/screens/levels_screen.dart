import 'dart:io';

import 'package:backstreets_widgets/extensions.dart';
import 'package:backstreets_widgets/screens.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;

import '../../extensions.dart';
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
    final editor = context.levelEditor;
    final levelsDirectory = editor.levelsDirectory;
    final levels = ref.watch(GameLevelsProvider(levelsDirectory));
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
          return CommonShortcuts(
            deleteCallback: () {
              context.confirm(
                message:
                    'Are you sure you want to delete the ${level.name} level?',
                title: 'Confirm Delete',
                yesCallback: () {
                  Navigator.pop(context);
                  levels.removeWhere((final l) => l.id == level.id);
                  File(path.join(levelsDirectory, level.filename)).deleteSync(
                    recursive: true,
                  );
                  ref.invalidate(GameLevelsProvider(levelsDirectory));
                },
              );
            },
            child: ListTile(
              autofocus: index == 0,
              title: Text(level.name),
              onTap: () => context.pushWidgetBuilder(
                (final _) => EditLevelScreen(
                  levelId: level.id,
                ),
              ),
            ),
          );
        },
        itemCount: levels.length,
        shrinkWrap: true,
      );
    }
    return CommonShortcuts(
      newCallback: () => newLevel(ref),
      child: Cancel(
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
    );
    saveLevel(ref: ref, level: level);
    ref.context.pushWidgetBuilder(
      (final _) => EditLevelScreen(
        levelId: id,
      ),
    );
  }
}
