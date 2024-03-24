import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:logbook/models/tag.dart';
import 'package:logbook/models/history.dart';
import 'package:logbook/views/formats/datetime.dart';
import 'package:logbook/views/screens/tag_histories.dart';

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
  List<Tag> tags = [];

  void onPressedRaisedButton() async {
    final DateTime? picked = await showDatePicker(
        locale: const Locale("ja"),
        context: context,
        initialDate: datetime,
        firstDate: DateTime(2024),
        lastDate: DateTime.now().add(const Duration(days: 1)));

    if (picked != null) {
      setState(() {
        datetime = picked;
      });
    }
    setState(() {
      tags = [];
    });
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
      TableRow(
        children: <Widget>[
          TableCell(
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  datetime = datetime.add(const Duration(days: -1));
                });
              },
              child: const Text('<'),
            ),
          ),
          const TableCell(
            child: Text("----"),
          ),
          TableCell(
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  datetime = datetime.add(const Duration(days: 1));
                });
              },
              child: const Text('>'),
            ),
          ),
        ],
      ),
    ];
    for (var category in availableCategories()) {
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

      final tagCategories =
          widget.tags.where((tag) => tag.category == category.value).toList();
      tagCategories
          .sort((a, b) => b.updatedTimestamp.compareTo(a.updatedTimestamp));
      for (var tag in tagCategories) {
        final tagHistories = histories.where(
            (history) => history.tagId == tag.id && history.notDeleted());
        final tagHistoriesOnDate = tagHistories
            .where((history) => history.doneOn() == dateStr(datetime));
        rows.add(TableRow(
          children: <Widget>[
            TableCell(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    tags = [tag];
                  });
                },
                child: Text(tag.name),
              ),
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
                          whereArgs: [tagHistoriesOnDate.first.id],
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
          tags.isEmpty
              ? ElevatedButton(
                  onPressed: () async {
                    onPressedRaisedButton();
                  },
                  child: Text(dateStr(datetime)))
              : ElevatedButton(
                  onPressed: () {
                    setState(() {
                      tags = [];
                    });
                  },
                  child: const Text('Back')),
          tags.isEmpty
              ? Table(
                  border: TableBorder.all(),
                  children: rows,
                )
              : TagHistories(database: widget.database, tag: tags.first)
        ]);
  }
}
