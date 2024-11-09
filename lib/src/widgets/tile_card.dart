import 'dart:math';

import 'package:backstreets_widgets/extensions.dart';
import 'package:backstreets_widgets/shortcuts.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_audio_games/flutter_audio_games.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../level_editor.dart';
import '../providers.dart';
import 'performable_actions/performable_action.dart';
import 'performable_actions/performable_actions.dart';

/// The random number generator to use.
final random = Random();

/// A widget to show the given [tile].
class TileCard extends ConsumerWidget {
  /// Create an instance.
  const TileCard({
    required this.levelId,
    required this.tile,
    required this.coordinates,
    required this.onTileChange,
    this.autofocus = false,
    super.key,
  });

  /// The ID of the level that [tile] is part of.
  final String levelId;

  /// The platform at this tile.
  ///
  /// If [tile] is `null`, then [tile] is considered a wall.
  final GameLevelPlatformReference? tile;

  /// The coordinates of the tile.
  final Point<int> coordinates;

  /// The function to call when [tile] changes.
  final VoidCallback onTileChange;

  /// Whether the resulting [Focus] should be autofocused.
  final bool autofocus;

  /// Build the widget.
  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final level = ref.watch(gameLevelProvider(levelId));
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
      child: PerformableActions(
        actions: [
          PerformableAction(
            name: 'Rename',
            activator: SingleActivator(
              LogicalKeyboardKey.keyR,
              control: useControlKey,
              meta: useMetaKey,
            ),
            invoke: () {
              if (tile == null) {
                return;
              }
              context.pushWidgetBuilder(
                (final getTextContext) => GetText(
                  onDone: (final value) {
                    Navigator.pop(getTextContext);
                    tile!.name = value;
                    onTileChange();
                  },
                  labelText: 'Platform name',
                  text: tile!.name,
                  title: 'Rename Platform',
                ),
              );
            },
          ),
          PerformableAction(
            name: 'Delete',
            activator: const SingleActivator(LogicalKeyboardKey.delete),
            invoke: () {
              if (tile == null) {
                return;
              }
              for (final other in level.platforms) {
                if (other.link?.platformId == tile!.id) {
                  context.showMessage(
                    message:
                        // ignore: lines_longer_than_80_chars
                        'You cannot delete the $tileName platform until you have unlinked it from ${other.name}.',
                  );
                  return;
                }
              }
              context.confirm(
                message:
                    'Are you sure you want to delete the $tileName platform?',
                title: 'Confirm Delete',
                yesCallback: () {
                  Navigator.pop(context);
                  level.platforms.removeWhere(
                    (final other) => other.id == tile!.id,
                  );
                  onTileChange();
                },
              );
            },
          ),
        ],
        child: Focus(
          autofocus: autofocus,
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
        ),
      ),
    );
  }
}
