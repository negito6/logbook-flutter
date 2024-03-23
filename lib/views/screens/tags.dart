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
        final tagHistories = histories.where(
            (history) => history.tagId == tag.id && history.notDeleted());
        rows.add(TableRow(
          children: <Widget>[
            TableCell(
              child: Text(tag.name),
            ),
            TableCell(
              child:
                  Text(tagHistories.isEmpty ? "" : tagHistories.first.doneOn()),
            ),
            TableCell(
              child: tagHistories.isEmpty
                  ? ElevatedButton(
                      onPressed: () async {
                        await database.insert(
                          'histories',
                          {
                            'tagId': tag.id,
                            'description': "",
                            'value': 0,
                            'doneTimestamp':
                                (DateTime.now().millisecondsSinceEpoch ~/ 1000),
                            'createdTimestamp':
                                (DateTime.now().millisecondsSinceEpoch ~/ 1000),
                          },
                          conflictAlgorithm: ConflictAlgorithm.replace,
                        );
                      },
                      child: const Text('Done'),
                    )
                  : ElevatedButton(
                      onPressed: () async {
                        await database.update(
                          'histories',
                          {
                            'deletedTimestamp':
                                DateTime.now().millisecondsSinceEpoch / 1000,
                          },
                          // Ensure that the Dog has a matching id.
                          where: 'id = ?',
                          // Pass the Dog's id as a whereArg to prevent SQL injection.
                          whereArgs: [tag.id],
                          conflictAlgorithm: ConflictAlgorithm.replace,
                        );
                      },
                      child: const Text('Delete'),
                    ),
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
