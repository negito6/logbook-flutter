import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:logbook/models/history.dart';
import 'package:logbook/models/tag.dart';

class DailyHistories extends StatelessWidget {
  const DailyHistories(
      {super.key,
      required this.database,
      required this.histories,
      required this.tags});

  final Database database;
  final List<History> histories;
  final List<Tag> tags;

  @override
  Widget build(BuildContext context) {
    var rows = <TableRow>[];
    for (var tag in tags) {
      final tagHistories = histories.where((value) => value.tagId == tag.id);

      final cells = <TableCell>[
        TableCell(
          child: Text(tag.name),
        ),
        TableCell(
          child: Text(tag.label()),
        )
      ];

      if (tagHistories.isEmpty) {
        rows.add(TableRow(
          children: <Widget>[
            ...cells,
            const TableCell(
              child: Text(""),
            ),
            const TableCell(
              child: Text(""),
            ),
          ],
        ));
      } else {
        for (var history in tagHistories) {
          rows.add(TableRow(
            children: <Widget>[
              ...cells,
              TableCell(
                child: Text(history.description),
              ),
              TableCell(
                child: Text(history.value.toString()),
              ),
            ],
          ));
        }
      }
    }

    return Table(
      border: TableBorder.all(),
      children: <TableRow>[
        const TableRow(
          children: <Widget>[
            TableCell(
              child: Text("Name"),
            ),
            TableCell(
              child: Text("Category"),
            ),
            TableCell(
              child: Text("Desc"),
            ),
            TableCell(
              child: Text("Value"),
            ),
          ],
        ),
        ...rows,
      ],
    );
  }
}
