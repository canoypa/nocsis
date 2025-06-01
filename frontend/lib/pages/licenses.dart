import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nocsis/components/pages/licenses/license_tile.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'licenses.g.dart';

@riverpod
Stream<Map<String, List<LicenseParagraph>>> licenses(_) async* {
  Map<String, List<LicenseParagraph>> licenses = {};

  await for (final entry in LicenseRegistry.licenses) {
    for (final package in entry.packages) {
      licenses.putIfAbsent(package, () => []).addAll(entry.paragraphs);
    }

    yield licenses;
  }
}

class LicensesPage extends ConsumerWidget {
  const LicensesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(licensesProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  GoRouter.of(context).go('/');
                }
              },
            ),
            centerTitle: false,
            flexibleSpace: const FlexibleSpaceBar(
              title: Text('ライセンス'),
              centerTitle: false,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 48)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: snapshot.when(
              data: (licenses) {
                return SliverList.separated(
                  itemCount: licenses.length,
                  itemBuilder: (context, i) {
                    final entry = licenses.entries.elementAt(i);
                    final packageName = entry.key;
                    final paragraphs = entry.value;

                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: LicenseTile(
                          packageName: packageName,
                          paragraphs: paragraphs,
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: const Divider(height: 48 * 2),
                      ),
                    );
                  },
                );
              },
              loading: () => const SliverToBoxAdapter(child: SizedBox()),
              error:
                  (error, stackTrace) =>
                      SliverToBoxAdapter(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }
}
