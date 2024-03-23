import 'package:sqflite/sqflite.dart';

class History {
  final int id;
  final int tagId;
  final String description;
  final int value;
  final DateTime doneAt;
  final DateTime createdAt;
  final DateTime deletedAt;

  const History({
    required this.id,
    required this.tagId,
    required this.description,
    required this.value,
    required this.doneAt,
    required this.createdAt,
    required this.deletedAt,
  });

  static String createTagTableStatement() {
    return 'CREATE TABLE histories(id INTEGER PRIMARY KEY, tagId INTEGER, description TEXT, value INTEGER, doneAt DATETIME, createdAt DATETIME, deletedAt DATETIME)';
  }
}

Future<List<History>> getHistories(Database db) async {
  // Get a reference to the database.

  final List<Map<String, Object?>> tagMaps = await db.query('histories');

  return [
    for (final {
          'id': id as int,
          'tagId': tagId as int,
          'description': description as String,
          'value': value as int,
          'doneAt': doneAt as DateTime,
          'createdAt': createdAt as DateTime,
          'deletedAt': deletedAt as DateTime,
        } in tagMaps)
      History(
        id: id,
        tagId: tagId,
        description: description,
        value: value,
        doneAt: doneAt,
        createdAt: createdAt,
        deletedAt: deletedAt,
      ),
  ];
}
