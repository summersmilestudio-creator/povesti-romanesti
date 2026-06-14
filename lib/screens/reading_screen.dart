import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/story.dart';
import '../providers/favorites_provider.dart';
import '../providers/settings_provider.dart';
import '../services/ad_service.dart';
import '../theme.dart';
import '../widgets/bottom_banner_ad.dart';
import '../widgets/story_illustration.dart';

enum TtsState { playing, stopped, paused }

class ReadingScreen extends StatefulWidget {
  final Story story;
  final FavoritesProvider favoritesProvider;
  final SettingsProvider settingsProvider;

  const ReadingScreen({
    super.key,
    required this.story,
    required this.favoritesProvider,
    required this.settingsProvider,
  });

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  bool _reachedEnd = false;

  // TTS
  late FlutterTts _flutterTts;
  TtsState _ttsState = TtsState.stopped;
  bool _ttsInitialized = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    widget.favoritesProvider.addListener(_refresh);
    widget.settingsProvider.addListener(_refresh);
    _initTts();
  }

  Future<void> _initTts() async {
    _flutterTts = FlutterTts();

    await _flutterTts.setLanguage('ro-RO');
    await _flutterTts.awaitSpeakCompletion(true);
    await _selectBestVoice();
    // Rate puțin mai natural (0.42 sună uman, nu robotic-rapid)
    await _flutterTts.setSpeechRate(0.42);
    await _flutterTts.setVolume(1.0);
    // Pitch puțin sub 1.0 = mai cald, mai puțin metalic
    await _flutterTts.setPitch(0.95);

    _flutterTts.setCompletionHandler(() {
      if (_currentPage < widget.story.pages.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
        Future.delayed(const Duration(milliseconds: 600), () {
          if (_ttsState == TtsState.playing) {
            _speak(widget.story.pages[_currentPage]);
          }
        });
      } else {
        setState(() => _ttsState = TtsState.stopped);
      }
    });

    _flutterTts.setErrorHandler((msg) {
      setState(() => _ttsState = TtsState.stopped);
    });

    setState(() => _ttsInitialized = true);
  }

  /// Selectează cea mai naturală voce ro-RO disponibilă.
  /// Prioritate: network/neural/wavenet > premium/enhanced > female default > orice ro.
  Future<void> _selectBestVoice() async {
    try {
      final dynamic raw = await _flutterTts.getVoices;
      if (raw is! List) return;
      final voices = raw
          .whereType<Map>()
          .map((m) => m.map((k, v) => MapEntry(k.toString(), v?.toString() ?? '')))
          .where((v) => (v['locale'] ?? '').toLowerCase().startsWith('ro'))
          .toList();
      if (voices.isEmpty) return;

      int score(Map<String, String> v) {
        final name = (v['name'] ?? '').toLowerCase();
        int s = 0;
        // Voci Google Neural / Network (Android) — cele mai naturale, sună aproape uman
        if (name.contains('network')) s += 100;
        if (name.contains('neural')) s += 100;
        if (name.contains('wavenet')) s += 90;
        // iOS premium/enhanced voices
        if (name.contains('premium')) s += 80;
        if (name.contains('enhanced')) s += 70;
        // Voce feminină pentru basme — Ioana / Carmen / Andreea — sună mai cald
        if (name.contains('ioana')) s += 30;
        if (name.contains('carmen')) s += 25;
        if (name.contains('andreea')) s += 20;
        if (name.contains('female') || name.contains('f00') || name.contains('rod')) s += 10;
        // Penalizează vocile evident sintetice
        if (name.contains('local') && !name.contains('premium')) s -= 5;
        if (name.contains('compact')) s -= 15;
        return s;
      }

      voices.sort((a, b) => score(b).compareTo(score(a)));
      final best = voices.first;
      await _flutterTts.setVoice({
        'name': best['name'] ?? '',
        'locale': best['locale'] ?? 'ro-RO',
      });
    } catch (_) {
      // Dacă API-ul nu suportă getVoices/setVoice, păstrăm vocea default
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _pageController.dispose();
    widget.favoritesProvider.removeListener(_refresh);
    widget.settingsProvider.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    setState(() {});
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
    setState(() => _ttsState = TtsState.playing);
  }

  Future<void> _stopTts() async {
    await _flutterTts.stop();
    setState(() => _ttsState = TtsState.stopped);
  }

  Future<void> _pauseTts() async {
    await _flutterTts.pause();
    setState(() => _ttsState = TtsState.paused);
  }

  void _toggleTts() {
    if (_ttsState == TtsState.playing) {
      _pauseTts();
    } else {
      _speak(widget.story.pages[_currentPage]);
    }
  }

  Future<void> _handleExit() async {
    await _stopTts();
    if (!mounted) return;
    // Dacă userul a terminat povestea și avem rewarded interstitial gata,
    // afișăm un „heads-up" conform politicii AdMob înainte de reclamă.
    if (_reachedEnd &&
        !AdService.adsBlocked &&
        AdService.isRewardedInterstitialReady) {
      final accept = await _showHeadsUpDialog();
      if (!mounted) return;
      if (accept == true) {
        final shown = AdService.showRewardedInterstitialAd(
          onReward: () {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🎉 15 minute fără reclame, mulțumim!'),
                ),
              );
            }
          },
        );
        if (!shown) AdService.showInterstitialAd();
      } else {
        AdService.showInterstitialAd();
      }
    } else {
      AdService.showInterstitialAd();
    }
    if (mounted) Navigator.pop(context);
  }

  Future<bool?> _showHeadsUpDialog() {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reclamă scurtă'),
        content: const Text(
          'Vizionezi un clip scurt și primești 15 minute fără reclame. Continui?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Nu, mulțumesc'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Continuă'),
          ),
        ],
      ),
    );
  }

  void _offerRewardedAdFree() {
    AdService.showRewardedAd(
      onReward: () {
        if (mounted) {
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎉 30 de minute fără reclame, savurează poveștile!'),
            ),
          );
        }
      },
      onUnavailable: () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Clipul nu e disponibil acum, încearcă mai târziu.'),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).scaffoldBackgroundColor == AppColors.nightBackground;
    final isFav = widget.favoritesProvider.isFavorite(widget.story.id);
    final fontSize = widget.settingsProvider.fontSize;
    final totalPages = widget.story.pages.length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      bottomNavigationBar: const SafeArea(
        top: false,
        child: BottomBannerAd(),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.cosmicTop,
              AppColors.cosmicMid,
              AppColors.cosmicBottom,
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      color: isDark ? AppColors.nightText : AppColors.warmBrown,
                    ),
                    onPressed: _handleExit,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          widget.story.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.nightText : AppColors.warmBrown,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Pagina ${_currentPage + 1} din $totalPages',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.nightText.withValues(alpha: 0.6)
                                : AppColors.lightBrown,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: isFav ? Colors.red.shade400 : (isDark ? AppColors.nightText : AppColors.lightBrown),
                    ),
                    onPressed: () => widget.favoritesProvider.toggleFavorite(widget.story.id),
                  ),
                ],
              ),
            ),

            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: ((_currentPage + 1) / totalPages),
                  backgroundColor: isDark
                      ? AppColors.nightCard
                      : AppColors.golden.withValues(alpha: 0.2),
                  color: AppColors.forestGreen,
                  minHeight: 6,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: totalPages,
                onPageChanged: (page) {
                  setState(() => _currentPage = page);
                  if (page == widget.story.pages.length - 1) {
                    _reachedEnd = true;
                    AdService.notifyStoryRead();
                  }
                  if (_ttsState == TtsState.playing) {
                    _flutterTts.stop();
                    Future.delayed(const Duration(milliseconds: 300), () {
                      _speak(widget.story.pages[page]);
                    });
                  }
                },
                itemBuilder: (context, index) {
                  return _buildPage(index, isDark, fontSize);
                },
              ),
            ),

            // Bottom controls
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.nightCard : AppColors.cardBackground,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Previous page
                  _buildControlButton(
                    icon: Icons.arrow_back_ios_rounded,
                    label: 'Inapoi',
                    isDark: isDark,
                    enabled: _currentPage > 0,
                    onTap: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                  // Play/Pause TTS
                  _buildControlButton(
                    icon: _ttsState == TtsState.playing
                        ? Icons.pause_rounded
                        : Icons.volume_up_rounded,
                    label: _ttsState == TtsState.playing ? 'Pauza' : 'Asculta',
                    isDark: isDark,
                    enabled: _ttsInitialized,
                    highlighted: _ttsState == TtsState.playing,
                    onTap: _toggleTts,
                  ),
                  // Stop TTS
                  _buildControlButton(
                    icon: Icons.stop_rounded,
                    label: 'Stop',
                    isDark: isDark,
                    enabled: _ttsState != TtsState.stopped,
                    onTap: _stopTts,
                  ),
                  // Next page
                  _buildControlButton(
                    icon: Icons.arrow_forward_ios_rounded,
                    label: 'Inainte',
                    isDark: isDark,
                    enabled: _currentPage < totalPages - 1,
                    onTap: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildPage(int index, bool isDark, double fontSize) {
    final isFirst = index == 0;
    final isLast = index == widget.story.pages.length - 1;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.glassStroke, width: 1),
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Show emoji and title on first page
          if (isFirst) ...[
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: StoryIllustration(story: widget.story, size: 136),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                widget.story.title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.nightAccent : AppColors.forestGreen,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (widget.story.author != 'Basm popular românesc')
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'de ${widget.story.author}',
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: isDark
                          ? AppColors.nightText.withValues(alpha: 0.6)
                          : AppColors.lightBrown,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 24),
            Center(
              child: Container(
                width: 60,
                height: 3,
                decoration: BoxDecoration(
                  color: AppColors.golden.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Story text
          Text(
            widget.story.pages[index],
            style: TextStyle(
              fontSize: fontSize,
              height: 1.8,
              color: isDark ? AppColors.nightText : AppColors.warmBrown,
              letterSpacing: 0.2,
            ),
          ),

          // End decoration on last page
          if (isLast) ...[
            const SizedBox(height: 32),
            Center(
              child: Container(
                width: 60,
                height: 3,
                decoration: BoxDecoration(
                  color: AppColors.golden.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                '✦ Sfârșit ✦',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                  color: isDark ? AppColors.nightAccent : AppColors.forestGreen,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildRewardedCta(isDark),
            const SizedBox(height: 32),
          ],
        ],
        ),
      ),
    );
  }

  Widget _buildRewardedCta(bool isDark) {
    if (AdService.isAdFreeActive) {
      return Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.forestGreen.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '✓ Fără reclame · ${AdService.adFreeMinutesLeft} min rămase',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.nightAccent : AppColors.forestGreen,
            ),
          ),
        ),
      );
    }
    if (AdService.adsBlocked || !AdService.isRewardedReady) {
      return const SizedBox.shrink();
    }
    return Center(
      child: ElevatedButton.icon(
        onPressed: _offerRewardedAdFree,
        icon: const Icon(Icons.play_circle_fill_rounded),
        label: const Text('30 min fără reclame — vezi un clip'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.forestGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required bool isDark,
    required bool enabled,
    bool highlighted = false,
    required VoidCallback onTap,
  }) {
    final color = !enabled
        ? (isDark ? AppColors.nightText.withValues(alpha: 0.2) : AppColors.lightBrown.withValues(alpha: 0.3))
        : highlighted
            ? AppColors.forestGreen
            : (isDark ? AppColors.nightText : AppColors.warmBrown);

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: highlighted
                  ? AppColors.forestGreen.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: highlighted ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
