import 'package:material_ui/material_ui.dart';
import 'package:nocsis/components/skeleton.dart';

class BasicCard extends StatelessWidget {
  final Widget primary;
  final Widget secondary;

  const BasicCard({super.key, required this.primary, required this.secondary});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: ListTile(title: primary, subtitle: secondary),
      ),
    );
  }
}

/// 読み込み中の [BasicCard] の並び。中身の数は分からないので 3 枚出す
class BasicCardListSkeleton extends StatelessWidget {
  const BasicCardListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeleton(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final width in [80.0, 64.0, 72.0])
            BasicCard(
              primary: Align(
                alignment: Alignment.centerLeft,
                child: SkeletonBlock(width: width, height: 16),
              ),
              secondary: const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: SkeletonBlock(width: 140),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
