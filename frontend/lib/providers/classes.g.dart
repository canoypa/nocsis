// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'classes.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$classesHash() => r'2b6a8580ae31c5d782b65264a3ccaa24194dbff4';

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

/// See also [classes].
@ProviderFor(classes)
const classesProvider = ClassesFamily();

/// See also [classes].
class ClassesFamily extends Family<AsyncValue<ClassList>> {
  /// See also [classes].
  const ClassesFamily();

  /// See also [classes].
  ClassesProvider call(String groupId) {
    return ClassesProvider(groupId);
  }

  @override
  ClassesProvider getProviderOverride(covariant ClassesProvider provider) {
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
  String? get name => r'classesProvider';
}

/// See also [classes].
class ClassesProvider extends AutoDisposeFutureProvider<ClassList> {
  /// See also [classes].
  ClassesProvider(String groupId)
    : this._internal(
        (ref) => classes(ref as ClassesRef, groupId),
        from: classesProvider,
        name: r'classesProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$classesHash,
        dependencies: ClassesFamily._dependencies,
        allTransitiveDependencies: ClassesFamily._allTransitiveDependencies,
        groupId: groupId,
      );

  ClassesProvider._internal(
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
    FutureOr<ClassList> Function(ClassesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ClassesProvider._internal(
        (ref) => create(ref as ClassesRef),
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
  AutoDisposeFutureProviderElement<ClassList> createElement() {
    return _ClassesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ClassesProvider && other.groupId == groupId;
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
mixin ClassesRef on AutoDisposeFutureProviderRef<ClassList> {
  /// The parameter `groupId` of this provider.
  String get groupId;
}

class _ClassesProviderElement
    extends AutoDisposeFutureProviderElement<ClassList>
    with ClassesRef {
  _ClassesProviderElement(super.provider);

  @override
  String get groupId => (origin as ClassesProvider).groupId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
