import 'package:flutter/material.dart';
import '../models/story.dart';
import '../providers/favorites_provider.dart';
import '../theme.dart';
import 'story_illustration.dart';

class StoryCard extends StatelessWidget {
  final Story story;
  final FavoritesProvider favoritesProvider;
  final VoidCallback onTap;
  final bool locked;

  const StoryCard({
    super.key,
    required this.story,
    required this.favoritesProvider,
    required this.onTap,
    this.locked = false,
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
          border: Border.all(color: AppColors.glassStroke, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.golden.withValues(alpha: 0.16),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Emoji illustration
              Stack(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.golden.withValues(alpha: 0.35),
                        width: 2,
                      ),
                    ),
                    child: Opacity(
                      opacity: locked ? 0.45 : 1.0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: StoryIllustration(story: story, size: 72),
                      ),
                    ),
                  ),
                  if (locked)
                    Positioned(
                      right: 4,
                      bottom: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.golden,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.lock_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
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
                          locked
                              ? Icons.lock_rounded
                              : Icons.auto_stories_rounded,
                          size: 14,
                          color: AppColors.golden,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          locked
                              ? 'Deblochează'
                              : '${story.pageCount} pagini',
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
