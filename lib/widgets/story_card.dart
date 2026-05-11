import 'package:flutter/material.dart';
import '../models/story.dart';
import '../providers/favorites_provider.dart';
import '../theme.dart';

class StoryCard extends StatelessWidget {
  final Story story;
  final FavoritesProvider favoritesProvider;
  final VoidCallback onTap;

  const StoryCard({
    super.key,
    required this.story,
    required this.favoritesProvider,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isFav = favoritesProvider.isFavorite(story.id);
    final isDark = Theme.of(context).scaffoldBackgroundColor == AppColors.nightBackground;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.nightCard : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black26
                  : AppColors.golden.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Emoji illustration
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.nightBackground
                      : AppColors.cream,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.golden.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    story.emoji,
                    style: const TextStyle(fontSize: 36),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Story info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      story.title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.nightText : AppColors.warmBrown,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      story.summary,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.nightText.withValues(alpha: 0.7)
                            : AppColors.lightBrown,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.auto_stories_rounded,
                          size: 14,
                          color: AppColors.golden,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${story.pageCount} pagini',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.golden,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Favorite button
              IconButton(
                icon: Icon(
                  isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: isFav ? Colors.red.shade400 : (isDark ? AppColors.nightText.withValues(alpha: 0.4) : AppColors.lightBrown.withValues(alpha: 0.4)),
                ),
                onPressed: () => favoritesProvider.toggleFavorite(story.id),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
