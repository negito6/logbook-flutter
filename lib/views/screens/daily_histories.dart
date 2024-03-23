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
              child: Text("Value"),
            ),
            TableCell(
              child: Text("Desc"),
            ),
          ],
        ),
        ...tags
            .map((tag) => TableRow(
                  children: <Widget>[
                    TableCell(
                      child: Text(tag.name),
                    ),
                    TableCell(
                      child: Text(tag.label()),
                    ),
                    TableCell(
                      child: Text(tag.label()),
                    ),
                    TableCell(
                      child: Text(tag.label()),
                    ),
                  ],
                ))
            .toList(),
      ],
    );
  }
}
