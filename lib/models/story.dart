class Story {
  final String id;
  final String title;
  final String category;
  final String emoji;
  final String summary;
  final List<String> pages;
  final String author;

  const Story({
    required this.id,
    required this.title,
    required this.category,
    required this.emoji,
    required this.summary,
    required this.pages,
    this.author = 'Basm popular românesc',
  });

  int get pageCount => pages.length;
}

class StoryCategory {
  final String id;
  final String name;
  final String emoji;
  final String description;

  const StoryCategory({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
  });
}
