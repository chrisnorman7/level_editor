import 'package:backstreets_widgets/screens.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';

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
            CopyListTile(
              title: 'Start coordinates',
              subtitle: '${platform.startX}, ${platform.startY}',
              autofocus: true,
            ),
            CopyListTile(title: 'Width', subtitle: '${platform.width}'),
            CopyListTile(title: 'Depth', subtitle: '${platform.depth}'),
            CopyListTile(
              title: 'End coordinates',
              subtitle: '${platform.end.x}, ${platform.end.y}',
            ),
          ],
        ),
      ),
    );
  }
}
