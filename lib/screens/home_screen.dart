import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../data/stories.dart';
import '../providers/favorites_provider.dart';
import '../providers/settings_provider.dart';
import '../services/ad_service.dart';
import '../services/subscription_service.dart';
import '../widgets/story_card.dart';
import '../theme.dart';
import 'reading_screen.dart';

class HomeScreen extends StatefulWidget {
  final FavoritesProvider favoritesProvider;
  final SettingsProvider settingsProvider;

  const HomeScreen({
    super.key,
    required this.favoritesProvider,
    required this.settingsProvider,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BannerAd? _bannerAd;
  bool _isBannerLoaded = false;

  @override
  void initState() {
    super.initState();
    widget.favoritesProvider.addListener(_refresh);
    SubscriptionService.instance.noAdsNotifier.addListener(_onSubscriptionChanged);
    _loadBannerAd();
  }

  void _onSubscriptionChanged() {
    if (SubscriptionService.instance.noAds && _bannerAd != null) {
      _bannerAd?.dispose();
      _bannerAd = null;
      if (mounted) setState(() => _isBannerLoaded = false);
    }
  }

  void _loadBannerAd() {
    final ad = AdService.createBannerAdIfAllowed();
    if (ad == null) return;
    _bannerAd = ad
      ..load().then((_) {
        if (mounted) setState(() => _isBannerLoaded = true);
      });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    widget.favoritesProvider.removeListener(_refresh);
    SubscriptionService.instance.noAdsNotifier.removeListener(_onSubscriptionChanged);
    super.dispose();
  }

  void _refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).scaffoldBackgroundColor == AppColors.nightBackground;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        '📖',
                        style: TextStyle(fontSize: 36),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Povești Românești',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.nightText : AppColors.warmBrown,
                              ),
                            ),
                            Text(
                              'Patrimoniu cultural românesc',
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
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Welcome banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [AppColors.nightCard, AppColors.nightBackground]
                            : [AppColors.golden.withValues(alpha: 0.15), AppColors.softPink.withValues(alpha: 0.3)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.golden.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'A fost odată ca niciodată... ✨',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.nightAccent : AppColors.forestGreen,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${allStories.length} basme și legende din folclorul românesc te așteaptă. Alege o poveste și descoperă moștenirea noastră.',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? AppColors.nightText : AppColors.warmBrown,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Toate poveștile',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.nightText : AppColors.warmBrown,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Story list
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final story = allStories[index];
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
              childCount: allStories.length,
            ),
          ),
          // Banner ad
          if (_isBannerLoaded && _bannerAd != null)
            SliverToBoxAdapter(
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 8),
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
            ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 16),
          ),
        ],
      ),
    );
  }
}
