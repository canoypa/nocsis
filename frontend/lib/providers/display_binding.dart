import 'package:nocsis/providers/firebase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'display_binding.g.dart';

/// 端末にそのグループの付与が残っているか。登録が解除されると false が届く
@riverpod
Stream<bool> displayBound(Ref ref, String uid, String groupId) {
  return ref
      .watch(firestoreProvider)
      .collection('role_bindings')
      .where('subject', isEqualTo: 'user:$uid')
      .snapshots()
      // 手元の写しだけでは、まだ届いていない付与を「無い」と取り違える
      .where((snapshot) => !snapshot.metadata.isFromCache)
      .map(
        (snapshot) => snapshot.docs.any(
          (doc) => doc.data()['resource'] == 'group:$groupId',
        ),
      );
}
