import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:logbook/models/tag.dart';
import 'package:logbook/models/history.dart';
import 'package:logbook/views/formats/datetime.dart';

class Tags extends StatefulWidget {
  const Tags(
      {super.key,
      required this.database,
      required this.datetime,
      required this.tags});

  final Database database;
  final List<Tag> tags;
  final DateTime datetime;

  @override
  State<Tags> createState() => TagsState();
}

class TagsState extends State<Tags> {
  DateTime datetime = DateTime.now();
  List<History> histories = [];

  void onPressedRaisedButton() async {
    final DateTime? picked = await showDatePicker(
        locale: const Locale("ja"),
        context: context,
        initialDate: datetime,
        firstDate: DateTime(2020),
        lastDate: DateTime.now().add(const Duration(days: 1)));

    if (picked != null) {
      setState(() {
        datetime = picked;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    datetime = widget.datetime;
    reload();
  }

  void reload() async {
    getHistories(widget.database).then((result) {
      setState(() {
        histories = result;
      });
    });
  }

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

      final tagCategory =
          widget.tags.where((tag) => tag.category == category.value);
      for (var tag in tagCategory) {
        final tagHistories = histories.where((history) =>
            history.tagId == tag.id &&
            history.notDeleted());
        final tagHistoriesOnDate = tagHistories.where((history) =>
             history.doneOn() == dateStr(datetime));
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
              child: tagHistoriesOnDate.isEmpty
                  ? ElevatedButton(
                      onPressed: () async {
                        await widget.database.insert(
                          'histories',
                          {
                            'tagId': tag.id,
                            'description': "",
                            'value': 0,
                            'doneTimestamp': timestamp(datetime),
                            'createdTimestamp': currentTimestamp(),
                          },
                          conflictAlgorithm: ConflictAlgorithm.replace,
                        );
                        reload();
                      },
                      child: const Text('Done'),
                    )
                  : ElevatedButton(
                      onPressed: () async {
                        await widget.database.update(
                          'histories',
                          {
                            'deletedTimestamp': currentTimestamp(),
                          },
                          // Ensure that the Dog has a matching id.
                          where: 'id = ?',
                          // Pass the Dog's id as a whereArg to prevent SQL injection.
                          whereArgs: [tag.id],
                          conflictAlgorithm: ConflictAlgorithm.replace,
                        );
                        reload();
                      },
                      child: const Text('Delete'),
                    ),
            ),
          ],
        ));
      }
    }

    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ElevatedButton(
              onPressed: () async {
                onPressedRaisedButton();
              },
              child: Text(dateStr(datetime))),
          Table(
            border: TableBorder.all(),
            children: rows,
          )
        ]);
  }
}
