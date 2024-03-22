enum Category {
  check("Check", 1),
  food("Food", 2),
  wash("Wash", 3),
  clean("Clean", 4),
  act("Act", 5),
  ;

  const Category(this.label, this.value);

  final String label;
  final int value;
}

class Tag {
  final int id;
  final String name;
  final int category;

  const Tag({
    required this.id,
    required this.name,
    required this.category,
  });

  static String createTagTableStatement() {
    return 'CREATE TABLE tags(id INTEGER PRIMARY KEY, name TEXT, category INTEGER)';
  }
}

Future<List<Tag>> getTags(database) async {
  // Get a reference to the database.
  final db = await database;

  final List<Map<String, Object?>> tagMaps = await db.query('tags');

  return [
    for (final {
          'id': id as int,
          'name': name as String,
          'category': category as int,
        } in tagMaps)
      Tag(id: id, name: name, category: category),
  ];
}