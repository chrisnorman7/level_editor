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
import '../screens/edit_platform_screen.dart';
import '../undoable_action.dart';
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
    required this.performAction,
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

  /// The function to call to perform an action.
  final void Function(UndoableAction action) performAction;

  /// Whether the resulting [Focus] should be autofocused.
  final bool autofocus;

  /// Build the widget.
  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final level = ref.watch(gameLevelProvider(levelId));
    final platform = tile;
    final editor = ref.watch(levelEditorContextProvider);
    final terrains = ref.watch(terrainsProvider);
    final Sound sound;
    final List<PerformableAction> actions;
    if (platform == null) {
      sound = editor.wallSound;
      actions = [
        PerformableAction(
          name: 'New platform',
          activator: SingleActivator(
            LogicalKeyboardKey.keyN,
            control: useControlKey,
            meta: useMetaKey,
          ),
          invoke: () {
            final platform = GameLevelPlatformReference(
              id: newId(),
              terrainId: terrains.first.id,
              startX: max(0, coordinates.x),
              startY: max(0, coordinates.y),
            );
            if (coordinates.x < 0 || coordinates.y < 0) {
              for (final other in level.platforms) {
                if (coordinates.x < 0) {
                  other.startX -= coordinates.x;
                }
                if (coordinates.y < 0) {
                  other.startY -= coordinates.y;
                }
              }
            }
            final action = UndoableAction(
              perform: () {
                level.platforms.add(platform);
              },
              undo: () {
                level.platforms
                    .removeWhere((final other) => other.id == platform.id);
              },
            );
            performAction(action);
          },
        ),
      ];
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
      actions = [
        PerformableAction(
          name: 'Rename',
          activator: SingleActivator(
            LogicalKeyboardKey.keyR,
            control: useControlKey,
            meta: useMetaKey,
          ),
          invoke: () {
            context.pushWidgetBuilder(
              (final getTextContext) {
                final oldName = platform.name;
                return GetText(
                  onDone: (final value) {
                    Navigator.pop(getTextContext);
                    final action = UndoableAction(
                      perform: () {
                        platform.name = value;
                      },
                      undo: () => platform.name = oldName,
                    );
                    performAction(action);
                  },
                  labelText: 'Platform name',
                  text: oldName,
                  title: 'Rename Platform',
                );
              },
            );
          },
        ),
        PerformableAction(
          name: 'Delete',
          activator: const SingleActivator(LogicalKeyboardKey.delete),
          invoke: () {
            for (final other in level.platforms) {
              if (other.link?.platformId == platform.id) {
                context.showMessage(
                  message:
                      // ignore: lines_longer_than_80_chars
                      'You cannot delete the ${platform.name} platform until you have unlinked it from ${other.name}.',
                );
                return;
              }
            }
            context.confirm(
              message:
                  // ignore: lines_longer_than_80_chars
                  'Are you sure you want to delete the ${platform.name} platform?',
              title: 'Confirm Delete',
              yesCallback: () {
                Navigator.pop(context);
                final action = UndoableAction(
                  perform: () {
                    level.platforms.removeWhere(
                      (final other) => other.id == platform.id,
                    );
                  },
                  undo: () {
                    level.platforms.add(platform);
                  },
                );
                performAction(action);
              },
            );
          },
        ),
      ];
    }
    return PlaySoundSemantics(
      key: ValueKey(tile?.id ?? 'wall'),
      sound: sound,
      child: PerformableActions(
        actions: actions,
        child: FocusableActionDetector(
          autofocus: autofocus,
          actions: {
            ActivateIntent: CallbackAction(
              onInvoke: (final intent) {
                if (platform == null) {
                  return null;
                }
                context.pushWidgetBuilder(
                  (final _) =>
                      EditPlatformScreen(platform: platform, levelId: levelId),
                );
                return null;
              },
            ),
          },
          child: Semantics(
            label:
                // ignore: lines_longer_than_80_chars
                '${coordinates.x}, ${coordinates.y}: ${platform?.name ?? 'Wall'}',
            child: Card(
              color: platform == null ? Colors.grey.shade300 : Colors.white,
              elevation: 3,
              margin: const EdgeInsets.all(8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${coordinates.x}, ${coordinates.y}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: platform == null
                          ? const Icon(
                              Icons.crop_din,
                              semanticLabel: 'Wall',
                            )
                          : Text(platform.name),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
