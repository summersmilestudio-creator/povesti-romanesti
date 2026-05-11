import 'package:flutter/material.dart';
import '../data/categories.dart';
import '../data/stories.dart';
import '../models/story.dart';
import '../providers/favorites_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/story_card.dart';
import '../theme.dart';
import 'reading_screen.dart';

class CategoriesScreen extends StatefulWidget {
  final FavoritesProvider favoritesProvider;
  final SettingsProvider settingsProvider;

  const CategoriesScreen({
    super.key,
    required this.favoritesProvider,
    required this.settingsProvider,
  });

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    widget.favoritesProvider.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.favoritesProvider.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    setState(() {});
  }

  List<Story> _getStoriesForCategory(String categoryId) {
    return allStories.where((s) => s.category == categoryId).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).scaffoldBackgroundColor == AppColors.nightBackground;

    if (_selectedCategory != null) {
      final category = storyCategories.firstWhere((c) => c.id == _selectedCategory);
      final stories = _getStoriesForCategory(_selectedCategory!);

      return SafeArea(
        child: Column(
          children: [
            // Back header
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      color: isDark ? AppColors.nightText : AppColors.warmBrown,
                    ),
                    onPressed: () => setState(() => _selectedCategory = null),
                  ),
                  Text(
                    '${category.emoji} ${category.name}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.nightText : AppColors.warmBrown,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: stories.isEmpty
                  ? Center(
                      child: Text(
                        'Nicio poveste în această categorie.',
                        style: TextStyle(
                          color: isDark ? AppColors.nightText : AppColors.lightBrown,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: stories.length,
                      itemBuilder: (context, index) {
                        final story = stories[index];
                        return StoryCard(
                          story: story,
                          favoritesProvider: widget.favoritesProvider,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReadingScreen(
                                  story: story,
                                  favoritesProvider: widget.favoritesProvider,
                                  settingsProvider: widget.settingsProvider,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      );
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Categorii',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.nightText : AppColors.warmBrown,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Alege o categorie de povești',
              style: TextStyle(
                fontSize: 15,
                color: isDark ? AppColors.nightText.withValues(alpha: 0.7) : AppColors.lightBrown,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: storyCategories.length,
                itemBuilder: (context, index) {
                  final category = storyCategories[index];
                  final storyCount = _getStoriesForCategory(category.id).length;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = category.id),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.nightCard : AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black26
                                : AppColors.golden.withValues(alpha: 0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: AppColors.golden.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.nightBackground
                                  : AppColors.cream,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                category.emoji,
                                style: const TextStyle(fontSize: 32),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  category.name,
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? AppColors.nightText : AppColors.warmBrown,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  category.description,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark
                                        ? AppColors.nightText.withValues(alpha: 0.7)
                                        : AppColors.lightBrown,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '$storyCount povești',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.golden,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 18,
                            color: isDark ? AppColors.nightText.withValues(alpha: 0.4) : AppColors.lightBrown.withValues(alpha: 0.4),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
