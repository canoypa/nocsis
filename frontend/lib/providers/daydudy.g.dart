// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daydudy.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$daydudyHash() => r'6bd0bc476c0c37b9749b94894b4925560d51c68a';

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

/// See also [daydudy].
@ProviderFor(daydudy)
const daydudyProvider = DaydudyFamily();

/// See also [daydudy].
class DaydudyFamily extends Family<AsyncValue<Daydudy>> {
  /// See also [daydudy].
  const DaydudyFamily();

  /// See also [daydudy].
  DaydudyProvider call(String groupId) {
    return DaydudyProvider(groupId);
  }

  @override
  DaydudyProvider getProviderOverride(covariant DaydudyProvider provider) {
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
  String? get name => r'daydudyProvider';
}

/// See also [daydudy].
class DaydudyProvider extends AutoDisposeFutureProvider<Daydudy> {
  /// See also [daydudy].
  DaydudyProvider(String groupId)
    : this._internal(
        (ref) => daydudy(ref as DaydudyRef, groupId),
        from: daydudyProvider,
        name: r'daydudyProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$daydudyHash,
        dependencies: DaydudyFamily._dependencies,
        allTransitiveDependencies: DaydudyFamily._allTransitiveDependencies,
        groupId: groupId,
      );

  DaydudyProvider._internal(
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
    FutureOr<Daydudy> Function(DaydudyRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DaydudyProvider._internal(
        (ref) => create(ref as DaydudyRef),
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
  AutoDisposeFutureProviderElement<Daydudy> createElement() {
    return _DaydudyProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DaydudyProvider && other.groupId == groupId;
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
mixin DaydudyRef on AutoDisposeFutureProviderRef<Daydudy> {
  /// The parameter `groupId` of this provider.
  String get groupId;
}

class _DaydudyProviderElement extends AutoDisposeFutureProviderElement<Daydudy>
    with DaydudyRef {
  _DaydudyProviderElement(super.provider);

  @override
  String get groupId => (origin as DaydudyProvider).groupId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
