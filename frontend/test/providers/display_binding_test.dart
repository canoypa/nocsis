import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nocsis/providers/display_binding.dart';
import 'package:nocsis/providers/firebase.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late ProviderContainer container;

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    await firestore.collection('role_bindings').doc('b1').set({
      'subject': 'user:device',
      'role': 'roles/group.display',
      'resource': 'group:g1',
    });
    container = ProviderContainer(
      overrides: [firestoreProvider.overrideWithValue(firestore)],
    );
    addTearDown(container.dispose);
  });

  test('付与が消えたら false が届く', () async {
    final provider = displayBoundProvider('device', 'g1');
    final values = <bool>[];
    container.listen(provider, (_, next) {
      if (next.hasValue) values.add(next.requireValue);
    });

    await container.read(provider.future);
    await firestore.collection('role_bindings').doc('b1').delete();
    await pumpEventQueue();

    expect(values, [true, false]);
  });

  test('ほかのグループの付与だけなら false', () async {
    final provider = displayBoundProvider('device', 'g2');
    container.listen(provider, (_, _) {});

    expect(await container.read(provider.future), isFalse);
  });
}
