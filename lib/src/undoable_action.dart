import 'package:flutter/material.dart';

/// An action with can be [perform]ed, or [undo]ne.
class UndoableAction {
  /// Create an instance.
  UndoableAction({required this.perform, required this.undo});

  /// The function to call to perform the action.
  final VoidCallback perform;

  /// The function to call to undo the action.
  final VoidCallback undo;
}
