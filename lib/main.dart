import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'providers/favorites_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/home_screen.dart';
import 'screens/categories_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/settings_screen.dart';
import 'services/ad_service.dart';
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
  runApp(const PovestiApp());
}

class PovestiApp extends StatefulWidget {
  const PovestiApp({super.key});

  @override
  State<PovestiApp> createState() => _PovestiAppState();
}

class _PovestiAppState extends State<PovestiApp> {
  final FavoritesProvider favoritesProvider = FavoritesProvider();
  final SettingsProvider settingsProvider = SettingsProvider();

  @override
  void initState() {
    super.initState();
    settingsProvider.addListener(_onSettingsChanged);
  }

  void _onSettingsChanged() {
    setState(() {});
  }

  @override
  void dispose() {
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
      bottomNavigationBar: BottomNavigationBar(
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
    );
  }
}
