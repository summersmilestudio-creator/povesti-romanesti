import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_purchase/in_app_purchase.dart';

/// Fire-and-forget notifier — POSTs to the smartfactura.ro IAP webhook
/// whenever a purchase completes, so we get an ntfy push without waiting
/// for Google's RTDN (which can lag minutes or skip altogether on dev test).
///
/// Errors are intentionally swallowed: the user already paid, we just want
/// best-effort notification on top of it.
class PurchaseNotifier {
  PurchaseNotifier._();

  static const String _endpoint =
      'https://smartfactura.ro/api-iap-notify.php';
  static const String _secret =
      'sf_iap_3c8a1d92_b7f64e25_a019';

  /// [packageName] e folosit pentru a mapa achiziția la app în webhook.
  /// Cere o valoare explicită ca să nu depindem de PackageInfo (1 plugin
  /// mai puțin) și ca să poată trimite și de pe iOS unde nu există packageName.
  static Future<void> notifyPurchase({
    required String packageName,
    required PurchaseDetails purchase,
  }) async {
    if (purchase.status != PurchaseStatus.purchased) return;
    final body = <String, dynamic>{
      'source':        'app',
      'platform':       Platform.isIOS ? 'ios' : 'android',
      'package':        packageName,
      'product_id':     purchase.productID,
      'order_id':       purchase.purchaseID ?? '',
      'purchase_token': purchase.verificationData.serverVerificationData,
      'transaction_ts': purchase.transactionDate ?? '',
    };
    try {
      await http
          .post(
            Uri.parse('$_endpoint?token=$_secret'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 5));
    } catch (e) {
      // Webhook offline / DNS lag — nu blocăm achiziția.
      debugPrint('[PurchaseNotifier] notify failed: $e');
    }
  }
}
