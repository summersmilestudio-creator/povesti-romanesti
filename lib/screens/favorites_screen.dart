import 'package:flutter/material.dart';
import '../data/stories.dart';
import '../providers/favorites_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/story_card.dart';
import '../theme.dart';
import 'reading_screen.dart';

class FavoritesScreen extends StatefulWidget {
  final FavoritesProvider favoritesProvider;
  final SettingsProvider settingsProvider;

  const FavoritesScreen({
    super.key,
    required this.favoritesProvider,
    required this.settingsProvider,
  });

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).scaffoldBackgroundColor == AppColors.nightBackground;
    final favoriteStories = allStories
        .where((s) => widget.favoritesProvider.isFavorite(s.id))
        .toList();

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Favorite',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.nightText : AppColors.warmBrown,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  favoriteStories.isEmpty
                      ? 'Adaugă povești la favorite apăsând pe inimioara'
                      : '${favoriteStories.length} povești favorite',
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark
                        ? AppColors.nightText.withValues(alpha: 0.7)
                        : AppColors.lightBrown,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: favoriteStories.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '💛',
                          style: TextStyle(fontSize: 64),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nicio poveste favorită',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.nightText : AppColors.warmBrown,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Apasă pe inimioară la poveștile\ncare îți plac mai mult!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? AppColors.nightText.withValues(alpha: 0.6)
                                : AppColors.lightBrown,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: favoriteStories.length,
                    itemBuilder: (context, index) {
                      final story = favoriteStories[index];
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
}
