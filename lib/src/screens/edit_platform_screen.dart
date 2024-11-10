import 'package:backstreets_widgets/extensions.dart';
import 'package:backstreets_widgets/screens.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_games/flutter_audio_games.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants.dart';
import '../providers.dart';
import '../widgets/terrain_list_tile.dart';
import 'select_terrain_screen.dart';

/// A screen to edit the given [platform] from the level with the given
/// [levelId].
class EditPlatformScreen extends ConsumerWidget {
  /// Create an instance.
  const EditPlatformScreen({
    required this.platformId,
    required this.levelId,
    super.key,
  });

  /// The ID of the platform to edit.
  final String platformId;

  /// The ID of the level that [platform] belongs to.
  final String levelId;

  /// Build the widget.
  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final platform = ref.watch(platformProvider(levelId, platformId));
    return Cancel(
      child: SimpleScaffold(
        title: 'Edit Platform',
        body: ListView(
          shrinkWrap: true,
          children: [
            TextListTile(
              value: platform.name,
              onChanged: (final name) {
                platform.name = name;
                invalidateProviders(ref);
              },
              header: 'Name',
              autofocus: true,
              labelText: 'Platform name',
              title: 'Rename Platform',
            ),
            TerrainListTile(
              terrainId: platform.terrainId,
              onTap: (final innerContext) =>
                  innerContext.pushWidgetBuilder((final _) {
                innerContext.stopPlaySoundsSemantics();
                return SelectTerrainScreen(
                  terrainId: platform.terrainId,
                  onChanged: (final value) {
                    platform.terrainId = value.id;
                    invalidateProviders(ref);
                  },
                  title: 'Terrain',
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  /// Invalidate providers.
  void invalidateProviders(final WidgetRef ref) {
    final level = ref.read(gameLevelProvider(levelId));
    saveLevel(ref: ref, level: level);
    ref
      ..invalidate(gameLevelProvider(levelId))
      ..invalidate(platformProvider(levelId, platformId));
  }
}
