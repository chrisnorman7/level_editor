import 'dart:math';

import 'json/game_level_platform_reference.dart';

/// Two platforms overlap each other.
class PlatformOverlapException implements Exception {
  /// Create an instance.
  const PlatformOverlapException({
    required this.coordinates,
    required this.initialPlatform,
    required this.overlappingPlatform,
  });

  /// The coordinates where the overlap occurs.
  final Point<int> coordinates;

  /// The platform which was there first.
  final GameLevelPlatformReference initialPlatform;

  /// The overlapping platform.
  final GameLevelPlatformReference overlappingPlatform;
}
