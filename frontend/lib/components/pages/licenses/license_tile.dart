import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LicenseTile extends StatelessWidget {
  final String packageName;
  final List<LicenseParagraph> paragraphs;

  const LicenseTile({
    super.key,
    required this.packageName,
    required this.paragraphs,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(packageName, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Theme.of(context).colorScheme.surfaceContainerLow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: paragraphs.map((paragraph) {
              if (paragraph.indent == LicenseParagraph.centeredIndent) {
                return Center(
                  child: Text(
                    paragraph.text,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              } else {
                return Padding(
                  padding: EdgeInsetsDirectional.only(
                    start: 16.0 * paragraph.indent,
                  ),
                  child: Text(
                    paragraph.text,
                    style: Theme.of(context).textTheme.bodySmall,
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
