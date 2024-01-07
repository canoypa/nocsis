// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cron.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$cronHash() => r'd0f1374b7f8e234e59a4c6ab7e13b4b4e630c4f1';

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

/// See also [cron].
@ProviderFor(cron)
const cronProvider = CronFamily();

/// See also [cron].
class CronFamily extends Family<AsyncValue<DateTime>> {
  /// See also [cron].
  const CronFamily();

  /// See also [cron].
  CronProvider call(
    String cronFormat,
  ) {
    return CronProvider(
      cronFormat,
    );
  }

  @override
  CronProvider getProviderOverride(
    covariant CronProvider provider,
  ) {
    return call(
      provider.cronFormat,
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
  String? get name => r'cronProvider';
}

/// See also [cron].
class CronProvider extends AutoDisposeStreamProvider<DateTime> {
  /// See also [cron].
  CronProvider(
    String cronFormat,
  ) : this._internal(
          (ref) => cron(
            ref as CronRef,
            cronFormat,
          ),
          from: cronProvider,
          name: r'cronProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product') ? null : _$cronHash,
          dependencies: CronFamily._dependencies,
          allTransitiveDependencies: CronFamily._allTransitiveDependencies,
          cronFormat: cronFormat,
        );

  CronProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.cronFormat,
  }) : super.internal();

  final String cronFormat;

  @override
  Override overrideWith(
    Stream<DateTime> Function(CronRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CronProvider._internal(
        (ref) => create(ref as CronRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        cronFormat: cronFormat,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<DateTime> createElement() {
    return _CronProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CronProvider && other.cronFormat == cronFormat;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, cronFormat.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin CronRef on AutoDisposeStreamProviderRef<DateTime> {
  /// The parameter `cronFormat` of this provider.
  String get cronFormat;
}

class _CronProviderElement extends AutoDisposeStreamProviderElement<DateTime>
    with CronRef {
  _CronProviderElement(super.provider);

  @override
  String get cronFormat => (origin as CronProvider).cronFormat;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
