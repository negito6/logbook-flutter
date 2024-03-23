import 'package:flutter/material.dart';
import 'package:logbook/models/tag.dart';

class CategoryTags extends StatelessWidget {
  const CategoryTags({super.key, required this.category, required this.tags});

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

    return Table(
      border: TableBorder.all(),
      children: rows,
    );
  }
}
