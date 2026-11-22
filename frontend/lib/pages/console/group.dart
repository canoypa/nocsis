import 'package:material_ui/material_ui.dart';
import 'package:nocsis/components/page_title.dart';

class ConsoleGroupPage extends StatelessWidget {
  const ConsoleGroupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageTitle('グループ'),
            const SizedBox(height: 24),
            const Text('グループに関する情報を管理します。'),
            const SizedBox(height: 48),
            TextField(
              controller: TextEditingController(text: 'WIP'),
              enabled: false,
              decoration: const InputDecoration(
                constraints: BoxConstraints(maxWidth: 800),
                border: OutlineInputBorder(),
                labelText: 'グループ名',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
