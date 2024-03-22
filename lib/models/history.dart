class History {
  final int id;
  final int tagId;
  final String description;
  final int value;
  final String createdAt;
  final String deletedAt;

  const History({
    required this.id,
    required this.tagId,
    required this.description,
    required this.value,
    required this.createdAt,
    required this.deletedAt,
  });

  static String createTagTableStatement() {
    return 'CREATE TABLE histories(id INTEGER PRIMARY KEY, tagId INTEGER, description TEXT, value INTEGER, createdAt DATETIME, deletedAt DATETIME)';
  }
}
