import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:logbook/models/tag.dart';
import 'package:logbook/views/formats/datetime.dart';

class MyCustomForm extends StatefulWidget {
  const MyCustomForm(
      {super.key, required this.category, required this.database, this.tag});

  final Database database;
  final Category category;
  final Tag? tag;

  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class MyCustomFormState extends State<MyCustomForm> {
  final _formKey = GlobalKey<FormState>();
  var myController = TextEditingController(text: "");

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Text(widget.tag == null
          ? "New"
          : 'id = ${widget.tag!.id} ${widget.tag!.name}'),
      ElevatedButton(
        onPressed: () {
          setState(() {
            myController = TextEditingController(text: widget.tag?.name ?? "");
          });
        },
        child: widget.tag == null ? const Text('Clear') : const Text('Load'),
      ),
      Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: myController,
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: ElevatedButton(
                onPressed: () async {
                  // Validate returns true if the form is valid, or false otherwise.
                  if (_formKey.currentState!.validate()) {
                    // If the form is valid, display a snackbar. In the real world,
                    // you'd often call a server or save the information in a database.

                    if (widget.tag == null) {
                      await widget.database.insert(
                        'tags',
                        {
                          'name': myController.text,
                          'category': widget.category.value,
                          'lot': 1,
                          'createdTimestamp': currentTimestamp(),
                          'updatedTimestamp': currentTimestamp(),
                        },
                        conflictAlgorithm: ConflictAlgorithm.replace,
                      );
                    } else {
                      await widget.database.update(
                        'tags',
                        {
                          'name': myController.text,
                          'updatedTimestamp': currentTimestamp(),
                        },
                        where: 'id = ?',
                        whereArgs: [widget.tag!.id!],
                        conflictAlgorithm: ConflictAlgorithm.replace,
                      );
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('OK')),
                    );
                  }
                },
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      )
    ]);
  }
}

class CategoryTags extends StatefulWidget {
  const CategoryTags(
      {super.key, required this.database, required this.category});

  final Database database;
  final Category category;

  @override
  State<CategoryTags> createState() => CategoryTagsState();
}

class CategoryTagsState extends State<CategoryTags> {
  List<Tag> tags = [];
  Tag? targetTag;

  @override
  void initState() {
    super.initState();

    reload();
  }

  void reload() async {
    getTags(widget.database).then((result) {
      final target =
          result.where((tag) => tag.category == widget.category.value).toList();
      target.sort((a, b) => b.updatedTimestamp.compareTo(a.updatedTimestamp));
      setState(() {
        tags = target;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    reload();
    var rows = <TableRow>[
      TableRow(
        children: <Widget>[
          TableCell(
            child: Text(widget.category.label),
          ),
          const TableCell(
            child: Text("Lot"),
          ),
          const TableCell(
            child: Text(""),
          ),
        ],
      ),
      ...tags.map((tag) => TableRow(
            children: <Widget>[
              TableCell(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      targetTag = tag;
                    });
                  },
                  child: Text(tag.name),
                ),
              ),
              TableCell(
                  child: TextFormField(
                initialValue: tag.lot.toString(),
                onChanged: (newValue) async {
                  try {
                    final intValue = int.parse(newValue);
                    await widget.database.update(
                      'tags',
                      {
                        'lot': intValue,
                      },
                      // Ensure that the Dog has a matching id.
                      where: 'id = ?',
                      // Pass the Dog's id as a whereArg to prevent SQL injection.
                      whereArgs: [tag.id],
                      conflictAlgorithm: ConflictAlgorithm.replace,
                    );
                    reload();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error $e')),
                    );
                  }
                },
              )),
              TableCell(
                child: ElevatedButton(
                  onPressed: () async {
                    await widget.database.update(
                      'tags',
                      {
                        'updatedTimestamp': currentTimestamp(),
                      },
                      // Ensure that the Dog has a matching id.
                      where: 'id = ?',
                      // Pass the Dog's id as a whereArg to prevent SQL injection.
                      whereArgs: [tag.id],
                      conflictAlgorithm: ConflictAlgorithm.replace,
                    );
                    reload();
                  },
                  child: const Text('To top'),
                ),
              ),
            ],
          )),
    ];

    return Column(children: [
      MyCustomForm(
          database: widget.database, category: widget.category, tag: targetTag),
      Table(
        border: TableBorder.all(),
        children: rows,
      ),
    ]);
  }
}
