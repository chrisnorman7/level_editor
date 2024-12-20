import 'dart:math';

import 'package:backstreets_widgets/extensions.dart';
import 'package:backstreets_widgets/shortcuts.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_audio_games/flutter_audio_games.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

import '../../level_editor.dart';
import '../json/game_level_object_reference.dart';
import '../json/sound_reference.dart';
import '../providers.dart';
import '../screens/edit_platform_screen.dart';
import '../screens/select_terrain_screen.dart';
import '../undoable_action.dart';

/// The random number generator to use.
final random = Random();

/// A widget to show the given [platformId].
class TileCard extends ConsumerWidget {
  /// Create an instance.
  const TileCard({
    required this.focusNode,
    required this.levelId,
    required this.platformId,
    required this.coordinates,
    required this.performAction,
    required this.linkingPlatformId,
    required this.linkPlatforms,
    required this.showDependentPlatforms,
    required this.resizePlatform,
    required this.movePlatform,
    this.autofocus = false,
    super.key,
  });

  /// The focus node to use.
  final FocusNode focusNode;

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

  /// The function to call to move a platform.
  final void Function(MovingDirection direction) movePlatform;

  /// Whether the resulting [Focus] should be autofocused.
  final bool autofocus;

  /// Build the widget.
  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final id = platformId;
    final platform =
        id == null ? null : ref.watch(platformProvider(levelId, id));
    final level = ref.watch(gameLevelProvider(levelId));
    final objects = level.objects
        .where(
          (final object) => object.coordinates == coordinates,
        )
        .toList();
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
    final Sound sound;
    final actions = [
      PerformableAction(
        name: 'New object',
        activator: SingleActivator(
          LogicalKeyboardKey.keyN,
          control: useControlKey,
          meta: useMetaKey,
          shift: true,
        ),
        invoke: () {
          final id = newId();
          final object = GameLevelObjectReference(
            id: id,
            ambiance: SoundReference(
              path: editor.ambianceSounds.first,
            ),
          );
          performAction(
            UndoableAction(
              perform: () => level.objects.add(object),
              undo: () => level.objects.removeWhere,
            ),
          );
        },
      ),
    ];
    if (objects.isNotEmpty) {
      actions.add(
        PerformableAction(
          name: 'Objects menu',
          activator: SingleActivator(
            LogicalKeyboardKey.keyO,
            control: useControlKey,
            meta: useMetaKey,
            shift: true,
          ),
          invoke: () {
            context.announce('Objects.');
          },
        ),
      );
    }
    final menuController = MenuController();
    if (platform == null) {
      sound = editor.wallSound;
      actions.add(
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
                level.platforms.removeWhere(
                  (final other) => other.id == platform.id,
                );
              },
            );
            performAction(action);
          },
        ),
      );
    } else {
      final footstepSounds = ref.watch(
        footstepsProvider(
          key: terrain!.footstepSounds,
          destroy: true,
          volume: terrain.footstepSoundsGain,
        ),
      );
      sound = footstepSounds.randomElement(random);
      actions.addAll(
        [
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
            activator: const SingleActivator(
              LogicalKeyboardKey.arrowUp,
              alt: true,
            ),
            invoke: () => performAction(
              UndoableAction(
                perform: () => resizePlatform(MovingDirection.forwards),
                undo: () => resizePlatform(MovingDirection.backwards),
              ),
            ),
          ),
          if (platform.startX > 0)
            PerformableAction(
              name: 'Move west',
              activator: const SingleActivator(
                LogicalKeyboardKey.arrowLeft,
                shift: true,
              ),
              invoke: () => performAction(
                UndoableAction(
                  perform: () => movePlatform(MovingDirection.left),
                  undo: () => movePlatform(MovingDirection.right),
                ),
              ),
            ),
          PerformableAction(
            name: 'Move east',
            activator: const SingleActivator(
              LogicalKeyboardKey.arrowRight,
              shift: true,
            ),
            invoke: () => performAction(
              UndoableAction(
                perform: () => movePlatform(MovingDirection.right),
                undo: () => movePlatform(MovingDirection.left),
              ),
            ),
          ),
          if (platform.startY > 0)
            PerformableAction(
              name: 'Move south',
              activator: const SingleActivator(
                LogicalKeyboardKey.arrowDown,
                shift: true,
              ),
              invoke: () => performAction(
                UndoableAction(
                  perform: () => movePlatform(MovingDirection.backwards),
                  undo: () => movePlatform(MovingDirection.forwards),
                ),
              ),
            ),
          PerformableAction(
            name: 'Move north',
            activator: const SingleActivator(
              LogicalKeyboardKey.arrowUp,
              shift: true,
            ),
            invoke: () => performAction(
              UndoableAction(
                perform: () => movePlatform(MovingDirection.forwards),
                undo: () => movePlatform(MovingDirection.backwards),
              ),
            ),
          ),
          PerformableAction(
            name: 'Toggle link menu',
            activator: SingleActivator(
              LogicalKeyboardKey.keyL,
              control: useControlKey,
              meta: useMetaKey,
            ),
            invoke: () {
              if (menuController.isOpen) {
                menuController.close();
              } else {
                menuController.open();
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
        ],
      );
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
      colour = Colors.red;
    } else if (linkingPlatformId != null) {
      colour = Colors.yellow;
    } else {
      colour = Colors.white;
    }
    return Semantics(
      onDidGainAccessibilityFocus: () {
        context.maybePlaySound(sound);
        SoLoud.instance.set3dListenerAt(
          coordinates.x.toDouble(),
          coordinates.y.toDouble(),
          0,
        );
      },
      child: PerformableActions(
        actions: actions,
        child: MenuAnchor(
          childFocusNode: focusNode,
          menuChildren: menuChildren,
          controller: menuController,
          builder: (final _, final __, final ___) => FocusableActionDetector(
            focusNode: focusNode,
            autofocus: autofocus,
            actions: {
              ActivateIntent: CallbackAction(
                onInvoke: (final intent) {
                  onTap(context);
                  return null;
                },
              ),
            },
            child: GestureDetector(
              onTap: () => onTap(context),
              child: Semantics(
                label:
                    // ignore: lines_longer_than_80_chars
                    '$linkText${coordinates.x}, ${coordinates.y}: ${platform == null ? "Wall" : '${platform.name} (${terrain!.name})${target == null ? "" : " [${target.name}]"}'}${objects.isEmpty ? "" : ': ${objects.map((final o) => o.name).join(', ')}'}',
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
      ),
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
