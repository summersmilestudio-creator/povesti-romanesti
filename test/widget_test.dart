import 'package:flutter_test/flutter_test.dart';
import 'package:povesti_romanesti/data/stories.dart';
import 'package:povesti_romanesti/data/categories.dart';

void main() {
  test('stories collection has expected count and unique ids', () {
    expect(allStories.length, 60);
    final ids = allStories.map((s) => s.id).toSet();
    expect(ids.length, 60, reason: 'story ids must be unique');
  });

  test('every story belongs to a known category', () {
    final categoryIds = storyCategories.map((c) => c.id).toSet();
    for (final story in allStories) {
      expect(categoryIds.contains(story.category), isTrue,
          reason: 'unknown category ${story.category} on ${story.id}');
    }
  });

  test('every story has at least 4 pages', () {
    for (final story in allStories) {
      expect(story.pages.length, greaterThanOrEqualTo(4),
          reason: '${story.id} has too few pages');
    }
  });
}
