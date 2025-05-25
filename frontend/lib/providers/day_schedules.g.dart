// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'day_schedules.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$daySchedulesHash() => r'52f509f8446b41bb7d33a351a27dca9a885fee32';

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

/// See also [daySchedules].
@ProviderFor(daySchedules)
const daySchedulesProvider = DaySchedulesFamily();

/// See also [daySchedules].
class DaySchedulesFamily extends Family<AsyncValue<DaySchedules>> {
  /// See also [daySchedules].
  const DaySchedulesFamily();

  /// See also [daySchedules].
  DaySchedulesProvider call(String groupId, int epochDay) {
    return DaySchedulesProvider(groupId, epochDay);
  }

  @override
  DaySchedulesProvider getProviderOverride(
    covariant DaySchedulesProvider provider,
  ) {
    return call(provider.groupId, provider.epochDay);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'daySchedulesProvider';
}

/// See also [daySchedules].
class DaySchedulesProvider extends AutoDisposeFutureProvider<DaySchedules> {
  /// See also [daySchedules].
  DaySchedulesProvider(String groupId, int epochDay)
    : this._internal(
        (ref) => daySchedules(ref as DaySchedulesRef, groupId, epochDay),
        from: daySchedulesProvider,
        name: r'daySchedulesProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$daySchedulesHash,
        dependencies: DaySchedulesFamily._dependencies,
        allTransitiveDependencies:
            DaySchedulesFamily._allTransitiveDependencies,
        groupId: groupId,
        epochDay: epochDay,
      );

  DaySchedulesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.groupId,
    required this.epochDay,
  }) : super.internal();

  final String groupId;
  final int epochDay;

  @override
  Override overrideWith(
    FutureOr<DaySchedules> Function(DaySchedulesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DaySchedulesProvider._internal(
        (ref) => create(ref as DaySchedulesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        groupId: groupId,
        epochDay: epochDay,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<DaySchedules> createElement() {
    return _DaySchedulesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DaySchedulesProvider &&
        other.groupId == groupId &&
        other.epochDay == epochDay;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, groupId.hashCode);
    hash = _SystemHash.combine(hash, epochDay.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DaySchedulesRef on AutoDisposeFutureProviderRef<DaySchedules> {
  /// The parameter `groupId` of this provider.
  String get groupId;

  /// The parameter `epochDay` of this provider.
  int get epochDay;
}

class _DaySchedulesProviderElement
    extends AutoDisposeFutureProviderElement<DaySchedules>
    with DaySchedulesRef {
  _DaySchedulesProviderElement(super.provider);

  @override
  String get groupId => (origin as DaySchedulesProvider).groupId;
  @override
  int get epochDay => (origin as DaySchedulesProvider).epochDay;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
