import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'purchase_notifier.dart';

/// Gestionează deblocarea tuturor poveștilor printr-o singură plată.
///
/// Primele [kFreeStoryCount] povești (definite în `data/stories.dart`) sunt
/// mereu gratuite. Restul se deblochează cumpărând produsul non-consumabil
/// [unlockAllId] din Google Play / App Store (preț recomandat: 0,99 lei).
class UnlockService {
  UnlockService._();
  static final UnlockService instance = UnlockService._();

  /// ID-ul produsului non-consumabil. Trebuie creat identic în
  /// Google Play Console și App Store Connect, cu prețul 0,99 RON.
  static const String unlockAllId = 'unlock_all_stories';
  static const String _kUnlockedKey = 'povesti_all_stories_unlocked';

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _sub;
  ProductDetails? _product;
  bool _available = false;
  bool _unlocked = false;

  /// Notifică ecranele când deblocarea devine activă.
  final ValueNotifier<bool> unlockedNotifier = ValueNotifier(false);

  bool get available => _available;
  bool get unlocked => _unlocked;
  ProductDetails? get product => _product;

  /// Prețul localizat din magazin; dacă nu e disponibil, fallback „0,99 lei".
  String get formattedPrice => _product?.price ?? '0,99 lei';

  Future<void> initialize() async {
    await _loadLocalState();
    if (!Platform.isAndroid && !Platform.isIOS) return;
    _available = await _iap.isAvailable();
    if (!_available) return;
    final response = await _iap.queryProductDetails({unlockAllId});
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
    _unlocked = prefs.getBool(_kUnlockedKey) ?? false;
    unlockedNotifier.value = _unlocked;
  }

  Future<void> _onPurchaseUpdated(List<PurchaseDetails> purchases) async {
    for (final p in purchases) {
      // Fiecare serviciu tratează doar produsul lui, ca să nu se confirme
      // de două ori aceeași achiziție (SubscriptionService face la fel).
      if (p.productID != unlockAllId) continue;
      if (p.status == PurchaseStatus.purchased ||
          p.status == PurchaseStatus.restored) {
        await _grantUnlock();
      }
      // Fire ntfy push only on fresh purchase, nu pe restore (utilizator
      // reinstalează — nu mai e o vânzare nouă pentru noi).
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

  Future<void> _grantUnlock() async {
    final prefs = await SharedPreferences.getInstance();
    _unlocked = true;
    unlockedNotifier.value = true;
    await prefs.setBool(_kUnlockedKey, true);
  }

  /// Pornește fluxul de cumpărare. Deblocarea efectivă se aplică din
  /// `purchaseStream` (vezi [_onPurchaseUpdated]).
  Future<bool> buyUnlock() async {
    if (_unlocked) return true;
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
