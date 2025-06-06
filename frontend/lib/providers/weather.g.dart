// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$weatherHash() => r'6b1df2d03d3441e86a74d7f90dfb260383d99fb1';

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

/// See also [weather].
@ProviderFor(weather)
const weatherProvider = WeatherFamily();

/// See also [weather].
class WeatherFamily extends Family<AsyncValue<Weather>> {
  /// See also [weather].
  const WeatherFamily();

  /// See also [weather].
  WeatherProvider call(String groupId) {
    return WeatherProvider(groupId);
  }

  @override
  WeatherProvider getProviderOverride(covariant WeatherProvider provider) {
    return call(provider.groupId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'weatherProvider';
}

/// See also [weather].
class WeatherProvider extends AutoDisposeFutureProvider<Weather> {
  /// See also [weather].
  WeatherProvider(String groupId)
    : this._internal(
        (ref) => weather(ref as WeatherRef, groupId),
        from: weatherProvider,
        name: r'weatherProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$weatherHash,
        dependencies: WeatherFamily._dependencies,
        allTransitiveDependencies: WeatherFamily._allTransitiveDependencies,
        groupId: groupId,
      );

  WeatherProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.groupId,
  }) : super.internal();

  final String groupId;

  @override
  Override overrideWith(
    FutureOr<Weather> Function(WeatherRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: WeatherProvider._internal(
        (ref) => create(ref as WeatherRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        groupId: groupId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Weather> createElement() {
    return _WeatherProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WeatherProvider && other.groupId == groupId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, groupId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin WeatherRef on AutoDisposeFutureProviderRef<Weather> {
  /// The parameter `groupId` of this provider.
  String get groupId;
}

class _WeatherProviderElement extends AutoDisposeFutureProviderElement<Weather>
    with WeatherRef {
  _WeatherProviderElement(super.provider);

  @override
  String get groupId => (origin as WeatherProvider).groupId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
