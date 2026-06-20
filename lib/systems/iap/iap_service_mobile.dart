import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../save.dart';
import 'iap_service.dart';

/// Android/iOS용 인앱결제 구현(in_app_purchase).
/// 구매 완료/복원 시 [SaveSystem.deliverPurchase]로 보상을 지급한다.
class MobileIapService implements IapService {
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _sub;
  final Map<String, ProductDetails> _details = {};

  bool _available = false;
  int _tick = 0;

  @override
  bool get available => _available;

  @override
  int get changeTick => _tick;

  @override
  String? priceOf(String id) => _details[id]?.price;

  @override
  Future<void> init() async {
    try {
      _available = await _iap.isAvailable();
      if (!_available) return;

      _sub = _iap.purchaseStream.listen(
        _onPurchases,
        onError: (e) => debugPrint('IAP stream error: $e'),
      );

      final ids = IapCatalog.all.map((p) => p.id).toSet();
      final resp = await _iap.queryProductDetails(ids);
      for (final p in resp.productDetails) {
        _details[p.id] = p;
      }
      // 비소비성 권한 복원.
      await _iap.restorePurchases();
    } catch (e) {
      debugPrint('IAP init failed: $e');
      _available = false;
    }
  }

  @override
  Future<void> buy(IapProduct product) async {
    final pd = _details[product.id];
    if (pd == null) return;
    final param = PurchaseParam(productDetails: pd);
    try {
      if (product.kind == IapKind.consumableShards) {
        await _iap.buyConsumable(purchaseParam: param);
      } else {
        await _iap.buyNonConsumable(purchaseParam: param);
      }
    } catch (e) {
      debugPrint('IAP buy failed: $e');
    }
  }

  @override
  Future<void> restore() async {
    try {
      await _iap.restorePurchases();
    } catch (e) {
      debugPrint('IAP restore failed: $e');
    }
  }

  Future<void> _onPurchases(List<PurchaseDetails> purchases) async {
    for (final pd in purchases) {
      if (pd.status == PurchaseStatus.purchased ||
          pd.status == PurchaseStatus.restored) {
        await SaveSystem.instance.deliverPurchase(pd.productID);
        _tick++;
      }
      if (pd.pendingCompletePurchase) {
        await _iap.completePurchase(pd);
      }
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
  }
}

IapService createIapService() => MobileIapService();
