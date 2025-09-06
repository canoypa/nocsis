import 'package:flutter/material.dart';
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
              // FIXME: swagger-dart-code-generator の制限により anyOf が dynamic 型になってしまうので、変換をかける
              final DateTime? startDate = data.startAt is String
                  ? DateTime.tryParse(data.startAt as String)
                  : data.startAt is DateTime
                  ? data.startAt as DateTime
                  : null;

              final String dateText = startDate != null
                  ? DateFormat("M月d日").format(startDate)
                  : "日時不明";

              return BasicCard(
                primary: Text(data.title),
                secondary: Text(dateText),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
