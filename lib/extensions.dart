import 'package:flutter/material.dart';

import 'src/screens/level_editor_screen.dart';

/// Useful methods on build contexts.
extension BuildContextX on BuildContext {
  /// Get the nearest level editor screen state.
  LevelEditorContext get levelEditor =>
      dependOnInheritedWidgetOfExactType<LevelEditorContext>()!;
}
