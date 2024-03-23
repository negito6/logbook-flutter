import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:logbook/models/tag.dart';

class Tags extends StatelessWidget {
  const Tags({super.key, required this.database, required this.records});

  final Database database;
  final List<Tag> records;

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
          ],
        ),
        ...records
            .map((tag) => TableRow(
                  children: <Widget>[
                    TableCell(
                      child: Text(tag.name),
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
