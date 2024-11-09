import 'package:backstreets_widgets/screens.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../extensions.dart';
import '../constants.dart';
import '../json/game_level_terrain_reference.dart';
import '../providers.dart';

/// A screen to edit the terrain with the given [terrainId].
class EditTerrainScreen extends ConsumerWidget {
  /// Create an instance.
  const EditTerrainScreen({
    required this.terrainId,
    super.key,
  });

  /// The ID of the terrain to edit.
  final String terrainId;

  /// Build the widget.
  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final editor = context.levelEditor;
    final terrain = ref.watch(
      terrainProvider(editor.terrainsFilename, terrainId),
    );
    return Cancel(
      child: SimpleScaffold(
        title: 'Edit Terrain',
        body: ListView(
          shrinkWrap: true,
          children: [
            TextListTile(
              value: terrain.name,
              onChanged: (final name) {
                terrain.name = name;
                saveTerrain(ref: ref, terrain: terrain);
              },
              header: 'Name',
              autofocus: true,
              labelText: 'Terrain name',
              title: 'Rename Terrain',
            ),
            DoubleListTile(
              value: terrain.footstepSoundsGain,
              onChanged: (final gain) {
                terrain.footstepSoundsGain = gain;
                saveTerrain(ref: ref, terrain: terrain);
              },
              title: 'Footsteps volume',
              min: minVolume,
              max: maxVolume,
              modifier: 0.1,
            ),
          ],
        ),
      ),
    );
  }

  /// Save [terrain].
  void saveTerrain({
    required final WidgetRef ref,
    required final GameLevelTerrainReference terrain,
  }) {
    final editor = ref.context.levelEditor;
    final terrains = ref.read(terrainsProvider(editor.terrainsFilename))
      ..removeWhere((final t) => t.id == terrain.id);
    if (terrains.isEmpty) {
      terrains.add(terrain);
    } else {
      terrains.insert(0, terrain);
    }
    saveTerrains(ref: ref, terrains: terrains);
  }
}
