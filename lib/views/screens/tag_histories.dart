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
        TableRow(
          children: <Widget>[
            TableCell(
              child: Text(widget.tag.name),
            ),
            const TableCell(
              child: Text("----"),
            ),
            const TableCell(
              child: Text("----"),
            ),
          ],
        ),
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
          ],
        ),
        ...histories.map((history) {
          return TableRow(
            decoration: BoxDecoration(
              color: history.notDeleted() ? Colors.white : Colors.grey,
            ),
            children: <Widget>[
              TableCell(
                child: Text(history.doneAt()),
              ),
              TableCell(
                  child: TextFormField(
                initialValue: history.value.toString(),
                onChanged: (newValue) async {
                  if (newValue != history.value) {
                    try {
                      final intValue = int.parse(newValue);
                      await widget.database.update(
                        'histories',
                        {
                          'value': intValue,
                        },
                        where: 'id = ?',
                        whereArgs: [history.id],
                        conflictAlgorithm: ConflictAlgorithm.replace,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Updating $newValue')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Updating $e')),
                      );
                    }
                  }
                },
              )),
              TableCell(
                  child: TextFormField(
                initialValue: history.description,
                onChanged: (newValue) async {
                  if (newValue != history.description) {
                    await widget.database.update(
                      'histories',
                      {
                        'description': newValue,
                      },
                      where: 'id = ?',
                      whereArgs: [history.id],
                      conflictAlgorithm: ConflictAlgorithm.replace,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Updating $newValue')),
                    );
                  }
                },
              )),
            ],
          );
        }),
      ],
    );
  }
}
