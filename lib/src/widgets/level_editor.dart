import 'dart:math';

import 'package:backstreets_widgets/extensions.dart';
import 'package:backstreets_widgets/screens.dart';
import 'package:backstreets_widgets/shortcuts.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_audio_games/flutter_audio_games.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

import '../constants.dart';
import '../exceptions.dart';
import '../json/game_level_platform_reference.dart';
import '../json/game_level_reference.dart';
import '../json/game_level_terrain_reference.dart';
import '../json/platform_link.dart';
import '../providers.dart';
import '../screens/edit_platform_screen.dart';
import '../undoable_action.dart';
import 'terrain_list_tile.dart';
import 'tile_card.dart';

/// A widget for editing the level with the given [levelId].
class LevelEditor extends ConsumerStatefulWidget {
  /// Create an instance.
  const LevelEditor({
    required this.levelId,
    this.startCoordinates = const Point(0, 0),
    super.key,
  });

  /// The ID of the level to edit.
  final String levelId;

  /// The starting coordinates.
  final Point<int> startCoordinates;

  /// Create state for this widget.
  @override
  LevelEditorState createState() => LevelEditorState();
}

/// State for [LevelEditor].
class LevelEditorState extends ConsumerState<LevelEditor> {
  /// The ID of a [GameLevelPlatformReference] that is in the process of being
  /// linked to another.
  String? linkingPlatformId;

  /// The undo queue.
  late final List<UndoableAction> undoActions;

  /// The list of redo actions.
  late final List<UndoableAction> redoActions;

  /// The random number generator to use.
  late final Random random;

  /// The level to work with.
  late GameLevelReference level;

  /// The terrains to work with.
  late List<GameLevelTerrainReference> terrains;

  /// Get the platforms of [level].
  List<GameLevelPlatformReference> get platforms => level.platforms;

  /// The coordinates of the camera.
  late Point<int> coordinates;

  /// The tiles for the level.
  late final Map<Point<int>, GameLevelPlatformReference> tiles;

  /// Whether or not the [level] has unsaved changes.
  bool get levelIsUnsaved => undoActions.isNotEmpty || redoActions.isNotEmpty;

  /// Initialise state.
  @override
  void initState() {
    super.initState();
    undoActions = [];
    redoActions = [];
    random = Random();
    tiles = {};
    setCoordinates(widget.startCoordinates);
  }

  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    const shortcuts = <String>[
      'CTRL+S: Save the level',
      'CTRL+Z: Undo most recent action',
      'CTRL+Y: Redo most recent action',
      'W: Move north',
      'D: move east',
      'S: Move south',
      'A: Move west',
      ']: Move to next platform',
      '[: Move to previous platform',
      'CTRL+N: New platform',
      'CTRL+L: link the current platform',
      'CTRL+R: Rename the current platform',
      'CTRL+T: Change the platform terrain',
      'DELETE: Delete the current platform',
      'CTRL+/: show this help',
    ];
    final editor = ref.watch(levelEditorContextProvider);
    terrains = ref.watch(terrainsProvider);
    level = ref.watch(GameLevelProvider(widget.levelId));
    if (tiles.isEmpty) {
      rebuildTiles();
    }
    return MaybeMusic(
      music: level.music?.asSound(
        destroy: false,
        soundType: editor.defaultSoundType,
        loadMode: LoadMode.disk,
        looping: true,
      ),
      builder: (final _) => Actions(
        actions: {
          UndoTextIntent: CallbackAction(
            onInvoke: (final intent) {
              if (undoActions.isEmpty) {
                context.announce('There is nothing to do.');
              } else {
                final action = undoActions.removeLast();
                redoActions.add(action);
                action.undo();
                setState(rebuildTiles);
              }
              return null;
            },
          ),
          RedoTextIntent: CallbackAction(
            onInvoke: (final intent) {
              if (redoActions.isEmpty) {
                context.announce('There is nothing to redo.');
              } else {
                final action = redoActions.removeLast();
                undoActions.add(action);
                action.perform();
                setState(rebuildTiles);
              }
              return null;
            },
          ),
        },
        child: PopScope(
          canPop: undoActions.isEmpty && redoActions.isEmpty,
          onPopInvokedWithResult: (final didPop, final result) {
            if (didPop) {
              if (levelIsUnsaved) {
                SemanticsService.announce(
                  'You have lost unsaved changes. Sorry.',
                  TextDirection.ltr,
                );
              }
            }
            if (levelIsUnsaved) {
              context.confirm(
                message:
                    // ignore: lines_longer_than_80_chars
                    'You have unsaved changes. Do you want to revert them?',
                title: 'Revert Level',
                noLabel: 'Keep Changes',
                yesCallback: () {
                  Navigator.pop(context);
                  undoActions.clear();
                  redoActions.clear();
                  ref.invalidate(gameLevelsProvider);
                },
                yesLabel: 'Revert Changes',
              );
            }
          },
          child: OrientationBuilder(
            builder: (final innerContext, final orientation) {
              final int columns;
              final int rows;
              switch (orientation) {
                case Orientation.portrait:
                  rows = 6;
                  columns = 3;
                case Orientation.landscape:
                  rows = 3;
                  columns = 5;
              }
              return CallbackShortcuts(
                bindings: {
                  const SingleActivator(LogicalKeyboardKey.escape): () =>
                      Navigator.maybePop(innerContext),
                  SingleActivator(
                    LogicalKeyboardKey.slash,
                    control: useControlKey,
                    meta: useMetaKey,
                  ): () => innerContext.pushWidgetBuilder(
                        (final innerContext) => Cancel(
                          child: SimpleScaffold(
                            title: 'Keyboard Shortcuts',
                            body: ListView.builder(
                              itemBuilder: (final _, final index) {
                                final shortcut = shortcuts[index];
                                return ListTile(
                                  autofocus: index == 0,
                                  title: Text(shortcut),
                                  onTap: shortcut.copyToClipboard,
                                );
                              },
                              itemCount: shortcuts.length,
                              shrinkWrap: true,
                            ),
                          ),
                        ),
                      ),
                  const SingleActivator(LogicalKeyboardKey.keyW): () =>
                      moveCamera(MovingDirection.forwards, rows + 1),
                  const SingleActivator(LogicalKeyboardKey.keyA): () =>
                      moveCamera(MovingDirection.left, columns + 1),
                  const SingleActivator(LogicalKeyboardKey.keyS): () =>
                      moveCamera(MovingDirection.backwards, rows + 1),
                  const SingleActivator(LogicalKeyboardKey.keyD): () =>
                      moveCamera(MovingDirection.right, columns + 1),
                  const SingleActivator(LogicalKeyboardKey.bracketRight): () =>
                      switchPlatforms(1),
                  const SingleActivator(LogicalKeyboardKey.bracketLeft): () =>
                      switchPlatforms(-1),
                  SingleActivator(
                    LogicalKeyboardKey.keyS,
                    control: useControlKey,
                    meta: useMetaKey,
                  ): _saveLevel,
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var row = rows; row >= 0; row--)
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (var column = 0; column <= columns; column++)
                              Builder(
                                builder: (final builderContext) {
                                  final point = Point(
                                    coordinates.x + column,
                                    coordinates.y + row,
                                  );
                                  final tile = getTileAt(point);
                                  return TileCard(
                                    autofocus: row == 0 && column == 0,
                                    levelId: widget.levelId,
                                    platformId: tile?.id,
                                    coordinates: point,
                                    performAction: performAction,
                                    linkingPlatformId: linkingPlatformId,
                                    linkPlatforms: () {
                                      if (tile == null) {
                                        return builderContext.announce(
                                          // ignore: lines_longer_than_80_chars
                                          'If you are seeing this message, some how you could link a wall as if it was a platform.',
                                        );
                                      }
                                      linkPlatforms(tile);
                                    },
                                    showDependentPlatforms: () =>
                                        showPlatformDependencies(
                                      builderContext,
                                      tile!,
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Save the [level].
  void _saveLevel() {
    saveLevel(ref: ref, level: level);
    undoActions.clear();
    redoActions.clear();
    context.announce('Level saved.');
  }

  /// Get the tile at the given [point].
  GameLevelPlatformReference? getTileAt(final Point<int> point) => tiles[point];

  /// Get the current tile.
  GameLevelPlatformReference? get currentTile => getTileAt(coordinates);

  /// Rebuild the [tiles] map.
  ///
  /// If any tiles overlap, [PlatformOverlapException] will be thrown.
  void rebuildTiles() {
    tiles.clear();
    for (final platform in platforms) {
      for (var x = platform.startX; x <= platform.endX; x++) {
        for (var y = platform.startY; y <= platform.endY; y++) {
          final point = Point(x, y);
          final tile = getTileAt(point);
          if (tile != null) {
            throw PlatformOverlapException(
              coordinates: point,
              initialPlatform: tile,
              overlappingPlatform: platform,
            );
          }
          tiles[point] = platform;
        }
      }
    }
  }

  /// Move the camera in the given [direction].
  void moveCamera(final MovingDirection direction, final int distance) {
    final x = switch (direction) {
      MovingDirection.left => coordinates.x - distance,
      MovingDirection.right => coordinates.x + distance,
      _ => coordinates.x
    };
    final y = switch (direction) {
      MovingDirection.forwards => coordinates.y + distance,
      MovingDirection.backwards => coordinates.y - distance,
      _ => coordinates.y
    };
    final point = Point(x, y);
    setCoordinates(point);
    setState(() {});
  }

  /// Set [coordinates] to [point].
  void setCoordinates(final Point<int> point) {
    coordinates = point;
    SoLoud.instance.set3dListenerPosition(
      point.x.toDouble(),
      point.y.toDouble(),
      0,
    );
  }

  /// Announce some [text].
  void announce(final String text) {
    SemanticsService.announce(text, TextDirection.ltr);
  }

  /// Switch to the next or previous platform.
  void switchPlatforms(final int direction) {
    if (platforms.isEmpty) {
      announce('There are no platforms yet.');
    }
    final tile = currentTile;
    final index = tile == null
        ? 0
        : (platforms.indexWhere((final platform) => platform.id == tile.id) +
            direction);
    final platform = platforms[index % platforms.length];
    setCoordinates(platform.start);
  }

  /// Perform an action.
  void performAction(final UndoableAction action) {
    action.perform();
    undoActions.add(action);
    setState(rebuildTiles);
  }

  /// Return all platforms linked to [platform].
  Set<GameLevelPlatformReference> getLinkedPlatforms(
    final GameLevelPlatformReference platform,
  ) {
    final links = <GameLevelPlatformReference>{};
    for (final other
        in platforms.where((final p) => p.link?.platformId == platform.id)) {
      links.addAll([other, ...getLinkedPlatforms(other)]);
    }
    return links;
  }

  /// Link 2 platforms.
  void linkPlatforms(final GameLevelPlatformReference platform) {
    final id = linkingPlatformId;
    if (id == null) {
      setState(() {
        linkingPlatformId = platform.id;
      });
    } else if (id == platform.id) {
      setState(() {
        linkingPlatformId = null;
      });
    } else {
      final from = ref.read(platformProvider(widget.levelId, id));
      final links = getLinkedPlatforms(from);
      if (links.contains(platform)) {
        final index = links.toList().indexOf(platform);
        context.showMessage(
          message:
              // ignore: lines_longer_than_80_chars
              '${from.name} is already linked to ${platform.name} ${index == 0 ? "directly" : "via ${links.elementAt(index - 1).name}"}.',
        );
        return;
      }
      from.link = PlatformLink(platformId: platform.id);
      setState(() {
        linkingPlatformId = null;
      });
    }
  }

  /// Show all the platforms which depend on [platform] in a menu.
  Future<void> showPlatformDependencies(
    final BuildContext context,
    final GameLevelPlatformReference platform,
  ) {
    final dependencies = getLinkedPlatforms(platform);
    if (dependencies.isEmpty) {
      return context.showMessage(message: 'This platform has no dependencies.');
    }
    return context.pushWidgetBuilder(
      (final _) => Cancel(
        child: SimpleScaffold(
          title: 'Platform Dependencies',
          body: ListView.builder(
            itemBuilder: (final context, final index) {
              final dependent = dependencies.elementAt(index);
              return TerrainListTile(
                autofocus: index == 0,
                terrainId: dependent.terrainId,
                title: dependent.name,
                onTap: (final innerContext) => innerContext.pushWidgetBuilder(
                  (final builderContext) {
                    innerContext.stopPlaySoundsSemantics();
                    return EditPlatformScreen(
                      platformId: dependent.id,
                      levelId: widget.levelId,
                    );
                  },
                ),
              );
            },
            itemCount: dependencies.length,
          ),
        ),
      ),
    );
  }
}
