enum Screen {
  tagHistories("Tag Histories"),
  tags("Tags"),
  categoryTags("Category"),
  histories("All histories"),
  deletedHistories("Deleted histories"),
  ;

  const Screen(this.label);

  final String label;
}
