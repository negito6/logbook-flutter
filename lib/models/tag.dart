import 'package:sqflite/sqflite.dart';

enum Category {
  undefined("Undefined", 0),
  check("Check", 1),
  food("Food", 2),
  wash("Wash", 3),
  clean("Clean", 4),
  act("Act", 5),
  item("Item", 6),
  ;

  const Category(this.label, this.value);

  final String label;
  final int value;
}

List<Category> availableCategories() {
  return [
    Category.check,
    Category.food,
    Category.wash,
    Category.clean,
    Category.act,
    Category.item,
  ];
}

class Tag {
  final int? id;
  final String name;
  final int category;
  final int lot;
  final int createdTimestamp;
  final int updatedTimestamp;
  int? deletedTimestamp;

  Tag({
    this.id,
    required this.name,
    required this.category,
    required this.lot,
    required this.createdTimestamp,
    required this.updatedTimestamp,
    this.deletedTimestamp,
  });

  bool notDeleted() {
    return deletedTimestamp == null;
  }

  String label() {
    return Category.values.firstWhere((value) => value.value == category,
        orElse: () {
      return Category.undefined;
    }).label;
  }

  static String createTagTableStatement() {
    return 'CREATE TABLE tags(id INTEGER PRIMARY KEY, name TEXT, category INTEGER, lot INTEGER, createdTimestamp INTEGER, updatedTimestamp INTEGER, deletedTimestamp INTEGER NULL)';
  }
}

Future<List<Tag>> getTags(Database db) async {
  // Get a reference to the database.

  final List<Map<String, Object?>> tagMaps = await db.query('tags');

  return [
    for (final {
          'id': id as int,
          'name': name as String?,
          'category': category as int?,
          'lot': lot as int?,
          'createdTimestamp': createdTimestamp as int?,
          'updatedTimestamp': updatedTimestamp as int?,
          'deletedTimestamp': deletedTimestamp as int?,
        } in tagMaps)
      Tag(
        id: id,
        name: name ?? 'No name',
        category: category ?? 0,
        lot: lot ?? 0,
        createdTimestamp: createdTimestamp ?? 0,
        updatedTimestamp: updatedTimestamp ?? 0,
        deletedTimestamp: deletedTimestamp,
      ),
  ];
}
