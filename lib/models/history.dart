import 'package:sqflite/sqflite.dart';

class History {
  int? id;
  final int tagId;
  final String description;
  final int value;
  final int doneTimestamp;
  final int createdTimestamp;
  int? deletedTimestamp;

  History({
    this.id,
    required this.tagId,
    required this.description,
    required this.value,
    required this.doneTimestamp,
    required this.createdTimestamp,
    this.deletedTimestamp,
  });

  String doneOn() {
    return DateTime.fromMillisecondsSinceEpoch(doneTimestamp * 1000)
        .toString()
        .substring(0, 10);
  }

  String doneAt() {
    return DateTime.fromMillisecondsSinceEpoch(doneTimestamp * 1000).toString();
  }

  bool notDeleted() {
    return deletedTimestamp == null;
  }

  static String createTagTableStatement() {
    return 'CREATE TABLE histories(id INTEGER PRIMARY KEY, tagId INTEGER, description TEXT, value INTEGER, doneTimestamp INTEGER, createdTimestamp INTEGER, deletedTimestamp INTEGER NULL)';
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
          'doneTimestamp': doneTimestamp as int,
          'createdTimestamp': createdTimestamp as int,
          // 'deletedTimestamp': deletedTimestamp as int,
        } in tagMaps)
      History(
        id: id,
        tagId: tagId,
        description: description,
        value: value,
        doneTimestamp: doneTimestamp,
        createdTimestamp: createdTimestamp,
        // deletedTimestamp: deletedTimestamp,
      ),
  ];
}
