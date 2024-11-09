import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_audio_games/flutter_audio_games.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../level_editor.dart';
import '../providers.dart';

/// A widget to show the given [tile].
class TileCard extends ConsumerWidget {
  /// Create an instance.
  const TileCard({
    required this.random,
    required this.tile,
    required this.coordinates,
    super.key,
  });

  /// The random number generator to use.
  final Random random;

  /// The platform at this tile.
  ///
  /// If [tile] is `null`, then [tile] is considered a wall.
  final GameLevelPlatformReference? tile;

  /// The coordinates of the tile.
  final Point<int> coordinates;

  /// Build the widget.
  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final platform = tile;
    final editor = ref.watch(levelEditorContextProvider);
    final Sound sound;
    if (platform == null) {
      sound = editor.wallSound;
    } else {
      final terrain = ref.watch(terrainProvider(platform.terrainId));
      final footstepSounds = ref.watch(
        footstepsProvider(
          key: terrain.footstepSounds,
          destroy: true,
          volume: terrain.footstepSoundsGain,
        ),
      );
      sound = footstepSounds.randomElement(random);
    }
    final tileName = tile?.name ?? '<Wall>';
    return PlaySoundSemantics(
      sound: sound,
      child: Semantics(
        excludeSemantics: true,
        inMutuallyExclusiveGroup: true,
        label: '${coordinates.x}, ${coordinates.y}: $tileName',
        child: Card(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${coordinates.x}, ${coordinates.y}'),
              Expanded(
                flex: 3,
                child: Text(tileName),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
