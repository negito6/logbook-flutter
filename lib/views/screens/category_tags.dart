import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:logbook/models/tag.dart';

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

class CategoryTags extends StatelessWidget {
  const CategoryTags(
      {super.key,
      required this.database,
      required this.category,
      required this.tags});

  final Database database;
  final Category category;
  final List<Tag> tags;

  @override
  Widget build(BuildContext context) {
    var rows = <TableRow>[
      TableRow(
        children: <Widget>[
          TableCell(
            child: Text(category.label),
          ),
        ],
      ),
      ...tags
          .where((tag) => tag.category == category.value)
          .map((tag) => TableRow(
                children: <Widget>[
                  TableCell(
                    child: Text(tag.name),
                  ),
                ],
              )),
    ];

    return Column(children: [
      Table(
        border: TableBorder.all(),
        children: rows,
      ),
      MyCustomForm(database: database, category: category),
    ]);
  }
}
