import 'package:backstreets_widgets/screens.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_games/flutter_audio_games.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;

import '../providers.dart';

/// A screen for selecting a new [currentPath] from [paths].
class SelectSoundScreen extends ConsumerWidget {
  /// Create an instance.
  const SelectSoundScreen({
    required this.paths,
    required this.currentPath,
    required this.onDone,
    this.title = 'Select Sound',
    this.looping = false,
    super.key,
  });

  /// The list of paths to choose from.
  final List<String> paths;

  /// The current path.
  final String? currentPath;

  /// The function to call with the new path.
  final void Function(String path) onDone;

  /// The title of the [SimpleScaffold].
  final String title;

  /// Whether the resulting sound should loop.
  final bool looping;

  /// Build the widget.
  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final editor = ref.watch(levelEditorContextProvider);
    return Cancel(
      child: SimpleScaffold(
        title: title,
        body: ListView.builder(
          itemBuilder: (final context, final index) {
            final newPath = paths[index];
            return PlaySoundSemantics(
              sound: newPath.asSound(
                destroy: false,
                soundType: editor.defaultSoundType,
                looping: looping,
              ),
              child: ListTile(
                autofocus: index == 0,
                title: Text(path.basename(newPath)),
                onTap: () {
                  Navigator.pop(context);
                  onDone(newPath);
                },
                selected: newPath == currentPath,
              ),
            );
          },
          itemCount: paths.length,
          shrinkWrap: true,
        ),
      ),
    );
  }
}
