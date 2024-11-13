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
import '../json/game_level_object_reference.dart';
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
    this.longestSide = 6,
    this.shortestSide = 4,
    super.key,
  });

  /// The ID of the level to edit.
  final String levelId;

  /// The starting coordinates.
  final Point<int> startCoordinates;

  /// The number of tiles to show along the longest side of the editor.
  final int longestSide;

  /// The number of tiles to show along the shortest side of the editor.
  final int shortestSide;

  /// Create state for this widget.
  @override
  LevelEditorState createState() => LevelEditorState();
}

/// State for [LevelEditor].
class LevelEditorState extends ConsumerState<LevelEditor> {
  /// How many columns of tiles to show.
  late int columns;

  /// How many rows of tiles to show.
  late int rows;

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

  /// The objects which are part of the [level].
  late final Map<Point<int>, GameLevelObjectReference> objects;

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
    objects = {};
    _setCoordinates(widget.startCoordinates);
  }

  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    const shortcuts = <String>[
      'CTRL+S: Save the level',
      'CTRL+Z: Undo most recent action',
      'CTRL+SHIFT+Z: Redo most recent action',
      'W: Move north',
      'D: move east',
      'S: Move south',
      'A: Move west',
      ']: Move to next platform',
      '[: Move to previous platform',
      'CTRL+N: New platform',
      'CTRL+L: Toggle link menu',
      'CTRL+R: Rename the current platform',
      'CTRL+T: Change the platform terrain',
      'ALT+Arrows: Resize platforms',
      'SHIFT+Arrows: Move platforms',
      'DELETE: Delete the current platform',
      'CTRL+SHIFT+N: New object',
      'CTRL+SHIFT+O: Objects menu',
      'CTRL+/: show this help',
    ];
    final editor = ref.watch(levelEditorContextProvider);
    terrains = ref.watch(terrainsProvider);
    level = ref.watch(GameLevelProvider(widget.levelId));
    if (tiles.isEmpty) {
      rebuildTiles();
    }
    return AmbiancesBuilder(
      ambiances: level.objects
          .where((final object) => object.ambiance != null)
          .map(
            (final object) => object.ambiance!.asSound(
              destroy: false,
              soundType: editor.defaultSoundType,
              looping: true,
              position: SoundPosition3d(
                object.x.toDouble(),
                object.y.toDouble(),
                0.0,
              ),
            ),
          )
          .toList(),
      builder: (final ambianceBuilderContext, final ambiances) => MaybeMusic(
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
                switch (orientation) {
                  case Orientation.portrait:
                    rows = widget.longestSide;
                    columns = widget.shortestSide;
                  case Orientation.landscape:
                    rows = widget.shortestSide;
                    columns = widget.longestSide;
                }
                return CallbackShortcuts(
                  bindings: {
                    const SingleActivator(LogicalKeyboardKey.escape): () =>
                        Navigator.maybePop(ambianceBuilderContext),
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
                        moveCamera(MovingDirection.forwards),
                    const SingleActivator(LogicalKeyboardKey.keyA): () =>
                        moveCamera(MovingDirection.left),
                    const SingleActivator(LogicalKeyboardKey.keyS): () =>
                        moveCamera(MovingDirection.backwards),
                    const SingleActivator(LogicalKeyboardKey.keyD): () =>
                        moveCamera(MovingDirection.right),
                    const SingleActivator(LogicalKeyboardKey.bracketRight):
                        () => switchPlatforms(1),
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
                                      resizePlatform: (final direction) =>
                                          resizePlatform(
                                        tile!,
                                        direction,
                                      ),
                                      movePlatform: (final direction) =>
                                          movePlatform(
                                        tile!,
                                        direction,
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
    objects.clear();
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
    for (final object in level.objects) {
      objects[object.coordinates] = object;
    }
  }

  /// Move the camera in the given [direction].
  void moveCamera(
    final MovingDirection direction,
  ) {
    final x = switch (direction) {
      MovingDirection.left => coordinates.x - columns - 1,
      MovingDirection.right => coordinates.x + columns + 1,
      _ => coordinates.x
    };
    final y = switch (direction) {
      MovingDirection.forwards => coordinates.y + rows + 1,
      MovingDirection.backwards => coordinates.y - rows - 1,
      _ => coordinates.y
    };
    final point = Point(x, y);
    _setCoordinates(point);
  }

  /// Set [coordinates] to [point].
  ///
  /// This method does no smoothing. As such, [point] always ends up being the
  /// bottom left coordinate.
  ///
  /// If you want a method with smoothing, use [panToCoordinates].
  void _setCoordinates(final Point<int> point) {
    coordinates = point;
    SoLoud.instance.set3dListenerPosition(
      point.x.toDouble(),
      point.y.toDouble(),
      0,
    );
    setState(() {});
  }

  /// Pan the screen to [point].
  void panToCoordinates(final Point<int> point) {
    _setCoordinates(
      Point(point.x - (point.x % columns), point.y - (point.y % rows)),
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
    panToCoordinates(platform.start);
  }

  /// Perform an action.
  void performAction(final UndoableAction action) {
    action.perform();
    undoActions.add(action);
    setState(rebuildTiles);
  }

  /// Return all platforms linked to [platform].
  Set<GameLevelPlatformReference> getLinkedPlatforms(
    final GameLevelPlatformReference platform, {
    final bool? move,
    final bool? resize,
  }) {
    final links = <GameLevelPlatformReference>{};
    for (final other
        in platforms.where((final p) => p.link?.platformId == platform.id)) {
      final link = other.link!;
      if ((move == null || move == link.move) &&
          (resize == null || resize == link.resize)) {
        links.addAll([other, ...getLinkedPlatforms(other)]);
      }
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

  /// Resize [platform] in the given [direction].
  void resizePlatform(
    final GameLevelPlatformReference platform,
    final MovingDirection direction,
  ) {
    final width = switch (direction) {
      MovingDirection.left => -1,
      MovingDirection.right => 1,
      _ => 0
    };
    final depth = switch (direction) {
      MovingDirection.forwards => 1,
      MovingDirection.backwards => -1,
      _ => 0
    };
    final finishedPlatforms = <GameLevelPlatformReference>[];
    for (final p in [platform, ...getLinkedPlatforms(platform, resize: true)]) {
      finishedPlatforms.add(p);
      p
        ..width += width
        ..depth += depth;
      var fail = false;
      if (p.width < 1) {
        fail = true;
        context.showMessage(
          message:
              // ignore: lines_longer_than_80_chars
              'Resize failed because ${p.name} would have a width of ${p.width}.',
        );
      } else if (p.depth < 1) {
        fail = true;
        context.showMessage(
          message:
              // ignore: lines_longer_than_80_chars
              'Resize failed because ${p.name} would have a depth of ${p.depth}.',
        );
      } else {
        try {
          rebuildTiles();
        } on PlatformOverlapException catch (e) {
          fail = true;
          context.showMessage(
            message:
                // ignore: lines_longer_than_80_chars
                'Resize failed because ${e.initialPlatform.name} would overlap ${e.overlappingPlatform.name} at ${e.coordinates.x}, ${e.coordinates.y}.',
          );
        }
      }
      if (fail) {
        for (final failed in finishedPlatforms) {
          failed
            ..depth += (depth * -1)
            ..width += (width * -1);
        }
        return;
      }
    }
    context.announce(
      '${platform.name} resized to ${platform.width} x ${platform.depth}.',
    );
  }

  /// Move [platform] in the given [direction].
  void movePlatform(
    final GameLevelPlatformReference platform,
    final MovingDirection direction,
  ) {
    final x = switch (direction) {
      MovingDirection.left => -1,
      MovingDirection.right => 1,
      _ => 0
    };
    final y = switch (direction) {
      MovingDirection.forwards => 1,
      MovingDirection.backwards => -1,
      _ => 0
    };
    final finishedPlatforms = <GameLevelPlatformReference>[];
    for (final p in [platform, ...getLinkedPlatforms(platform, move: true)]) {
      finishedPlatforms.add(p);
      p
        ..startX += x
        ..startY += y;
      var fail = false;
      if (p.startX < 0 || p.startY < 0) {
        fail = true;
        context.showMessage(
          message:
              // ignore: lines_longer_than_80_chars
              'Cannot move ${platform.name} because it would cause ${p.name} to have starting coordinates of ${p.startX}, ${p.startY}.',
        );
      } else {
        try {
          rebuildTiles();
        } on PlatformOverlapException catch (e) {
          fail = true;
          context.showMessage(
            message:
                // ignore: lines_longer_than_80_chars
                'Move failed because ${e.initialPlatform.name} would overlap ${e.overlappingPlatform.name} at ${e.coordinates.x}, ${e.coordinates.y}.',
          );
        }
      }
      if (fail) {
        for (final failed in finishedPlatforms) {
          failed
            ..startY += (y * -1)
            ..startX += (x * -1);
        }
        return;
      }
    }
    context.announce(
      '${platform.name} moved to ${platform.startX}, ${platform.startY}.',
    );
  }
}
