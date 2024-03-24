enum Screen {
  tagHistories("Tag Histories"),
  tags("Tags"),
  categoryTags("Category"),
  allHistories("All histories"),
  deletedHistories("Deleted histories"),
  ;

  const Screen(this.label);

  final String label;
}
