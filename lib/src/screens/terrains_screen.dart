import 'package:backstreets_widgets/extensions.dart';
import 'package:backstreets_widgets/screens.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../extensions.dart';
import '../constants.dart';
import '../json/game_level_terrain_reference.dart';
import '../providers.dart';
import 'edit_terrain_screen.dart';

/// A screen to show the created terrains.
class TerrainsScreen extends ConsumerWidget {
  /// Create an instance.
  const TerrainsScreen({
    super.key,
  });

  /// Build the widget.
  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final editor = context.levelEditor;
    final terrains = ref.watch(terrainsProvider(editor.terrainsFilename));
    final Widget child;
    if (terrains.isEmpty) {
      child = const CenterText(
        text: 'There are no terrains to show.',
        autofocus: true,
      );
    } else {
      child = ListView.builder(
        itemBuilder: (final context, final index) {
          final terrain = terrains[index];
          return CommonShortcuts(
            deleteCallback: () {
              final levels = ref.read(
                GameLevelsProvider(editor.levelsDirectory),
              );
              for (final level in levels) {
                for (final platform in level.platforms) {
                  if (platform.terrainId == terrain.id) {
                    context.showMessage(
                      message:
                          // ignore: lines_longer_than_80_chars
                          'This terrain is being used by the ${platform.name} platform of the ${level.name} level.',
                    );
                    return;
                  }
                }
              }
              terrains.removeWhere((final t) => t.id == terrain.id);
              saveTerrains(
                ref: ref,
                terrains: terrains,
              );
            },
            child: ListTile(
              autofocus: index == 0,
              title: Text(terrain.name),
              onTap: () => context.pushWidgetBuilder(
                (final _) => EditTerrainScreen(terrainId: terrain.id),
              ),
            ),
          );
        },
        itemCount: terrains.length,
        shrinkWrap: true,
      );
    }
    return CommonShortcuts(
      newCallback: () => newTerrain(ref),
      child: Cancel(
        child: SimpleScaffold(
          title: 'Terrains',
          body: child,
          floatingActionButton: NewButton(
            onPressed: () => newTerrain(ref),
            tooltip: 'New Terrain',
          ),
        ),
      ),
    );
  }

  /// Create a new terrain.
  void newTerrain(final WidgetRef ref) {
    final editor = ref.context.levelEditor;
    final terrains = ref.read(terrainsProvider(editor.terrainsFilename));
    final terrain = GameLevelTerrainReference(id: newId(), footstepSounds: []);
    terrains.add(terrain);
    saveTerrains(ref: ref, terrains: terrains);
    ref.context.pushWidgetBuilder(
      (final _) => EditTerrainScreen(terrainId: terrain.id),
    );
  }
}
