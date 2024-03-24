import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:logbook/models/tag.dart';
import 'package:logbook/views/formats/datetime.dart';

class AllTags extends StatefulWidget {
  const AllTags({super.key, required this.database});

  final Database database;

  @override
  State<AllTags> createState() => AllTagsState();
}

class AllTagsState extends State<AllTags> {
  List<Tag> tags = [];

  @override
  void initState() {
    super.initState();

    reload();
  }

  void reload() async {
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
            TableCell(child: Text("Id")),
            TableCell(child: Text("Tag")),
            TableCell(child: Text("Category")),
            TableCell(child: Text("Lot")),
            TableCell(child: Text("----")),
          ],
        ),
        ...tags.map((tag) {
          final categories = Category.values
              .where((category) => tag.category == category.value);
          return TableRow(
            decoration: BoxDecoration(
              color: tag.notDeleted() ? Colors.white : Colors.grey,
            ),
            children: <Widget>[
              TableCell(child: Text(tag.id.toString())),
              TableCell(child: Text(tag.name)),
              TableCell(
                child: Text(categories.isEmpty
                    ? '(${tag.category.toString()} ?)'
                    : categories.first.label),
              ),
              TableCell(child: Text(tag.lot.toString())),
              TableCell(
                child: ElevatedButton(
                  onPressed: () async {
                    await widget.database.update(
                      'tags',
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
          );
        }),
      ],
    );
  }
}
