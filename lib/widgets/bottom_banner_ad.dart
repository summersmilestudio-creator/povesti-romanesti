import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../services/ad_service.dart';

/// Banner ancorat reutilizabil. Își încarcă propriul [BannerAd] (cu retry
/// exponențial), respectă fereastra de recompensă „fără reclame" și se
/// ascunde curat când nu există reclamă disponibilă.
class BottomBannerAd extends StatefulWidget {
  const BottomBannerAd({super.key});

  @override
  State<BottomBannerAd> createState() => _BottomBannerAdState();
}

class _BottomBannerAdState extends State<BottomBannerAd> {
  BannerAd? _bannerAd;
  bool _isBannerLoaded = false;
  bool _bannerInit = false;
  int _bannerRetry = 0;
  Timer? _bannerRetryTimer;
  static const int _maxBannerRetries = 5;

  @override
  void initState() {
    super.initState();
    AdService.adFreeNotifier.addListener(_onAdsAvailabilityChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_bannerInit) {
      _bannerInit = true;
      _loadBannerAd();
    }
  }

  Future<void> _loadBannerAd() async {
    if (AdService.adsBlocked || !mounted) return;
    final widthDp = MediaQuery.of(context).size.width.truncate();
    final size = await AdService.resolveBannerSize(widthDp);
    if (!mounted || AdService.adsBlocked) return;
    _bannerAd = AdService.createBannerAd(
      size: size,
      onLoaded: () {
        _bannerRetry = 0;
        if (mounted) setState(() => _isBannerLoaded = true);
      },
      onFailed: _onBannerFailed,
    )..load();
  }

  void _onBannerFailed() {
    _bannerAd = null;
    if (mounted) setState(() => _isBannerLoaded = false);
    _bannerRetryTimer?.cancel();
    if (AdService.adsBlocked || _bannerRetry >= _maxBannerRetries) return;
    final delay = Duration(
      seconds: math.min(60, math.pow(2, _bannerRetry + 1).toInt()),
    );
    _bannerRetry++;
    _bannerRetryTimer = Timer(delay, _loadBannerAd);
  }

  void _onAdsAvailabilityChanged() {
    if (AdService.adsBlocked) {
      _bannerRetryTimer?.cancel();
      _bannerAd?.dispose();
      _bannerAd = null;
      if (mounted) setState(() => _isBannerLoaded = false);
    } else if (_bannerAd == null) {
      _bannerRetry = 0;
      _loadBannerAd();
    }
  }

  @override
  void dispose() {
    _bannerRetryTimer?.cancel();
    _bannerAd?.dispose();
    AdService.adFreeNotifier.removeListener(_onAdsAvailabilityChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isBannerLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }
    return Container(
      alignment: Alignment.center,
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
