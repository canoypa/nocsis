import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nocsis_personal/models/calendar_class/calendar_class.dart';
import 'package:nocsis_personal/widget/basic_card.dart';

class ClassList extends StatelessWidget {
  final List<CalendarClass> items;

  const ClassList({
    super.key,
    required this.items,
  });

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
              final String startAt = DateFormat("HH:mm").format(data.startAt);
              final String endAt = DateFormat("HH:mm").format(data.endAt);

              return BasicCard(
                primary: Text(data.title),
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
