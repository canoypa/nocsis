import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nocsis/components/personal/basic_card.dart';
import 'package:nocsis/models/events.dart';

class EventListView extends StatelessWidget {
  final List<EventData> items;

  const EventListView({
    super.key,
    required this.items,
  });

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
              return BasicCard(
                primary: Text(data.title),
                secondary: Text(DateFormat("M月d日").format(data.startAt)),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
