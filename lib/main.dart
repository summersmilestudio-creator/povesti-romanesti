import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'providers/favorites_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/home_screen.dart';
import 'screens/categories_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/settings_screen.dart';
import 'services/ad_service.dart';
import 'services/notification_service.dart';
import 'services/subscription_service.dart';
import 'services/unlock_service.dart';
import 'theme.dart';
import 'widgets/bottom_banner_ad.dart';

/// Rulează un pas de inițializare izolat. Dacă pică (ex. plugin stripat de
/// R8 în release, lipsă Play Services, permisiune refuzată) logăm eroarea
/// și mergem mai departe — un serviciu picat (ads / IAP / notificări) NU
/// mai are voie să blocheze `runApp()`. Aceasta era cauza ecranului alb din
/// 2.3.1: orice excepție în `main()` oprea pornirea aplicației definitiv.
Future<void> _safeInit(String name, Future<void> Function() step) async {
  try {
    await step();
  } catch (e, st) {
    debugPrint('[init] "$name" a esuat (continui oricum): $e');
    debugPrintStack(stackTrace: st, label: 'init:$name');
  }
}

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Erorile de framework nu mai trebuie să lase ecranul gol în tăcere.
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      debugPrint('[FlutterError] ${details.exceptionAsString()}');
    };

    await _safeInit('orientation', () async {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    });
    await _safeInit(
        'SubscriptionService', SubscriptionService.instance.initialize);
    await _safeInit('UnlockService', UnlockService.instance.initialize);
    await _safeInit('AdService', AdService.initialize);
    await _safeInit(
        'NotificationService', NotificationService.instance.initialize);
    await _safeInit('scheduleDailyReminders',
        NotificationService.instance.scheduleDailyReminders);

    runApp(const PovestiApp());
  }, (error, stack) {
    // Plasă de siguranță finală: chiar și o eroare neașteptată în zonă
    // nu mai trebuie să lase utilizatorul cu ecran alb.
    debugPrint('[zone] Eroare neprinsa: $error');
    debugPrintStack(stackTrace: stack, label: 'zone');
  });
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
          const BottomBannerAd(),
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
