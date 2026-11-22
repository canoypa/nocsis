import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';
import 'package:nocsis/components/personal/basic_card.dart';
import 'package:nocsis/generated/api_client/api.models.swagger.dart';
import 'package:nocsis/extensions/schedule_title.dart';

class ClassListView extends StatelessWidget {
  final List<Class> items;

  const ClassListView({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const ListTile(title: Text("授業")),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: (items).map((data) {
              final String startAt = DateFormat("HH:mm")
                  .format(data.startAt.toLocal());
              final String endAt = DateFormat("HH:mm")
                  .format(data.endAt.toLocal());

              return BasicCard(
                primary: Text(data.shownTitle),
                secondary: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text("${data.period}限目"),
                    const SizedBox(width: 8),
                    Text("$startAt-$endAt"),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
