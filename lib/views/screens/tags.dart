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
  int currentValue = 0;
  bool visibleValueGroupTags = false;

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

  TableRow categoryHeaderRow(Category category) {
    return TableRow(
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
    );
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

    for (var category in [
      Category.check,
    ]) {
      rows.add(categoryHeaderRow(category));
      final tagCategories =
          widget.tags.where((tag) => tag.category == category.value).toList();
      var tagHistoriesOnDate = <History>[];
      for (var history in histories) {
        for (var tag in tagCategories) {
          if (history.notDeleted() &&
              history.tagId == tag.id &&
              history.doneOn() == dateStr(datetime)) {
            tagHistoriesOnDate.add(history);
          }
        }
      }
      final distinctValues = [
        ...{...tagHistoriesOnDate.map((h) => h.value)}
      ];
      for (var value in distinctValues) {
        rows.add(TableRow(children: <Widget>[
          TableCell(
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  currentValue = value;
                });
              },
              child: Text(value.toString()),
            ),
          ),
          const TableCell(child: Text("----")),
          const TableCell(child: Text("----")),
        ]));
      }
      rows.add(TableRow(children: <Widget>[
        TableCell(
          child: currentValue == 0
              ? ElevatedButton(
                  onPressed: () {
                    setState(() {
                      visibleValueGroupTags = !visibleValueGroupTags;
                    });
                  },
                  child: Text(visibleValueGroupTags ? "Hide" : "Show"),
                )
              : const Text("----"),
        ),
        TableCell(
          child: currentValue == 0
              ? ElevatedButton(
                  onPressed: () {
                    setState(() {
                      currentValue = currentTimeInt();
                    });
                  },
                  child: const Text("New"),
                )
              : ElevatedButton(
                  onPressed: () {
                    setState(() {
                      currentValue = 0;
                    });
                  },
                  child: const Text("Back"),
                ),
        ),
        const TableCell(child: Text("----")),
      ]));
      tagCategories
          .sort((a, b) => b.updatedTimestamp.compareTo(a.updatedTimestamp));
      if (currentValue > 0) {
        final distinctLots = [
          ...{...tagCategories.map((tag) => tag.lot)}
        ];
        distinctLots.sort((a, b) => a.compareTo(b));
        tagCategories
            .sort((a, b) => b.updatedTimestamp.compareTo(a.updatedTimestamp));
        for (var lot in distinctLots) {
          final tagCategoryOnLot = tagCategories.where((tag) => tag.lot == lot);
          for (var tag in tagCategoryOnLot) {
            final tagHistoriesOnDateAndValue = histories.where((history) =>
                history.tagId == tag.id &&
                history.notDeleted() &&
                history.doneOn() == dateStr(datetime) &&
                history.value == currentValue);
            rows.add(TableRow(
              children: <Widget>[
                TableCell(child: Text(tag.name)),
                TableCell(
                    child: tagHistoriesOnDateAndValue.isEmpty
                        ? const Text("")
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
                                whereArgs: [
                                  tagHistoriesOnDateAndValue.first.id
                                ],
                                conflictAlgorithm: ConflictAlgorithm.replace,
                              );
                              reload();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Deleted ${tag.name}')),
                              );
                            },
                            child: const Text('Delete'),
                          )),
                TableCell(
                    child: tagHistoriesOnDateAndValue.isEmpty
                        ? ElevatedButton(
                            onPressed: () async {
                              await widget.database.insert(
                                'histories',
                                {
                                  'tagId': tag.id,
                                  'description': "",
                                  'value': currentValue,
                                  'doneTimestamp': timestamp(datetime),
                                  'createdTimestamp': currentTimestamp(),
                                },
                                conflictAlgorithm: ConflictAlgorithm.replace,
                              );
                              reload();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Created ${tag.name}')),
                              );
                            },
                            child: Text(currentValue.toString()),
                          )
                        : const Text("")),
              ],
            ));
          }
        }
      }
      if (currentValue == 0 && visibleValueGroupTags) {
        for (var tag in tagCategories) {
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
              const TableCell(child: Text("")),
              const TableCell(child: Text("")),
            ],
          ));
        }
      }
    }
    if (currentValue == 0) {
      for (var category in [
        Category.food,
        Category.wash,
        Category.clean,
        Category.act,
        Category.item,
      ]) {
        rows.add(categoryHeaderRow(category));

        final tagCategories =
            widget.tags.where((tag) => tag.category == category.value).toList();
        final distinctLots = [
          ...{...tagCategories.map((tag) => tag.lot)}
        ];
        distinctLots.sort((a, b) => a.compareTo(b));
        tagCategories
            .sort((a, b) => b.updatedTimestamp.compareTo(a.updatedTimestamp));
        for (var lot in distinctLots) {
          final tagCategoryOnLot = tagCategories.where((tag) => tag.lot == lot);
          rows.add(TableRow(
            children: <Widget>[
              const TableCell(child: Text("----")),
              TableCell(child: Text(lot.toString())),
              const TableCell(child: Text("----")),
            ],
          ));

          for (var tag in tagCategoryOnLot) {
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
                    child: tagHistories.isEmpty
                        ? const Text("----")
                        : (tagHistoriesOnDate.isEmpty
                            ? Text(tagHistories.first.doneOn()) // old or new
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
                                    conflictAlgorithm:
                                        ConflictAlgorithm.replace,
                                  );
                                  reload();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text('Deleted ${tag.name}')),
                                  );
                                },
                                child: const Text('Delete'),
                              ))),
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
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Created ${tag.name}')),
                            );
                          },
                          child: Text(dateStr(datetime)),
                        )
                      : Text(tagHistoriesOnDate.first.description),
                ),
              ],
            ));
          }
        }
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
