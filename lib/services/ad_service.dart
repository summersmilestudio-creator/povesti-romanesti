import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  // ---- Ad unit IDs ----
  static const String _androidBannerId = 'ca-app-pub-5549243085914479/3341750336';
  static const String _androidInterstitialId = 'ca-app-pub-5549243085914479/6783744852';
  // Unități noi (creat 2026-05-15) — momentan DOAR Android (iOS nu le are încă)
  static const String _androidRewardedId = 'ca-app-pub-5549243085914479/7195824692';
  static const String _androidRewardedInterstitialId = 'ca-app-pub-5549243085914479/9630416344';
  static const String _androidAppOpenId = 'ca-app-pub-5549243085914479/7191726357';

  static const String _iosBannerId = 'ca-app-pub-5549243085914479/1966190531';
  static const String _iosInterstitialId = 'ca-app-pub-5549243085914479/8469009388';

  static String get bannerAdUnitId =>
      Platform.isIOS ? _iosBannerId : _androidBannerId;
  static String get interstitialAdUnitId =>
      Platform.isIOS ? _iosInterstitialId : _androidInterstitialId;
  // null pe iOS => nu încărcăm/afișăm formatul respectiv pe iOS
  static String? get rewardedAdUnitId =>
      Platform.isAndroid ? _androidRewardedId : null;
  static String? get rewardedInterstitialAdUnitId =>
      Platform.isAndroid ? _androidRewardedInterstitialId : null;
  static String? get appOpenAdUnitId =>
      Platform.isAndroid ? _androidAppOpenId : null;

  // ---- Stare interstitial ----
  static InterstitialAd? _interstitialAd;
  static bool _isInterstitialLoaded = false;
  static int _storiesReadSinceLastAd = 0;
  static DateTime? _lastInterstitialAt;
  static Timer? _periodicTimer;
  static const int _storiesBetweenAds = 1;
  // Cadență mai relaxată: cere reclame mai rar. Mai puține solicitări
  // neumplute => rată de potrivire mai mare + conform politicii AdMob
  // (interstitial-urile prea dese pot duce la limitarea contului).
  // Cadență agresivă (cerere user 2026-06-14): venit maxim din reclame.
  static const Duration _minTimeBetweenAds = Duration(seconds: 90);
  // Timer-ul periodic forțează un interstitial chiar dacă userul nu termină
  // o poveste — mai des = mai multe afișări.
  static const Duration _periodicInterval = Duration(minutes: 3);

  // ---- Retry cu backoff exponențial (crește rata de potrivire) ----
  // O solicitare care eșua era abandonată instant. Cu retry, multe
  // solicitări „neumplute" ajung umplute la a 2-a/3-a încercare.
  static const int _maxLoadRetries = 5;
  static int _interstitialRetry = 0;
  static int _rewardedRetry = 0;
  static int _rewardedInterstitialRetry = 0;
  static int _appOpenRetry = 0;
  static Timer? _interstitialRetryTimer;
  static Timer? _rewardedRetryTimer;
  static Timer? _rewardedInterstitialRetryTimer;
  static Timer? _appOpenRetryTimer;

  /// Backoff: 2s, 4s, 8s, 16s, 32s, max 60s.
  static Duration _backoff(int attempt) =>
      Duration(seconds: math.min(60, math.pow(2, attempt + 1).toInt()));

  // ---- Recompensă: fereastră temporară fără reclame ----
  static DateTime? _adFreeUntil;
  static Timer? _adFreeTimer;

  /// Recompensă pentru rewarded video (opt-in).
  static const Duration rewardedAdFreeDuration = Duration(minutes: 30);

  /// Recompensă pentru rewarded interstitial (heads-up).
  static const Duration rewardedInterstitialAdFreeDuration = Duration(minutes: 15);

  /// True dacă userul e în fereastra de recompensă „fără reclame".
  static bool get isAdFreeActive =>
      _adFreeUntil != null && DateTime.now().isBefore(_adFreeUntil!);

  /// Reclamele sunt blocate doar în fereastra de recompensă „fără reclame".
  /// (Monetizare exclusiv prin reclame — nu există abonament fără reclame.)
  static bool get adsBlocked => isAdFreeActive;

  /// Notifică UI-ul (banner) când starea „fără reclame" se schimbă.
  static final ValueNotifier<bool> adFreeNotifier = ValueNotifier(false);

  // ---- Stare fullscreen (evită suprapunerea app-open peste interstitial etc.) ----
  static bool _showingFullScreenAd = false;

  // ====================================================================
  // INIT
  // ====================================================================
  static Future<void> initialize() async {
    await MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(
        tagForChildDirectedTreatment: TagForChildDirectedTreatment.unspecified,
        tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.unspecified,
        maxAdContentRating: MaxAdContentRating.t,
      ),
    );
    await MobileAds.instance.initialize();
    loadInterstitialAd();
    loadRewardedAd();
    loadRewardedInterstitialAd();
    loadAppOpenAd();
    startPeriodicInterstitial();
  }

  // ====================================================================
  // PERIODIC INTERSTITIAL (existent)
  // ====================================================================
  static void startPeriodicInterstitial() {
    _periodicTimer?.cancel();
    if (adsBlocked) return;
    _periodicTimer = Timer.periodic(_periodicInterval, (_) {
      _tryShowInterstitial(force: true);
    });
  }

  static void stopPeriodicInterstitial() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
  }

  static void notifyStoryRead() {
    _storiesReadSinceLastAd++;
  }

  static bool _shouldShowInterstitial({bool force = false}) {
    if (!force && _storiesReadSinceLastAd < _storiesBetweenAds) return false;
    if (_lastInterstitialAt != null &&
        DateTime.now().difference(_lastInterstitialAt!) < _minTimeBetweenAds) {
      return false;
    }
    return true;
  }

  static void _tryShowInterstitial({bool force = false}) {
    if (adsBlocked || _showingFullScreenAd) return;
    if (!_shouldShowInterstitial(force: force)) return;
    if (_isInterstitialLoaded && _interstitialAd != null) {
      _lastInterstitialAt = DateTime.now();
      _storiesReadSinceLastAd = 0;
      _showingFullScreenAd = true;
      _interstitialAd!.show();
    } else {
      loadInterstitialAd();
    }
  }

  // ====================================================================
  // BANNER (existent)
  // ====================================================================
  /// Dimensiune banner adaptiv ancorat — umple mai bine inventarul și are
  /// eCPM mai mare decât bannerul fix 320x50. Fallback la bannerul standard
  /// dacă platforma nu poate calcula dimensiunea adaptivă.
  static Future<AdSize> resolveBannerSize(int widthDp) async {
    final adaptive = await AdSize.getAnchoredAdaptiveBannerAdSize(
      Orientation.portrait,
      widthDp,
    );
    return adaptive ?? AdSize.banner;
  }

  /// Creează un banner (adaptiv dacă se trimite [size]) cu callback-uri de
  /// încărcare. Eșecul e raportat prin [onFailed] ca să poată fi reîncercat
  /// cu backoff (vezi main.dart) — esențial pentru rata de potrivire.
  static BannerAd createBannerAd({
    AdSize size = AdSize.banner,
    VoidCallback? onLoaded,
    VoidCallback? onFailed,
  }) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => onLoaded?.call(),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          onFailed?.call();
        },
      ),
    );
  }

  // ====================================================================
  // INTERSTITIAL (existent)
  // ====================================================================
  static void loadInterstitialAd() {
    if (adsBlocked) return;
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialRetry = 0;
          _interstitialRetryTimer?.cancel();
          _interstitialAd = ad;
          _isInterstitialLoaded = true;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isInterstitialLoaded = false;
              _showingFullScreenAd = false;
              loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _isInterstitialLoaded = false;
              _showingFullScreenAd = false;
              loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isInterstitialLoaded = false;
          _interstitialRetryTimer?.cancel();
          if (adsBlocked || _interstitialRetry >= _maxLoadRetries) return;
          final delay = _backoff(_interstitialRetry++);
          _interstitialRetryTimer = Timer(delay, loadInterstitialAd);
        },
      ),
    );
  }

  static void showInterstitialAd() {
    _tryShowInterstitial();
  }

  // ====================================================================
  // REWARDED VIDEO (nou) — opt-in: userul alege să vadă un clip
  // ====================================================================
  static RewardedAd? _rewardedAd;
  static bool _isRewardedLoaded = false;

  static void loadRewardedAd() {
    final id = rewardedAdUnitId;
    if (id == null || adsBlocked) return;
    RewardedAd.load(
      adUnitId: id,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedRetry = 0;
          _rewardedRetryTimer?.cancel();
          _rewardedAd = ad;
          _isRewardedLoaded = true;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isRewardedLoaded = false;
              _showingFullScreenAd = false;
              loadRewardedAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _isRewardedLoaded = false;
              _showingFullScreenAd = false;
              loadRewardedAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isRewardedLoaded = false;
          _rewardedRetryTimer?.cancel();
          if (adsBlocked || _rewardedRetry >= _maxLoadRetries) return;
          final delay = _backoff(_rewardedRetry++);
          _rewardedRetryTimer = Timer(delay, loadRewardedAd);
        },
      ),
    );
  }

  static bool get isRewardedReady => _isRewardedLoaded && _rewardedAd != null;

  /// Afișează rewarded video. Apelează [onReward] dacă userul primește recompensa.
  /// Întoarce false dacă reclama nu e disponibilă (nu s-a afișat nimic).
  static bool showRewardedAd({VoidCallback? onReward, VoidCallback? onUnavailable}) {
    if (!isRewardedReady || _showingFullScreenAd) {
      loadRewardedAd();
      onUnavailable?.call();
      return false;
    }
    _showingFullScreenAd = true;
    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        _grantAdFree(rewardedAdFreeDuration);
        onReward?.call();
      },
    );
    return true;
  }

  // ====================================================================
  // REWARDED INTERSTITIAL (nou) — necesită heads-up înainte (vezi UI)
  // ====================================================================
  static RewardedInterstitialAd? _rewardedInterstitialAd;
  static bool _isRewardedInterstitialLoaded = false;

  static void loadRewardedInterstitialAd() {
    final id = rewardedInterstitialAdUnitId;
    if (id == null || adsBlocked) return;
    RewardedInterstitialAd.load(
      adUnitId: id,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedInterstitialRetry = 0;
          _rewardedInterstitialRetryTimer?.cancel();
          _rewardedInterstitialAd = ad;
          _isRewardedInterstitialLoaded = true;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isRewardedInterstitialLoaded = false;
              _showingFullScreenAd = false;
              loadRewardedInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _isRewardedInterstitialLoaded = false;
              _showingFullScreenAd = false;
              loadRewardedInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isRewardedInterstitialLoaded = false;
          _rewardedInterstitialRetryTimer?.cancel();
          if (adsBlocked ||
              _rewardedInterstitialRetry >= _maxLoadRetries) {
            return;
          }
          final delay = _backoff(_rewardedInterstitialRetry++);
          _rewardedInterstitialRetryTimer =
              Timer(delay, loadRewardedInterstitialAd);
        },
      ),
    );
  }

  static bool get isRewardedInterstitialReady =>
      _isRewardedInterstitialLoaded && _rewardedInterstitialAd != null;

  /// IMPORTANT: politica AdMob cere un ecran de „heads-up" ÎNAINTE de afișare.
  /// Apelează această metodă DOAR după ce userul a confirmat (vezi reading_screen).
  static bool showRewardedInterstitialAd({VoidCallback? onReward}) {
    if (!isRewardedInterstitialReady || _showingFullScreenAd) {
      loadRewardedInterstitialAd();
      return false;
    }
    _showingFullScreenAd = true;
    _rewardedInterstitialAd!.show(
      onUserEarnedReward: (ad, reward) {
        _grantAdFree(rewardedInterstitialAdFreeDuration);
        onReward?.call();
      },
    );
    return true;
  }

  // ====================================================================
  // APP OPEN (nou) — la revenirea în prim-plan, max 1 / cooldown
  // ====================================================================
  static AppOpenAd? _appOpenAd;
  static bool _isAppOpenLoaded = false;
  static DateTime? _appOpenLoadTime;
  static DateTime? _lastAppOpenShownAt;
  static const Duration _appOpenCooldown = Duration(minutes: 2);
  static const Duration _appOpenMaxCacheAge = Duration(hours: 4);

  static void loadAppOpenAd() {
    final id = appOpenAdUnitId;
    if (id == null || adsBlocked) return;
    AppOpenAd.load(
      adUnitId: id,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenRetry = 0;
          _appOpenRetryTimer?.cancel();
          _appOpenAd = ad;
          _isAppOpenLoaded = true;
          _appOpenLoadTime = DateTime.now();
        },
        onAdFailedToLoad: (error) {
          _isAppOpenLoaded = false;
          _appOpenRetryTimer?.cancel();
          if (adsBlocked || _appOpenRetry >= _maxLoadRetries) return;
          final delay = _backoff(_appOpenRetry++);
          _appOpenRetryTimer = Timer(delay, loadAppOpenAd);
        },
      ),
    );
  }

  static bool get _isAppOpenAvailable {
    if (!_isAppOpenLoaded || _appOpenAd == null) return false;
    if (_appOpenLoadTime == null) return false;
    return DateTime.now().difference(_appOpenLoadTime!) < _appOpenMaxCacheAge;
  }

  /// Apelat la revenirea aplicației în prim-plan (vezi main.dart).
  static void onAppResumed() {
    if (adsBlocked || _showingFullScreenAd) {
      if (!_isAppOpenAvailable) loadAppOpenAd();
      return;
    }
    if (_lastAppOpenShownAt != null &&
        DateTime.now().difference(_lastAppOpenShownAt!) < _appOpenCooldown) {
      return;
    }
    if (!_isAppOpenAvailable) {
      loadAppOpenAd();
      return;
    }
    _showingFullScreenAd = true;
    _lastAppOpenShownAt = DateTime.now();
    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _isAppOpenLoaded = false;
        _showingFullScreenAd = false;
        loadAppOpenAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _isAppOpenLoaded = false;
        _showingFullScreenAd = false;
        loadAppOpenAd();
      },
    );
    _appOpenAd!.show();
  }

  // ====================================================================
  // RECOMPENSĂ: gestiune fereastră „fără reclame"
  // ====================================================================
  static void _grantAdFree(Duration duration) {
    final newUntil = DateTime.now().add(duration);
    if (_adFreeUntil == null || newUntil.isAfter(_adFreeUntil!)) {
      _adFreeUntil = newUntil;
    }
    adFreeNotifier.value = true;
    stopPeriodicInterstitial();
    _adFreeTimer?.cancel();
    final remaining = _adFreeUntil!.difference(DateTime.now());
    _adFreeTimer = Timer(remaining, _expireAdFree);
  }

  static void _expireAdFree() {
    _adFreeUntil = null;
    _adFreeTimer?.cancel();
    _adFreeTimer = null;
    adFreeNotifier.value = false;
    loadInterstitialAd();
    loadRewardedAd();
    loadRewardedInterstitialAd();
    loadAppOpenAd();
    startPeriodicInterstitial();
  }

  /// Minute rămase din fereastra de recompensă (0 dacă nu e activă).
  static int get adFreeMinutesLeft {
    if (!isAdFreeActive) return 0;
    return _adFreeUntil!.difference(DateTime.now()).inMinutes + 1;
  }
}
