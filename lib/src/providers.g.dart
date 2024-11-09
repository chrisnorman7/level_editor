// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$terrainsHash() => r'6b2c86330c6e6e3b8295b0fd07e7acb6de60842d';

/// Provide the terrains that have been created.
///
/// Copied from [terrains].
@ProviderFor(terrains)
final terrainsProvider =
    AutoDisposeProvider<List<GameLevelTerrainReference>>.internal(
  terrains,
  name: r'terrainsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$terrainsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TerrainsRef = AutoDisposeProviderRef<List<GameLevelTerrainReference>>;
String _$terrainHash() => r'e1bae8c9f6e785730284850c6e6e95717ebe6810';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Provide the terrain with the given [id].
///
/// Copied from [terrain].
@ProviderFor(terrain)
const terrainProvider = TerrainFamily();

/// Provide the terrain with the given [id].
///
/// Copied from [terrain].
class TerrainFamily extends Family<GameLevelTerrainReference> {
  /// Provide the terrain with the given [id].
  ///
  /// Copied from [terrain].
  const TerrainFamily();

  /// Provide the terrain with the given [id].
  ///
  /// Copied from [terrain].
  TerrainProvider call(
    String id,
  ) {
    return TerrainProvider(
      id,
    );
  }

  @override
  TerrainProvider getProviderOverride(
    covariant TerrainProvider provider,
  ) {
    return call(
      provider.id,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'terrainProvider';
}

/// Provide the terrain with the given [id].
///
/// Copied from [terrain].
class TerrainProvider extends AutoDisposeProvider<GameLevelTerrainReference> {
  /// Provide the terrain with the given [id].
  ///
  /// Copied from [terrain].
  TerrainProvider(
    String id,
  ) : this._internal(
          (ref) => terrain(
            ref as TerrainRef,
            id,
          ),
          from: terrainProvider,
          name: r'terrainProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$terrainHash,
          dependencies: TerrainFamily._dependencies,
          allTransitiveDependencies: TerrainFamily._allTransitiveDependencies,
          id: id,
        );

  TerrainProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    GameLevelTerrainReference Function(TerrainRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TerrainProvider._internal(
        (ref) => create(ref as TerrainRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<GameLevelTerrainReference> createElement() {
    return _TerrainProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TerrainProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TerrainRef on AutoDisposeProviderRef<GameLevelTerrainReference> {
  /// The parameter `id` of this provider.
  String get id;
}

class _TerrainProviderElement
    extends AutoDisposeProviderElement<GameLevelTerrainReference>
    with TerrainRef {
  _TerrainProviderElement(super.provider);

  @override
  String get id => (origin as TerrainProvider).id;
}

String _$gameLevelsHash() => r'358ddb1b77d57bfef0e8c4963717b20434b7f620';

/// Provide all the created game levels.
///
/// Copied from [gameLevels].
@ProviderFor(gameLevels)
final gameLevelsProvider =
    AutoDisposeProvider<List<GameLevelReference>>.internal(
  gameLevels,
  name: r'gameLevelsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$gameLevelsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GameLevelsRef = AutoDisposeProviderRef<List<GameLevelReference>>;
String _$gameLevelHash() => r'd968a4730ccc9e2377293e9ebfdc59df1ce1e0a1';

/// Provide a single game level reference with the given [id].
///
/// Copied from [gameLevel].
@ProviderFor(gameLevel)
const gameLevelProvider = GameLevelFamily();

/// Provide a single game level reference with the given [id].
///
/// Copied from [gameLevel].
class GameLevelFamily extends Family<GameLevelReference> {
  /// Provide a single game level reference with the given [id].
  ///
  /// Copied from [gameLevel].
  const GameLevelFamily();

  /// Provide a single game level reference with the given [id].
  ///
  /// Copied from [gameLevel].
  GameLevelProvider call(
    String id,
  ) {
    return GameLevelProvider(
      id,
    );
  }

  @override
  GameLevelProvider getProviderOverride(
    covariant GameLevelProvider provider,
  ) {
    return call(
      provider.id,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'gameLevelProvider';
}

/// Provide a single game level reference with the given [id].
///
/// Copied from [gameLevel].
class GameLevelProvider extends AutoDisposeProvider<GameLevelReference> {
  /// Provide a single game level reference with the given [id].
  ///
  /// Copied from [gameLevel].
  GameLevelProvider(
    String id,
  ) : this._internal(
          (ref) => gameLevel(
            ref as GameLevelRef,
            id,
          ),
          from: gameLevelProvider,
          name: r'gameLevelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$gameLevelHash,
          dependencies: GameLevelFamily._dependencies,
          allTransitiveDependencies: GameLevelFamily._allTransitiveDependencies,
          id: id,
        );

  GameLevelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    GameLevelReference Function(GameLevelRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GameLevelProvider._internal(
        (ref) => create(ref as GameLevelRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<GameLevelReference> createElement() {
    return _GameLevelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GameLevelProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GameLevelRef on AutoDisposeProviderRef<GameLevelReference> {
  /// The parameter `id` of this provider.
  String get id;
}

class _GameLevelProviderElement
    extends AutoDisposeProviderElement<GameLevelReference> with GameLevelRef {
  _GameLevelProviderElement(super.provider);

  @override
  String get id => (origin as GameLevelProvider).id;
}

String _$levelEditorContextHash() =>
    r'ec3e412c7c5b7f73f3db5d62e19b5b6bd5403676';

/// Ensure [levelEditorContextNotifierProvider] is not `null`.
///
/// Copied from [levelEditorContext].
@ProviderFor(levelEditorContext)
final levelEditorContextProvider =
    AutoDisposeProvider<LevelEditorContext>.internal(
  levelEditorContext,
  name: r'levelEditorContextProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$levelEditorContextHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LevelEditorContextRef = AutoDisposeProviderRef<LevelEditorContext>;
String _$footstepSoundsHash() => r'bb060f2902835928532d4a7b7226f6ceda286867';

/// Provide all the footstep sounds.
///
/// Copied from [footstepSounds].
@ProviderFor(footstepSounds)
final footstepSoundsProvider =
    AutoDisposeProvider<Map<String, List<String>>>.internal(
  footstepSounds,
  name: r'footstepSoundsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$footstepSoundsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FootstepSoundsRef = AutoDisposeProviderRef<Map<String, List<String>>>;
String _$levelEditorContextNotifierHash() =>
    r'f72b5374d29a9de17a91d16d8db179bc1472322c';

/// Provide a level editor context.
///
/// Copied from [LevelEditorContextNotifier].
@ProviderFor(LevelEditorContextNotifier)
final levelEditorContextNotifierProvider = AutoDisposeNotifierProvider<
    LevelEditorContextNotifier, LevelEditorContext?>.internal(
  LevelEditorContextNotifier.new,
  name: r'levelEditorContextNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$levelEditorContextNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LevelEditorContextNotifier = AutoDisposeNotifier<LevelEditorContext?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
