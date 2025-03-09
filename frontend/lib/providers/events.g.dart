// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'events.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$eventsHash() => r'60c0a80e3f9fa0fb1c94417a25b06354a30b9666';

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

/// See also [events].
@ProviderFor(events)
const eventsProvider = EventsFamily();

/// See also [events].
class EventsFamily extends Family<AsyncValue<EventList>> {
  /// See also [events].
  const EventsFamily();

  /// See also [events].
  EventsProvider call(String groupId) {
    return EventsProvider(groupId);
  }

  @override
  EventsProvider getProviderOverride(covariant EventsProvider provider) {
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
  String? get name => r'eventsProvider';
}

/// See also [events].
class EventsProvider extends AutoDisposeFutureProvider<EventList> {
  /// See also [events].
  EventsProvider(String groupId)
    : this._internal(
        (ref) => events(ref as EventsRef, groupId),
        from: eventsProvider,
        name: r'eventsProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product') ? null : _$eventsHash,
        dependencies: EventsFamily._dependencies,
        allTransitiveDependencies: EventsFamily._allTransitiveDependencies,
        groupId: groupId,
      );

  EventsProvider._internal(
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
    FutureOr<EventList> Function(EventsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: EventsProvider._internal(
        (ref) => create(ref as EventsRef),
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
  AutoDisposeFutureProviderElement<EventList> createElement() {
    return _EventsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EventsProvider && other.groupId == groupId;
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
mixin EventsRef on AutoDisposeFutureProviderRef<EventList> {
  /// The parameter `groupId` of this provider.
  String get groupId;
}

class _EventsProviderElement extends AutoDisposeFutureProviderElement<EventList>
    with EventsRef {
  _EventsProviderElement(super.provider);

  @override
  String get groupId => (origin as EventsProvider).groupId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
