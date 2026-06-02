import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'purchase_notifier.dart';

class SubscriptionService {
  SubscriptionService._();
  static final SubscriptionService instance = SubscriptionService._();

  static const String noAdsMonthlyId = 'noads_monthly';
  static const String _kNoAdsKey = 'povesti_no_ads_monthly';
  static const String _kNoAdsExpiresAtKey = 'povesti_no_ads_expires_at';

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _sub;
  ProductDetails? _product;
  bool _available = false;
  bool _noAds = false;
  DateTime? _expiresAt;

  final ValueNotifier<bool> noAdsNotifier = ValueNotifier(false);

  bool get available => _available;
  bool get noAds => _noAds;
  ProductDetails? get product => _product;
  String get formattedPrice => _product?.price ?? '25 RON';

  Future<void> initialize() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return;
    }
    await _loadLocalState();
    _available = await _iap.isAvailable();
    if (!_available) return;
    final response = await _iap.queryProductDetails({noAdsMonthlyId});
    if (response.productDetails.isNotEmpty) {
      _product = response.productDetails.first;
    }
    _sub = _iap.purchaseStream.listen(
      _onPurchaseUpdated,
      onError: (_) {},
      onDone: () => _sub?.cancel(),
    );
    await _iap.restorePurchases();
  }

  Future<void> _loadLocalState() async {
    final prefs = await SharedPreferences.getInstance();
    final flag = prefs.getBool(_kNoAdsKey) ?? false;
    final expiresMs = prefs.getInt(_kNoAdsExpiresAtKey);
    if (expiresMs != null) {
      _expiresAt = DateTime.fromMillisecondsSinceEpoch(expiresMs);
    }
    if (flag && _expiresAt != null && DateTime.now().isBefore(_expiresAt!)) {
      _noAds = true;
    } else {
      _noAds = false;
    }
    noAdsNotifier.value = _noAds;
  }

  Future<void> _onPurchaseUpdated(List<PurchaseDetails> purchases) async {
    for (final p in purchases) {
      // Tratează doar produsul propriu. Alte produse (ex. deblocarea
      // poveștilor) sunt confirmate de serviciul lor, ca să nu se apeleze
      // completePurchase de două ori pe aceeași achiziție.
      if (p.productID != noAdsMonthlyId) continue;
      if (p.status == PurchaseStatus.purchased ||
          p.status == PurchaseStatus.restored) {
        await _grantNoAds();
      }
      if (p.status == PurchaseStatus.purchased) {
        unawaited(PurchaseNotifier.notifyPurchase(
          packageName: 'ro.povestiromanesti.app',
          purchase: p,
        ));
      }
      if (p.pendingCompletePurchase) {
        await _iap.completePurchase(p);
      }
    }
  }

  Future<void> _grantNoAds() async {
    final prefs = await SharedPreferences.getInstance();
    _noAds = true;
    _expiresAt = DateTime.now().add(const Duration(days: 32));
    noAdsNotifier.value = true;
    await prefs.setBool(_kNoAdsKey, true);
    await prefs.setInt(
      _kNoAdsExpiresAtKey,
      _expiresAt!.millisecondsSinceEpoch,
    );
  }

  Future<bool> buyNoAds() async {
    if (!_available || _product == null) return false;
    final param = PurchaseParam(productDetails: _product!);
    return _iap.buyNonConsumable(purchaseParam: param);
  }

  Future<void> restore() async {
    if (!_available) return;
    await _iap.restorePurchases();
  }

  void dispose() {
    _sub?.cancel();
  }
}
