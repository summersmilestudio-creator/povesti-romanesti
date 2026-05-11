import 'dart:io' show Platform;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'subscription_service.dart';

class AdService {
  static const String _androidBannerId = 'ca-app-pub-5549243085914479/3341750336';
  static const String _androidInterstitialId = 'ca-app-pub-5549243085914479/6783744852';
  static const String _iosBannerId = 'ca-app-pub-5549243085914479/1966190531';
  static const String _iosInterstitialId = 'ca-app-pub-5549243085914479/8469009388';

  static String get bannerAdUnitId =>
      Platform.isIOS ? _iosBannerId : _androidBannerId;
  static String get interstitialAdUnitId =>
      Platform.isIOS ? _iosInterstitialId : _androidInterstitialId;

  static InterstitialAd? _interstitialAd;
  static bool _isInterstitialLoaded = false;
  static int _storiesReadSinceLastAd = 0;
  static DateTime? _lastInterstitialAt;
  static const int _storiesBetweenAds = 3;
  static const Duration _minTimeBetweenAds = Duration(minutes: 3);

  static Future<void> initialize() async {
    if (SubscriptionService.instance.noAds) return;
    await MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(
        tagForChildDirectedTreatment: TagForChildDirectedTreatment.unspecified,
        tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.unspecified,
        maxAdContentRating: MaxAdContentRating.t,
      ),
    );
    await MobileAds.instance.initialize();
    loadInterstitialAd();
  }

  static void notifyStoryRead() {
    _storiesReadSinceLastAd++;
  }

  static bool _shouldShowInterstitial() {
    if (_storiesReadSinceLastAd < _storiesBetweenAds) return false;
    if (_lastInterstitialAt != null &&
        DateTime.now().difference(_lastInterstitialAt!) < _minTimeBetweenAds) {
      return false;
    }
    return true;
  }

  static BannerAd? createBannerAdIfAllowed() {
    if (SubscriptionService.instance.noAds) return null;
    return createBannerAd();
  }

  static BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );
  }

  static void loadInterstitialAd() {
    if (SubscriptionService.instance.noAds) return;
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoaded = true;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isInterstitialLoaded = false;
              loadInterstitialAd(); // Pre-load next one
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _isInterstitialLoaded = false;
              loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isInterstitialLoaded = false;
        },
      ),
    );
  }

  static void showInterstitialAd() {
    if (SubscriptionService.instance.noAds) return;
    if (!_shouldShowInterstitial()) return;
    if (_isInterstitialLoaded && _interstitialAd != null) {
      _lastInterstitialAt = DateTime.now();
      _storiesReadSinceLastAd = 0;
      _interstitialAd!.show();
    }
  }
}
