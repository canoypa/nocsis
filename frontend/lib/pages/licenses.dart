import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'licenses.g.dart';

@riverpod
Future<Map<String, List<LicenseParagraph>>> licenses(ref) async {
  final licensesEntries = await LicenseRegistry.licenses.toList();

  Map<String, List<LicenseParagraph>> licenses = {};

  for (final license in licensesEntries) {
    for (final package in license.packages) {
      licenses.putIfAbsent(package, () => []).addAll(license.paragraphs);
    }
  }

  return licenses;
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
              onPressed: () {},
            ),
            // title: const Text('ライセンス'),
            centerTitle: false,
            flexibleSpace: const FlexibleSpaceBar(
              title: Text('ライセンス'),
              centerTitle: false,
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 48),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: snapshot.when(
              data: (licenses) {
                return SliverList.separated(
                  itemCount: licenses.length,
                  itemBuilder: (context, index) {
                    final entry = licenses.entries.elementAt(index);
                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: Package(entry: entry),
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
              loading: () => const SliverToBoxAdapter(
                child: SizedBox(),
              ),
              error: (error, stackTrace) => SliverToBoxAdapter(
                child: Text('Error: $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Package extends StatelessWidget {
  const Package({
    super.key,
    required this.entry,
  });

  final MapEntry<String, List<LicenseParagraph>> entry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          entry.key,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Theme.of(context).colorScheme.surfaceContainerLow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: entry.value.map((paragraph) {
              if (paragraph.indent == LicenseParagraph.centeredIndent) {
                return Center(
                  child: Text(paragraph.text),
                );
              } else {
                return Padding(
                  padding: EdgeInsetsDirectional.only(
                    start: 16.0 * paragraph.indent,
                  ),
                  child: Text(
                    paragraph.text,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                );
              }
            }).toList(),
          ),
        ),
      ],
    );
  }
}
