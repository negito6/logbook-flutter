import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:logbook/models/tag.dart';
import 'package:logbook/models/history.dart';

class Tags extends StatelessWidget {
  const Tags(
      {super.key,
      required this.database,
      required this.histories,
      required this.tags});

  final Database database;
  final List<History> histories;
  final List<Tag> tags;

  @override
  Widget build(BuildContext context) {
    var rows = <TableRow>[
      const TableRow(
        children: <Widget>[
          TableCell(
            child: Text("Tag"),
          ),
          TableCell(
            child: Text("Date"),
          ),
          TableCell(
            child: Text("Today"),
          ),
        ],
      )
    ];
    for (var category in Category.values) {
      rows.add(TableRow(
        children: <Widget>[
          TableCell(
            child: Text(category.label),
          ),
          const TableCell(
            child: Text("----"),
          ),
          const TableCell(
            child: Text("----"),
          ),
        ],
      ));

      final tagCategory = tags.where((tag) => tag.category == category.value);
      for (var tag in tagCategory) {
        final tagHistories =
            histories.where((history) => history.tagId == tag.id);
        rows.add(TableRow(
          children: <Widget>[
            TableCell(
              child: Text(tag.name),
            ),
            TableCell(
              child: Text(tagHistories.isEmpty
                  ? ""
                  : tagHistories.first.createdAt.toString()),
            ),
            const TableCell(
              child: Text("----"),
            ),
          ],
        ));
      }
    }

    return Table(
      border: TableBorder.all(),
      children: rows,
    );
  }
}
