import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

Uri _displayUrl() => Uri(
  scheme: Uri.base.scheme,
  host: Uri.base.host,
  port: Uri.base.hasPort ? Uri.base.port : null,
  path: '/display',
);

class DisplayUrlField extends StatefulWidget {
  const DisplayUrlField({super.key});

  @override
  State<DisplayUrlField> createState() => _DisplayUrlFieldState();
}

class _DisplayUrlFieldState extends State<DisplayUrlField> {
  final _controller = TextEditingController(text: _displayUrl().toString());

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 480),
      child: TextField(
        controller: _controller,
        readOnly: true,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          isDense: true,
          suffixIcon: IconButton(
            tooltip: 'URL をコピー',
            onPressed: () => _copyDisplayUrl(context),
            icon: const Icon(Symbols.content_copy),
          ),
        ),
      ),
    );
  }
}

Future<void> _copyDisplayUrl(BuildContext context) async {
  await Clipboard.setData(ClipboardData(text: _displayUrl().toString()));
  if (!context.mounted) return;

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(const SnackBar(content: Text('URL をコピーしました')));
}
