import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:logbook/models/tag.dart';
import 'package:logbook/models/history.dart';

class AllHistories extends StatefulWidget {
  const AllHistories({super.key, required this.database});

  final Database database;

  @override
  State<AllHistories> createState() => AllHistoriesState();
}

class AllHistoriesState extends State<AllHistories> {
  List<History> histories = [];
  List<Tag> tags = [];

  @override
  void initState() {
    super.initState();

    reload();
  }

  void reload() async {
    getHistories(widget.database).then((result) {
      final target = result;
      target.sort((a, b) => b.doneTimestamp.compareTo(a.doneTimestamp));
      setState(() {
        histories = target;
      });
    });
    getTags(widget.database).then((result) {
      final target = result;
      setState(() {
        tags = target;
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
              child: Text("Tag"),
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
          final targetTags = tags.where((tag) => tag.id == history.tagId);
          return TableRow(
            decoration: BoxDecoration(
              color: history.notDeleted() ? Colors.white : Colors.grey,
            ),
            children: <Widget>[
              TableCell(
                child:
                    Text(targetTags.isEmpty ? "No tag" : targetTags.first.name),
              ),
              TableCell(
                child: Text(history.doneAt()),
              ),
              TableCell(
                child: Text(history.value.toString()),
              ),
              TableCell(
                child: Text(history.description),
              ),
            ],
          );
        }),
      ],
    );
  }
}
