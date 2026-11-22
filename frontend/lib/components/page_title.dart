import 'package:material_ui/material_ui.dart';

/// Display は大きい画面向けの役割なので、狭い幅では Headline に下げる
const _largeWidth = 1200;

bool _isLarge(BuildContext context) =>
    MediaQuery.sizeOf(context).width >= _largeWidth;

class PageTitle extends StatelessWidget {
  final String text;

  const PageTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Text(
      text,
      style: _isLarge(context)
          ? textTheme.displayMedium
          : textTheme.headlineLarge,
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;

  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Text(
      text,
      style: _isLarge(context)
          ? textTheme.headlineMedium
          : textTheme.titleLarge,
    );
  }
}
