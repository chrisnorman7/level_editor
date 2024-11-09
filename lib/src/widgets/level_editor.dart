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
import '../providers.dart';
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

  /// Initialise state.
  @override
  void initState() {
    super.initState();
    random = Random();
    tiles = {};
    setCoordinates(widget.startCoordinates);
  }

  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    const shortcuts = <String>[
      'W: Move north',
      'D: move east',
      'S: Move south',
      'A: Move west',
      ']: Move to next platform',
      '[: Move to previous platform',
      'CTRL+N: New platform',
      'CTRL+L: link the current platform',
      'CTRL+R: Rename the current platform',
      'DELETE: Delete the current platform',
      'CTRL+/: show this help',
    ];
    terrains = ref.watch(terrainsProvider);
    level = ref.watch(GameLevelProvider(widget.levelId));
    if (tiles.isEmpty) {
      rebuildTiles();
    }
    return OrientationBuilder(
      builder: (final context, final orientation) {
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
            SingleActivator(
              LogicalKeyboardKey.slash,
              control: useControlKey,
              meta: useMetaKey,
            ): () => context.pushWidgetBuilder(
                  (final innerContext) => Cancel(
                    child: SimpleScaffold(
                      title: 'Keyboard Shortcuts',
                      body: ListView.builder(
                        itemBuilder: (final context, final index) {
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
              LogicalKeyboardKey.keyN,
              control: useControlKey,
              meta: useMetaKey,
            ): newPlatform,
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
                        TileCard(
                          autofocus: row == 0 && column == 0,
                          levelId: widget.levelId,
                          tile: getTileAt(
                            Point(
                              coordinates.x + column,
                              coordinates.y + row,
                            ),
                          ),
                          coordinates: Point(
                            coordinates.x + column,
                            coordinates.y + row,
                          ),
                          onTileChange: () => setState(() {}),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
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

  /// Create a new platform.
  void newPlatform() {
    final platform = GameLevelPlatformReference(
      id: newId(),
      terrainId: terrains.first.id,
      startX: max(0, coordinates.x),
      startY: max(0, coordinates.y),
    );
    if (coordinates.x < 0 || coordinates.y < 0) {
      for (final platform in platforms) {
        if (coordinates.x < 0) {
          platform.startX -= coordinates.x;
        }
        if (coordinates.y < 0) {
          platform.startY -= coordinates.y;
        }
      }
    }
    platforms.add(platform);
    rebuildTiles();
    setCoordinates(platform.start);
    setState(() {});
  }
}
