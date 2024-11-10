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
import '../screens/select_terrain_screen.dart';
import '../undoable_action.dart';
import 'performable_actions/performable_action.dart';
import 'performable_actions/performable_actions.dart';

/// The random number generator to use.
final random = Random();

/// A widget to show the given [platformId].
class TileCard extends ConsumerWidget {
  /// Create an instance.
  const TileCard({
    required this.levelId,
    required this.platformId,
    required this.coordinates,
    required this.performAction,
    this.autofocus = false,
    super.key,
  });

  /// The ID of the level that [platformId] is part of.
  final String levelId;

  /// The ID of the platform at [coordinates].
  ///
  /// If [platformId] is `null`, then the platform is considered a wall.
  final String? platformId;

  /// The coordinates of the tile.
  final Point<int> coordinates;

  /// The function to call to perform an action.
  final void Function(UndoableAction action) performAction;

  /// Whether the resulting [Focus] should be autofocused.
  final bool autofocus;

  /// Build the widget.
  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final id = platformId;
    final platform =
        id == null ? null : ref.watch(platformProvider(levelId, id));
    final level = ref.watch(gameLevelProvider(levelId));
    final editor = ref.watch(levelEditorContextProvider);
    final Sound sound;
    final List<PerformableAction> actions;
    final GameLevelTerrainReference? terrain;
    if (platform == null) {
      terrain = null;
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
            final terrains = ref.read(terrainsProvider);
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
      terrain = ref.watch(terrainProvider(platform.terrainId));
      final footstepSounds = ref.watch(
        footstepsProvider(
          key: terrain!.footstepSounds,
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
            final oldName = platform.name;
            context.pushWidgetBuilder(
              (final getTextContext) => GetText(
                onDone: (final value) {
                  Navigator.pop(getTextContext);
                  final action = UndoableAction(
                    perform: () => platform.name = value,
                    undo: () => platform.name = oldName,
                  );
                  performAction(action);
                },
                labelText: 'Platform name',
                text: oldName,
                title: 'Rename Platform',
              ),
            );
          },
        ),
        PerformableAction(
          name: 'Change terrain',
          activator: SingleActivator(
            LogicalKeyboardKey.keyT,
            control: useControlKey,
            meta: useMetaKey,
          ),
          invoke: () {
            final oldTerrainId = platform.terrainId;
            context.pushWidgetBuilder(
              (final _) => SelectTerrainScreen(
                terrainId: platform.terrainId,
                onChanged: (final value) {
                  final action = UndoableAction(
                    perform: () {
                      platform.terrainId = value.id;
                    },
                    undo: () {
                      platform.terrainId = oldTerrainId;
                    },
                  );
                  performAction(action);
                },
              ),
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
      key: platform == null ? null : ValueKey(platform.toJson().toString()),
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
                  (final _) => EditPlatformScreen(
                    platformId: platform.id,
                    levelId: levelId,
                  ),
                );
                return null;
              },
            ),
          },
          child: Semantics(
            label:
                // ignore: lines_longer_than_80_chars
                '${coordinates.x}, ${coordinates.y}: ${platform == null ? "Wall" : '${platform.name} (${terrain!.name})'}',
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
                          : Text('${platform.name} (${terrain!.name})'),
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
