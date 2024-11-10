import 'package:flutter/material.dart';
import 'package:flutter_audio_games/flutter_audio_games.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';

/// A [ListTile] which shows a terrain with the given [terrainId].
class TerrainListTile extends ConsumerWidget {
  /// Create an instance.
  const TerrainListTile({
    required this.terrainId,
    required this.onTap,
    this.title,
    this.autofocus = false,
    this.selected = false,
    super.key,
  });

  /// The ID of terrain to show.
  final String terrainId;

  /// The function to call when the [ListTile] is tapped.
  final void Function(BuildContext innerContext) onTap;

  /// The title of the [ListTile].
  ///
  /// If [title] is `null`, then the name of the terrain will be used.
  ///
  /// If [title] is not `null`, then the name of the terrain will become the
  /// subtitle.
  final String? title;

  /// Whether the [ListTile] should be autofocused.
  final bool autofocus;

  /// Whether the [ListTile] should be focused.
  final bool selected;

  /// Build the widget.
  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final terrain = ref.watch(terrainProvider(terrainId));
    final footsteps = ref.watch(
      footstepsProvider(key: terrain.footstepSounds, destroy: false),
    );
    return PlaySoundsSemantics(
      sounds: footsteps,
      interval: terrain.footstepInterval,
      child: Builder(
        builder: (final innerContext) => ListTile(
          autofocus: autofocus,
          title: Text(title ?? terrain.name),
          subtitle: title == null ? null : Text(terrain.name),
          onTap: () => onTap(innerContext),
        ),
      ),
    );
  }
}
