import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nocsis/providers/daydudy.dart';
import 'package:nocsis/providers/current_group_id.dart';

class Daydudy extends ConsumerWidget {
  const Daydudy({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupId = ref.watch(currentGroupIdProvider);
    final daydudy = ref
        .watch(daydudyProvider(groupId))
        .maybeWhen(data: (data) => data, orElse: () => null);

    if (daydudy == null) {
      return const SizedBox();
    }

    return Row(
      children: [
        Icon(Icons.person_pin_outlined, size: 48.sp),
        const SizedBox(width: 8),
        Text(daydudy.name, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}
