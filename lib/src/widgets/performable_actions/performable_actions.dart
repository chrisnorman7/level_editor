import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

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
  Widget build(final BuildContext context) => Semantics(
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
                child: Text(actions[i].name),
              ),
          ],
          builder: (final _, final controller, final __) => CallbackShortcuts(
            bindings: {
              const SingleActivator(LogicalKeyboardKey.enter): () =>
                  toggleController(controller),
              const SingleActivator(LogicalKeyboardKey.space): () =>
                  toggleController(controller),
              for (final action in actions) action.activator: action.invoke,
            },
            child: GestureDetector(
              onTap: () => toggleController(controller),
              child: child,
            ),
          ),
        ),
      );

  /// Toggle [controller] open or closed.
  void toggleController(final MenuController controller) {
    if (controller.isOpen) {
      controller.close();
    } else {
      controller.open();
    }
  }
}
