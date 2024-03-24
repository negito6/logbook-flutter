enum Screen {
  tagHistories("Tag Histories"),
  tags("Tags"),
  categoryTags("Category"),
  allHistories("All histories"),
  allTags("All Tags"),
  deletedHistories("Deleted histories"),
  ;

  const Screen(this.label);

  final String label;
}
