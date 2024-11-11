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
    required this.linkingPlatformId,
    required this.linkPlatforms,
    required this.showDependentPlatforms,
    required this.resizePlatform,
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

  /// The ID of a platform which is in the process of linking.
  final String? linkingPlatformId;

  /// The function to call to link platforms.
  final VoidCallback linkPlatforms;

  /// The function to call to show dependent platforms.
  final VoidCallback showDependentPlatforms;

  /// The function to call to resize a platform.
  final void Function(MovingDirection direction) resizePlatform;

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
    final terrain = platform == null
        ? null
        : ref.watch(terrainProvider(platform.terrainId));
    final menuChildren = <Widget>[];
    final link = platform?.link;
    final target = link == null
        ? null
        : ref.watch(platformProvider(levelId, link.platformId));
    if (platform != null) {
      if (link != null) {
        menuChildren.addAll([
          MenuItemButton(
            autofocus: linkingPlatformId == null,
            child: Text('Linked with ${target!.name}'),
            onPressed: () => context.pushWidgetBuilder(
              (final _) => EditPlatformScreen(
                platformId: target.id,
                levelId: levelId,
              ),
            ),
          ),
          MenuItemButton(
            child: Text(link.move ? 'Unlink move' : 'Link move'),
            onPressed: () {
              final oldValue = link.move;
              final action = UndoableAction(
                perform: () => link.move = !oldValue,
                undo: () => link.move = oldValue,
              );
              performAction(action);
            },
          ),
          MenuItemButton(
            child: Text(link.resize ? 'Unlink resize' : 'Link resize'),
            onPressed: () {
              final oldValue = link.resize;
              final action = UndoableAction(
                perform: () => link.resize = !oldValue,
                undo: () => link.resize = oldValue,
              );
              performAction(action);
            },
          ),
          MenuItemButton(
            child: const Text('Delete link'),
            onPressed: () {
              final action = UndoableAction(
                perform: () => platform.link = null,
                undo: () => platform.link = link,
              );
              performAction(action);
            },
          ),
        ]);
      } else if (linkingPlatformId == null) {
        menuChildren.add(
          MenuItemButton(
            autofocus: true,
            onPressed: linkPlatforms,
            child: const Text('Start linking'),
          ),
        );
      }
      menuChildren.add(
        MenuItemButton(
          onPressed: showDependentPlatforms,
          child: const Text('Show platform dependencies'),
        ),
      );
      if (linkingPlatformId == platform.id) {
        menuChildren.add(
          MenuItemButton(
            autofocus: true,
            onPressed: linkPlatforms,
            child: const Text('Cancel link'),
          ),
        );
      } else if (linkingPlatformId != null) {
        menuChildren.add(
          MenuItemButton(
            autofocus: true,
            onPressed: linkPlatforms,
            child: const Text('Complete link'),
          ),
        );
      }
    }
    return MenuAnchor(
      menuChildren: menuChildren,
      builder: (final builderContext, final controller, final child) {
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
            if (platform.width > 1)
              PerformableAction(
                name: 'Shrink x',
                activator: const SingleActivator(
                  LogicalKeyboardKey.arrowLeft,
                  alt: true,
                ),
                invoke: () => performAction(
                  UndoableAction(
                    perform: () => resizePlatform(MovingDirection.left),
                    undo: () => resizePlatform(MovingDirection.right),
                  ),
                ),
              ),
            PerformableAction(
              name: 'Expand x',
              activator: const SingleActivator(
                LogicalKeyboardKey.arrowRight,
                alt: true,
              ),
              invoke: () => performAction(
                UndoableAction(
                  perform: () => resizePlatform(MovingDirection.right),
                  undo: () => resizePlatform(MovingDirection.left),
                ),
              ),
            ),
            if (platform.depth > 1)
              PerformableAction(
                name: 'Shrink y',
                activator: const SingleActivator(
                  LogicalKeyboardKey.arrowDown,
                  alt: true,
                ),
                invoke: () => performAction(
                  UndoableAction(
                    perform: () => resizePlatform(MovingDirection.backwards),
                    undo: () => resizePlatform(MovingDirection.forwards),
                  ),
                ),
              ),
            PerformableAction(
              name: 'Expand y',
              activator:
                  const SingleActivator(LogicalKeyboardKey.arrowUp, alt: true),
              invoke: () => performAction(
                UndoableAction(
                  perform: () => resizePlatform(MovingDirection.forwards),
                  undo: () => resizePlatform(MovingDirection.backwards),
                ),
              ),
            ),
            PerformableAction(
              name: 'Link platforms',
              activator: SingleActivator(
                LogicalKeyboardKey.keyL,
                control: useControlKey,
                meta: useMetaKey,
              ),
              invoke: () {
                if (controller.isOpen) {
                  controller.close();
                } else {
                  controller.open();
                }
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
        final String linkText;
        if (linkingPlatformId == null) {
          linkText = '';
        } else if (linkingPlatformId == platformId) {
          linkText = 'Cancel link ';
        } else if (platformId == null) {
          linkText = "Can't link ";
        } else {
          linkText = 'Complete link ';
        }
        final Color colour;
        if (platform == null) {
          colour = Colors.grey.shade300;
        } else if (platform.id == linkingPlatformId) {
          colour = Colors.yellow;
        } else {
          colour = Colors.white;
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
                    onTap(builderContext);
                    return null;
                  },
                ),
              },
              child: GestureDetector(
                onTap: () => onTap(builderContext),
                child: Semantics(
                  label:
                      // ignore: lines_longer_than_80_chars
                      '$linkText${coordinates.x}, ${coordinates.y}: ${platform == null ? "Wall" : '${platform.name} (${terrain!.name})${target == null ? "" : " [${target.name}]"}'}',
                  child: Card(
                    color: colour,
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
                          if (terrain != null) Text(terrain.name),
                          if (target != null) Text(target.name),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// The function to call when the card is tapped.
  void onTap(final BuildContext context) {
    final id = platformId;
    if (id == null) {
      context.showMessage(message: 'This tile is a wall.');
    } else if (linkingPlatformId != null) {
      linkPlatforms();
    } else {
      context.pushWidgetBuilder(
        (final _) => EditPlatformScreen(
          platformId: platformId!,
          levelId: levelId,
        ),
      );
    }
  }
}
