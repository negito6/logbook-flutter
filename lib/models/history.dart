import 'package:sqflite/sqflite.dart';
import 'package:logbook/views/formats/datetime.dart';

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
    return dateStr(datetimeFromTimestamp(doneTimestamp));
  }

  String doneAt() {
    return datetimeStr(doneTimestamp);
  }

  bool notDeleted() {
    return deletedTimestamp == null;
  }

  List<String> csv() {
    return [
      id.toString(),
      tagId.toString(),
      description,
      value.toString(),
      doneTimestamp.toString(),
      createdTimestamp.toString(),
      (deletedTimestamp ?? 0).toString(),
    ];
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
          'tagId': tagId as int?,
          'description': description as String?,
          'value': value as int?,
          'doneTimestamp': doneTimestamp as int?,
          'createdTimestamp': createdTimestamp as int?,
          'deletedTimestamp': deletedTimestamp as int?,
        } in tagMaps)
      History(
        id: id,
        tagId: tagId ?? 1,
        description: description ?? "",
        value: value ?? 0,
        doneTimestamp: doneTimestamp ?? 0,
        createdTimestamp: createdTimestamp ?? 0,
        deletedTimestamp: deletedTimestamp,
      ),
  ];
}
