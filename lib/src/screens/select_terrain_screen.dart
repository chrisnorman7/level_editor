import 'package:backstreets_widgets/screens.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../level_editor.dart';
import '../providers.dart';
import '../widgets/terrain_list_tile.dart';

/// A screen to select a new terrain.
class SelectTerrainScreen extends ConsumerWidget {
  /// Create an instance.
  const SelectTerrainScreen({
    required this.terrainId,
    required this.onChanged,
    this.title = 'Select Terrain',
    super.key,
  });

  /// The ID of the current terrain.
  final String terrainId;

  /// The function to call when a new terrain is selected.
  final ValueChanged<GameLevelTerrainReference> onChanged;

  /// The title of the [Scaffold].
  final String title;

  /// Build the widget.
  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final terrains = ref.watch(terrainsProvider);
    return Cancel(
      child: SimpleScaffold(
        title: title,
        body: ListView.builder(
          itemBuilder: (final context, final index) {
            final terrain = terrains[index];
            return TerrainListTile(
              autofocus: index == 0,
              selected: terrain.id == terrainId,
              terrainId: terrain.id,
              onTap: (final innerContext) {
                Navigator.pop(innerContext);
                onChanged(terrain);
              },
            );
          },
          itemCount: terrains.length,
          shrinkWrap: true,
        ),
      ),
    );
  }
}
