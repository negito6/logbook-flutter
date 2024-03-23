import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:logbook/models/tag.dart';
import 'package:logbook/models/history.dart';

class TagHistories extends StatefulWidget {
  const TagHistories({super.key, required this.database, required this.tag});

  final Database database;
  final Tag tag;

  @override
  State<TagHistories> createState() => TagHistoriesState();
}

class TagHistoriesState extends State<TagHistories> {
  List<History> histories = [];

  @override
  void initState() {
    super.initState();

    reload();
  }

  void reload() async {
    getHistories(widget.database).then((result) {
      final target =
          result.where((history) => history.tagId == widget.tag.id).toList();
      target.sort((a, b) => b.doneTimestamp.compareTo(a.doneTimestamp));
      setState(() {
        histories = target;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(),
      children: <TableRow>[
        const TableRow(
          children: <Widget>[
            TableCell(
              child: Text("Done at"),
            ),
            TableCell(
              child: Text("Value"),
            ),
            TableCell(
              child: Text("Desc"),
            ),
            TableCell(
              child: Text("Save"),
            ),
          ],
        ),
        ...histories.map((history) {
          return TableRow(
            children: <Widget>[
              TableCell(
                child: Text(history.doneAt()),
              ),
              TableCell(
                child: Text(history.value.toString()),
              ),
              TableCell(
                child: Text(history.description),
              ),
              TableCell(
                child: ElevatedButton(
                  onPressed: () async {
                    await widget.database.update(
                      'histories',
                      {
                        'description': "",
                        'value': 0,
                      },
                      where: 'id = ?',
                      whereArgs: [history.id],
                      conflictAlgorithm: ConflictAlgorithm.replace,
                    );

                    reload();
                  },
                  child: const Text('Clear'),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}
