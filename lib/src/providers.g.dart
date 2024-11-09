// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$terrainsHash() => r'bb847655f1d882756fcf8cc97017b40fe0f250b1';

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

/// Provide the terrains from [filename].
///
/// Copied from [terrains].
@ProviderFor(terrains)
const terrainsProvider = TerrainsFamily();

/// Provide the terrains from [filename].
///
/// Copied from [terrains].
class TerrainsFamily extends Family<List<GameLevelTerrainReference>> {
  /// Provide the terrains from [filename].
  ///
  /// Copied from [terrains].
  const TerrainsFamily();

  /// Provide the terrains from [filename].
  ///
  /// Copied from [terrains].
  TerrainsProvider call(
    String filename,
  ) {
    return TerrainsProvider(
      filename,
    );
  }

  @override
  TerrainsProvider getProviderOverride(
    covariant TerrainsProvider provider,
  ) {
    return call(
      provider.filename,
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
  String? get name => r'terrainsProvider';
}

/// Provide the terrains from [filename].
///
/// Copied from [terrains].
class TerrainsProvider
    extends AutoDisposeProvider<List<GameLevelTerrainReference>> {
  /// Provide the terrains from [filename].
  ///
  /// Copied from [terrains].
  TerrainsProvider(
    String filename,
  ) : this._internal(
          (ref) => terrains(
            ref as TerrainsRef,
            filename,
          ),
          from: terrainsProvider,
          name: r'terrainsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$terrainsHash,
          dependencies: TerrainsFamily._dependencies,
          allTransitiveDependencies: TerrainsFamily._allTransitiveDependencies,
          filename: filename,
        );

  TerrainsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.filename,
  }) : super.internal();

  final String filename;

  @override
  Override overrideWith(
    List<GameLevelTerrainReference> Function(TerrainsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TerrainsProvider._internal(
        (ref) => create(ref as TerrainsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        filename: filename,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<List<GameLevelTerrainReference>> createElement() {
    return _TerrainsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TerrainsProvider && other.filename == filename;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, filename.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TerrainsRef on AutoDisposeProviderRef<List<GameLevelTerrainReference>> {
  /// The parameter `filename` of this provider.
  String get filename;
}

class _TerrainsProviderElement
    extends AutoDisposeProviderElement<List<GameLevelTerrainReference>>
    with TerrainsRef {
  _TerrainsProviderElement(super.provider);

  @override
  String get filename => (origin as TerrainsProvider).filename;
}

String _$terrainHash() => r'3a473b9737d5a1083e316cb670402e529d39d747';

/// Provide a single terrain with the given [id] from the terrains file at
/// [filename].
///
/// Copied from [terrain].
@ProviderFor(terrain)
const terrainProvider = TerrainFamily();

/// Provide a single terrain with the given [id] from the terrains file at
/// [filename].
///
/// Copied from [terrain].
class TerrainFamily extends Family<GameLevelTerrainReference> {
  /// Provide a single terrain with the given [id] from the terrains file at
  /// [filename].
  ///
  /// Copied from [terrain].
  const TerrainFamily();

  /// Provide a single terrain with the given [id] from the terrains file at
  /// [filename].
  ///
  /// Copied from [terrain].
  TerrainProvider call(
    String filename,
    String id,
  ) {
    return TerrainProvider(
      filename,
      id,
    );
  }

  @override
  TerrainProvider getProviderOverride(
    covariant TerrainProvider provider,
  ) {
    return call(
      provider.filename,
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

/// Provide a single terrain with the given [id] from the terrains file at
/// [filename].
///
/// Copied from [terrain].
class TerrainProvider extends AutoDisposeProvider<GameLevelTerrainReference> {
  /// Provide a single terrain with the given [id] from the terrains file at
  /// [filename].
  ///
  /// Copied from [terrain].
  TerrainProvider(
    String filename,
    String id,
  ) : this._internal(
          (ref) => terrain(
            ref as TerrainRef,
            filename,
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
          filename: filename,
          id: id,
        );

  TerrainProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.filename,
    required this.id,
  }) : super.internal();

  final String filename;
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
        filename: filename,
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
    return other is TerrainProvider &&
        other.filename == filename &&
        other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, filename.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TerrainRef on AutoDisposeProviderRef<GameLevelTerrainReference> {
  /// The parameter `filename` of this provider.
  String get filename;

  /// The parameter `id` of this provider.
  String get id;
}

class _TerrainProviderElement
    extends AutoDisposeProviderElement<GameLevelTerrainReference>
    with TerrainRef {
  _TerrainProviderElement(super.provider);

  @override
  String get filename => (origin as TerrainProvider).filename;
  @override
  String get id => (origin as TerrainProvider).id;
}

String _$gameLevelsHash() => r'c541b7ab4614aba461673d6cbba557cd19c96675';

/// Provide all game levels loaded from the directory at [path].
///
/// Copied from [gameLevels].
@ProviderFor(gameLevels)
const gameLevelsProvider = GameLevelsFamily();

/// Provide all game levels loaded from the directory at [path].
///
/// Copied from [gameLevels].
class GameLevelsFamily extends Family<List<GameLevelReference>> {
  /// Provide all game levels loaded from the directory at [path].
  ///
  /// Copied from [gameLevels].
  const GameLevelsFamily();

  /// Provide all game levels loaded from the directory at [path].
  ///
  /// Copied from [gameLevels].
  GameLevelsProvider call(
    String path,
  ) {
    return GameLevelsProvider(
      path,
    );
  }

  @override
  GameLevelsProvider getProviderOverride(
    covariant GameLevelsProvider provider,
  ) {
    return call(
      provider.path,
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
  String? get name => r'gameLevelsProvider';
}

/// Provide all game levels loaded from the directory at [path].
///
/// Copied from [gameLevels].
class GameLevelsProvider extends AutoDisposeProvider<List<GameLevelReference>> {
  /// Provide all game levels loaded from the directory at [path].
  ///
  /// Copied from [gameLevels].
  GameLevelsProvider(
    String path,
  ) : this._internal(
          (ref) => gameLevels(
            ref as GameLevelsRef,
            path,
          ),
          from: gameLevelsProvider,
          name: r'gameLevelsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$gameLevelsHash,
          dependencies: GameLevelsFamily._dependencies,
          allTransitiveDependencies:
              GameLevelsFamily._allTransitiveDependencies,
          path: path,
        );

  GameLevelsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.path,
  }) : super.internal();

  final String path;

  @override
  Override overrideWith(
    List<GameLevelReference> Function(GameLevelsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GameLevelsProvider._internal(
        (ref) => create(ref as GameLevelsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        path: path,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<List<GameLevelReference>> createElement() {
    return _GameLevelsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GameLevelsProvider && other.path == path;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, path.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GameLevelsRef on AutoDisposeProviderRef<List<GameLevelReference>> {
  /// The parameter `path` of this provider.
  String get path;
}

class _GameLevelsProviderElement
    extends AutoDisposeProviderElement<List<GameLevelReference>>
    with GameLevelsRef {
  _GameLevelsProviderElement(super.provider);

  @override
  String get path => (origin as GameLevelsProvider).path;
}

String _$gameLevelHash() => r'7295e0466dcbf62bca1cc77d51ecf6c200b35b35';

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
    String path,
    String id,
  ) {
    return GameLevelProvider(
      path,
      id,
    );
  }

  @override
  GameLevelProvider getProviderOverride(
    covariant GameLevelProvider provider,
  ) {
    return call(
      provider.path,
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
    String path,
    String id,
  ) : this._internal(
          (ref) => gameLevel(
            ref as GameLevelRef,
            path,
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
          path: path,
          id: id,
        );

  GameLevelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.path,
    required this.id,
  }) : super.internal();

  final String path;
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
        path: path,
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
    return other is GameLevelProvider && other.path == path && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, path.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GameLevelRef on AutoDisposeProviderRef<GameLevelReference> {
  /// The parameter `path` of this provider.
  String get path;

  /// The parameter `id` of this provider.
  String get id;
}

class _GameLevelProviderElement
    extends AutoDisposeProviderElement<GameLevelReference> with GameLevelRef {
  _GameLevelProviderElement(super.provider);

  @override
  String get path => (origin as GameLevelProvider).path;
  @override
  String get id => (origin as GameLevelProvider).id;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
