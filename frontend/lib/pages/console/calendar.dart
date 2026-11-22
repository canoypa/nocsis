import 'package:material_ui/material_ui.dart';
import 'package:nocsis/components/page_title.dart';

class ConsoleCalendarPage extends StatelessWidget {
  const ConsoleCalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageTitle('カレンダー'),
            const SizedBox(height: 24),
            const Text('授業とイベントを管理します。'),
            const SizedBox(height: 48),
            const SectionTitle('Google カレンダーへのアクセス設定'),
            const SizedBox(height: 24),
            const Text(
              'Nocsis がカレンダーにアクセスして授業/イベントを取得できるようにするために、以下のサービスアカウントを対象の Google カレンダーに追加してください。',
            ),
            const SizedBox(height: 24),
            TextField(
              controller: TextEditingController(text: 'WIP'),
              enabled: false,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'サービスアカウント',
              ),
            ),
            const SizedBox(height: 48),
            const SectionTitle('授業'),
            const SizedBox(height: 24),
            const Text('授業を管理している Google カレンダーの ID を入力してください。'),
            const SizedBox(height: 24),
            TextField(
              controller: TextEditingController(text: 'WIP'),
              enabled: false,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'カレンダー ID',
              ),
            ),
            const SizedBox(height: 48),
            const SectionTitle('イベント'),
            const SizedBox(height: 24),
            const Text('イベントを管理している Google カレンダーの ID を入力してください。'),
            const SizedBox(height: 24),
            TextField(
              controller: TextEditingController(text: 'WIP'),
              enabled: false,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'カレンダー ID',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
