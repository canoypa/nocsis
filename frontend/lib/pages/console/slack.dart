import 'package:material_ui/material_ui.dart';
import 'package:nocsis/components/page_title.dart';

class ConsoleSlackPage extends StatelessWidget {
  const ConsoleSlackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageTitle('Slack 連携'),
            const SizedBox(height: 24),
            const Text('Slack への各種通知メッセージの送信を管理します。'),
            const SizedBox(height: 48),
            const SectionTitle('トークン'),
            const SizedBox(height: 24),
            TextField(
              controller: TextEditingController(text: 'WIP'),
              enabled: false,
              decoration: const InputDecoration(
                constraints: BoxConstraints(maxWidth: 800),
                border: OutlineInputBorder(),
                labelText: 'トークン',
              ),
            ),
            const SizedBox(height: 48),
            const SectionTitle('イベント通知'),
            const SizedBox(height: 24),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('イベント通知を受け取る'),
                Switch(value: true, onChanged: null),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: TextEditingController(text: 'WIP'),
              enabled: false,
              decoration: const InputDecoration(
                constraints: BoxConstraints(maxWidth: 800),
                border: OutlineInputBorder(),
                labelText: '通知時刻',
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: TextEditingController(text: 'WIP'),
              enabled: false,
              decoration: const InputDecoration(
                constraints: BoxConstraints(maxWidth: 800),
                border: OutlineInputBorder(),
                labelText: '通知するチャンネル',
              ),
            ),
            const SizedBox(height: 48),
            const SectionTitle('日直通知'),
            const SizedBox(height: 24),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('日直通知を受け取る'),
                Switch(value: true, onChanged: null),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: TextEditingController(text: 'WIP'),
              enabled: false,
              decoration: const InputDecoration(
                constraints: BoxConstraints(maxWidth: 800),
                border: OutlineInputBorder(),
                labelText: '通知時刻',
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: TextEditingController(text: 'WIP'),
              enabled: false,
              decoration: const InputDecoration(
                constraints: BoxConstraints(maxWidth: 800),
                border: OutlineInputBorder(),
                labelText: '通知するチャンネル',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
