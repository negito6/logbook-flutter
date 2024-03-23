import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class DailyHistories extends StatelessWidget {
  const DailyHistories({super.key, required this.database});

  final Database database;

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
        TableRow(
          children: <Widget>[
            Container(
              height: 64,
              width: 128,
              color: Colors.purple,
            ),
            Container(
              height: 32,
              color: Colors.yellow,
            ),
            Container(
              height: 32,
              color: Colors.yellow,
            ),
            Container(
              height: 32,
              color: Colors.yellow,
            ),
          ],
        ),
      ],
    );
  }
}