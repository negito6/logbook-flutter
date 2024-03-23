import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:logbook/models/tag.dart';
import 'package:logbook/models/history.dart';
import 'package:logbook/views/formats/datetime.dart';

class MyCustomForm extends StatefulWidget {
  const MyCustomForm(
      {super.key, required this.category, required this.database});

  final Database database;
  final Category category;

  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class MyCustomFormState extends State<MyCustomForm> {
  final _formKey = GlobalKey<FormState>();

  final myController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
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

                  await widget.database.insert(
                    'tags',
                    {
                      'name': myController.text,
                      'category': widget.category.value,
                      'createdTimestamp': currentTimestamp(),
                      'updatedTimestamp': currentTimestamp(),
                    },
                    conflictAlgorithm: ConflictAlgorithm.replace,
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Processing Data')),
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryTags extends StatefulWidget {
  const CategoryTags(
      {super.key,
      required this.database,
      required this.category,
      required this.tags});

  final Database database;
  final Category category;
  final List<Tag> tags;

  @override
  State<CategoryTags> createState() => CategoryTagsState();
}

class CategoryTagsState extends State<CategoryTags> {
  List<History> histories = [];

  @override
  void initState() {
    super.initState();

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
    final tags = widget.tags
        .where((tag) => tag.category == widget.category.value)
        .toList();
    tags.sort((a, b) => b.updatedTimestamp.compareTo(a.updatedTimestamp));
    var rows = <TableRow>[
      TableRow(
        children: <Widget>[
          TableCell(
            child: Text(widget.category.label),
          ),
          const TableCell(
            child: Text(""),
          ),
        ],
      ),
      ...tags.map((tag) => TableRow(
            children: <Widget>[
              TableCell(
                child: Text(tag.name),
              ),
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
                  child: const Text('Update'),
                ),
              ),
            ],
          )),
    ];

    return Column(children: [
      Table(
        border: TableBorder.all(),
        children: rows,
      ),
      MyCustomForm(database: widget.database, category: widget.category),
    ]);
  }
}
