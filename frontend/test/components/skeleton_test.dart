import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nocsis/components/skeleton.dart';

void main() {
  testWidgets('動きを減らす設定のときは、明滅させない', (tester) async {
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Skeleton(child: SkeletonBlock(width: 100)),
        ),
      ),
    );

    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('ふだんは明滅させる', (tester) async {
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Skeleton(child: SkeletonBlock(width: 100)),
        ),
      ),
    );

    expect(tester.hasRunningAnimations, isTrue);
  });
}
