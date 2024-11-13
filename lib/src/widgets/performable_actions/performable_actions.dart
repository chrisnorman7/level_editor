import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'performable_action.dart';

/// A widget which allows [actions] to be performed.
class PerformableActions extends StatelessWidget {
  /// Create an instance.
  const PerformableActions({
    required this.actions,
    required this.child,
    super.key,
  });

  /// The actions which can be performed.
  final List<PerformableAction> actions;

  /// The widget below this widget in the tree.
  final Widget child;

  /// Build the widget.
  @override
  Widget build(final BuildContext context) {
    final actionNames = actions.map((final action) => action.name).toList();
    return Semantics(
      customSemanticsActions: {
        for (final action in actions)
          CustomSemanticsAction(label: action.name): action.invoke,
      },
      child: MenuAnchor(
        menuChildren: [
          for (var i = 0; i < actions.length; i++)
            MenuItemButton(
              autofocus: i == 0,
              onPressed: actions[i].invoke,
              shortcut: actions[i].activator,
              child: Text(actions[i].name),
            ),
        ],
        builder: (final _, final controller, final __) => CallbackShortcuts(
          bindings: {
            for (final action in actions) action.activator: action.invoke,
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              child,
              FocusScope(
                canRequestFocus: false,
                debugLabel: 'More options for actions [$actionNames].',
                child: IconButton(
                  onPressed: () => toggleController(controller),
                  icon: const Icon(Icons.more_vert),
                  tooltip: 'Show / hide menu',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Toggle [controller] open or closed.
  void toggleController(final MenuController controller) {
    if (controller.isOpen) {
      controller.close();
    } else {
      controller.open();
    }
  }
}
