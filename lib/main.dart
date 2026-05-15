import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'providers/favorites_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/home_screen.dart';
import 'screens/categories_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/settings_screen.dart';
import 'services/ad_service.dart';
import 'services/notification_service.dart';
import 'services/subscription_service.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await SubscriptionService.instance.initialize();
  await AdService.initialize();
  await NotificationService.instance.initialize();
  await NotificationService.instance.scheduleDailyReminders();
  runApp(const PovestiApp());
}

class PovestiApp extends StatefulWidget {
  const PovestiApp({super.key});

  @override
  State<PovestiApp> createState() => _PovestiAppState();
}

class _PovestiAppState extends State<PovestiApp> with WidgetsBindingObserver {
  final FavoritesProvider favoritesProvider = FavoritesProvider();
  final SettingsProvider settingsProvider = SettingsProvider();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    settingsProvider.addListener(_onSettingsChanged);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App Open ad la revenirea în prim-plan (cooldown gestionat în AdService)
    if (state == AppLifecycleState.resumed) {
      AdService.onAppResumed();
    }
  }

  void _onSettingsChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    settingsProvider.removeListener(_onSettingsChanged);
    favoritesProvider.dispose();
    settingsProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Povești Românești',
      debugShowCheckedModeBanner: false,
      theme: settingsProvider.nightMode ? buildDarkTheme() : buildLightTheme(),
      home: MainNavigation(
        favoritesProvider: favoritesProvider,
        settingsProvider: settingsProvider,
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  final FavoritesProvider favoritesProvider;
  final SettingsProvider settingsProvider;

  const MainNavigation({
    super.key,
    required this.favoritesProvider,
    required this.settingsProvider,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  BannerAd? _bannerAd;
  bool _isBannerLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
    SubscriptionService.instance.noAdsNotifier.addListener(_onAdsAvailabilityChanged);
    AdService.adFreeNotifier.addListener(_onAdsAvailabilityChanged);
  }

  void _loadBannerAd() {
    final ad = AdService.createBannerAdIfAllowed();
    if (ad == null) return;
    _bannerAd = ad
      ..load().then((_) {
        if (mounted) setState(() => _isBannerLoaded = true);
      });
  }

  void _onAdsAvailabilityChanged() {
    if (AdService.adsBlocked) {
      _bannerAd?.dispose();
      _bannerAd = null;
      if (mounted) setState(() => _isBannerLoaded = false);
    } else if (_bannerAd == null) {
      _loadBannerAd();
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    SubscriptionService.instance.noAdsNotifier.removeListener(_onAdsAvailabilityChanged);
    AdService.adFreeNotifier.removeListener(_onAdsAvailabilityChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        favoritesProvider: widget.favoritesProvider,
        settingsProvider: widget.settingsProvider,
      ),
      CategoriesScreen(
        favoritesProvider: widget.favoritesProvider,
        settingsProvider: widget.settingsProvider,
      ),
      FavoritesScreen(
        favoritesProvider: widget.favoritesProvider,
        settingsProvider: widget.settingsProvider,
      ),
      SettingsScreen(
        settingsProvider: widget.settingsProvider,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isBannerLoaded && _bannerAd != null)
            Container(
              alignment: Alignment.center,
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
          BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: 'Acasă',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.category_rounded),
                label: 'Categorii',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite_rounded),
                label: 'Favorite',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_rounded),
                label: 'Setări',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
