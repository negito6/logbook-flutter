import 'package:flutter/material.dart';

class Tags extends StatelessWidget {
  const Tags({super.key});

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
          ],
        ),
      ],
    );
  }
}
