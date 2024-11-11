import 'dart:io';

import 'package:backstreets_widgets/screens.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;

import '../constants.dart';
import '../providers.dart';
import '../widgets/level_editor.dart';
import '../widgets/sound_reference_list_tile.dart';

/// A screen to edit a level with the given [levelId].
class EditLevelScreen extends ConsumerWidget {
  /// Create an instance.
  const EditLevelScreen({
    required this.levelId,
    super.key,
  });

  /// The ID of the level to edit.
  final String levelId;

  /// Build the widget.
  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final editor = ref.watch(levelEditorContextProvider);
    final levelsDirectory = editor.levelsDirectoryName;
    final level = ref.watch(gameLevelProvider(levelId));
    return TabbedScaffold(
      tabs: [
        TabbedScaffoldTab(
          title: 'Settings',
          icon: const Icon(Icons.settings),
          builder: (final _) => Cancel(
            child: ListView(
              shrinkWrap: true,
              children: [
                TextListTile(
                  value: level.name,
                  onChanged: (final name) {
                    level.name = name;
                    saveLevel(
                      ref: ref,
                      level: level,
                    );
                  },
                  header: 'Name',
                  autofocus: true,
                  labelText: 'Level name',
                  title: 'Rename Level',
                ),
                SoundReferenceListTile(
                  soundReference: level.music,
                  possiblePaths: editor.musicSounds,
                  onChanged: (final value) {
                    level.music = value;
                    saveLevel(ref: ref, level: level);
                  },
                  title: 'Music',
                  looping: true,
                ),
                TextListTile(
                  value: level.filename,
                  onChanged: (final filename) {
                    File(path.join(levelsDirectory, level.filename))
                        .deleteSync(recursive: true);
                    level.filename = filename;
                    saveLevel(
                      ref: ref,
                      level: level,
                    );
                  },
                  header: 'Filename',
                  labelText: 'Level filename',
                  title: 'Move Level',
                  validator: (final value) {
                    if (value == null || value.isEmpty) {
                      return 'Filename cannot be blank';
                    }
                    if (path.extension(value) != '.json') {
                      return 'Filename must be .json';
                    }
                    final filenames = Directory(levelsDirectory)
                        .listSync()
                        .whereType<File>()
                        .map((final file) => path.basename(file.path));
                    if (filenames.contains(value)) {
                      return 'Filename must be unique';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        TabbedScaffoldTab(
          title: 'Editor',
          icon: const Icon(Icons.edit),
          actions: [
            SaveButton(onPressed: () => saveLevel(ref: ref, level: level)),
          ],
          builder: (final _) => LevelEditor(levelId: levelId),
        ),
      ],
      initialPageIndex: 1,
    );
  }
}
