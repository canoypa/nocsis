import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';
import 'package:nocsis/components/personal/basic_card.dart';
import 'package:nocsis/generated/api_client/api.models.swagger.dart';

class EventListView extends StatelessWidget {
  final List<Event> items;

  const EventListView({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const ListTile(title: Text("イベント")),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: (items).map((data) {
              // FIXME: swagger-dart-code-generator の制限により anyOf が dynamic 型になってしまうので、String として扱う
              final startDate = DateTime.parse(data.startAt as String)
                  .toLocal();

              return BasicCard(
                primary: Text(data.title),
                secondary: Text(DateFormat("M月d日").format(startDate)),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
