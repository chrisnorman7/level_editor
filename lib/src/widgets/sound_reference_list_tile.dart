import 'package:backstreets_widgets/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_games/flutter_audio_games.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;

import '../json/sound_reference.dart';
import '../providers.dart';
import '../screens/select_sound_screen.dart';

/// A [ListTile] for editing a [SoundReference].
class SoundReferenceListTile extends ConsumerWidget {
  /// Create an instance.
  const SoundReferenceListTile({
    required this.soundReference,
    required this.possiblePaths,
    required this.onChanged,
    required this.title,
    this.autofocus = false,
    this.looping = false,
    super.key,
  }) : assert(
          possiblePaths.length > 0,
          'You must provide at least 1 possible path.',
        );

  /// The sound reference to use.
  final SoundReference? soundReference;

  /// The possible paths for [soundReference].
  final List<String> possiblePaths;

  /// The function to call when [soundReference] is edited.
  final ValueChanged<SoundReference?> onChanged;

  /// The title of the [ListTile].
  final String title;

  /// Whether the [ListTile] should be autofocused.
  final bool autofocus;

  /// Whether the resulting sound should loop.
  final bool looping;

  /// Build the widget.
  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final reference = soundReference;
    final editor = ref.watch(levelEditorContextProvider);
    if (reference == null) {
      return ListTile(
        autofocus: autofocus,
        title: Text(title),
        subtitle: const Text('Not set'),
        onTap: () => context.pushWidgetBuilder(
          (final _) => SelectSoundScreen(
            paths: possiblePaths,
            currentPath: null,
            onDone: (final path) => onChanged(SoundReference(path: path)),
          ),
        ),
      );
    }
    final sound = reference.asSound(
      destroy: false,
      soundType: editor.defaultSoundType,
      looping: looping,
    );
    return PlaySoundSemantics(
      sound: sound,
      child: Builder(
        builder: (final builderContext) => ListTile(
          autofocus: autofocus,
          title: Text(title),
          subtitle: Text(path.basename(reference.path)),
          onTap: () => builderContext.pushWidgetBuilder((final innerContext) {
            builderContext.stopPlaySoundSemantics();
            return SelectSoundScreen(
              paths: possiblePaths,
              currentPath: reference.path,
              onDone: (final newPath) {
                reference.path = newPath;
                onChanged(reference);
              },
              looping: looping,
            );
          }),
        ),
      ),
    );
  }
}
