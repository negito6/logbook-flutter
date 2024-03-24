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
  int editingHistoryId = 0;
  int? editingValue;
  String? editingDesc;

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
            TableCell(
              child: (editingHistoryId > 0 && editingValue != null)
                  ? ElevatedButton(
                      onPressed: () async {
                        await widget.database.update(
                          'histories',
                          {
                            'value': editingValue,
                          },
                          where: 'id = ?',
                          whereArgs: [editingHistoryId],
                          conflictAlgorithm: ConflictAlgorithm.replace,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Value updated to $editingValue')),
                        );
                        setState(() {
                          editingValue = null;
                        });
                        reload();
                      },
                      child: Text("Save $editingHistoryId"),
                    )
                  : const Text("----"),
            ),
            TableCell(
              child: (editingHistoryId > 0 && editingDesc != null)
                  ? ElevatedButton(
                      onPressed: () async {
                        await widget.database.update(
                          'histories',
                          {
                            'description': editingDesc,
                          },
                          where: 'id = ?',
                          whereArgs: [editingHistoryId],
                          conflictAlgorithm: ConflictAlgorithm.replace,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Desc updated to $editingDesc')),
                        );
                        setState(() {
                          editingValue = null;
                        });
                        reload();
                      },
                      child: Text("Save $editingHistoryId"),
                    )
                  : const Text("----"),
            ),
          ],
        ),
        const TableRow(
          children: <Widget>[
            TableCell(
              child: Text("Id"),
            ),
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
                child: Text(history.id.toString()),
              ),
              TableCell(
                child: Text(history.doneAt()),
              ),
              TableCell(
                  child: TextFormField(
                initialValue: history.value.toString(),
                onChanged: (newValue) async {
                  if (newValue != history.value.toString()) {
                    try {
                      final intValue = int.parse(newValue);
                      setState(() {
                        editingHistoryId = history.id == null ? 0 : history.id!;
                        editingValue = intValue;
                      });
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error $e')),
                      );
                    }
                  }
                },
              )),
              TableCell(
                  child: TextFormField(
                initialValue: history.description,
                onChanged: (newValue) async {
                  setState(() {
                    editingHistoryId = history.id == null ? 0 : history.id!;
                    editingDesc = newValue;
                  });
                },
              )),
            ],
          );
        }),
      ],
    );
  }
}
