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
  Widget build(final BuildContext context) => CallbackShortcuts(
        bindings: {
          for (final action in actions) action.activator: action.invoke,
        },
        child: Semantics(
          customSemanticsActions: {
            for (final action in actions)
              CustomSemanticsAction(label: action.name): action.invoke,
          },
          child: child,
        ),
      );
}
