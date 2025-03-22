// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'during_class_data.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$duringClassDataHash() => r'c4836d5ec1ada945661d6f3c3cdf01f998b8ab2b';

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

/// See also [duringClassData].
@ProviderFor(duringClassData)
const duringClassDataProvider = DuringClassDataFamily();

/// See also [duringClassData].
class DuringClassDataFamily extends Family<AsyncValue<ClassData?>> {
  /// See also [duringClassData].
  const DuringClassDataFamily();

  /// See also [duringClassData].
  DuringClassDataProvider call(String groupId) {
    return DuringClassDataProvider(groupId);
  }

  @override
  DuringClassDataProvider getProviderOverride(
    covariant DuringClassDataProvider provider,
  ) {
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
  String? get name => r'duringClassDataProvider';
}

/// See also [duringClassData].
class DuringClassDataProvider extends AutoDisposeFutureProvider<ClassData?> {
  /// See also [duringClassData].
  DuringClassDataProvider(String groupId)
    : this._internal(
        (ref) => duringClassData(ref as DuringClassDataRef, groupId),
        from: duringClassDataProvider,
        name: r'duringClassDataProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$duringClassDataHash,
        dependencies: DuringClassDataFamily._dependencies,
        allTransitiveDependencies:
            DuringClassDataFamily._allTransitiveDependencies,
        groupId: groupId,
      );

  DuringClassDataProvider._internal(
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
    FutureOr<ClassData?> Function(DuringClassDataRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DuringClassDataProvider._internal(
        (ref) => create(ref as DuringClassDataRef),
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
  AutoDisposeFutureProviderElement<ClassData?> createElement() {
    return _DuringClassDataProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DuringClassDataProvider && other.groupId == groupId;
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
mixin DuringClassDataRef on AutoDisposeFutureProviderRef<ClassData?> {
  /// The parameter `groupId` of this provider.
  String get groupId;
}

class _DuringClassDataProviderElement
    extends AutoDisposeFutureProviderElement<ClassData?>
    with DuringClassDataRef {
  _DuringClassDataProviderElement(super.provider);

  @override
  String get groupId => (origin as DuringClassDataProvider).groupId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
