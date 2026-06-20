import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_service.dart';

/// Android/iOS용 보상형 광고 구현(google_mobile_ads).
///
/// Android·iOS 모두 실제 AdMob 보상형 단위 ID 사용.
/// 앱 ID는 AndroidManifest(APPLICATION_ID) / Info.plist(GADApplicationIdentifier)에 등록 완료.
class MobileAdService implements AdService {
  // 실제 보상형 광고 단위 ID (kaammo / VOID SPARK).
  static const String _androidRewarded =
      'ca-app-pub-8069021496350968/4514671092';
  static const String _iosRewarded =
      'ca-app-pub-8069021496350968/6284219192';

  RewardedAd? _ad;
  bool _initialized = false;

  String get _unitId => Platform.isIOS ? _iosRewarded : _androidRewarded;

  @override
  bool get available => Platform.isAndroid || Platform.isIOS;

  @override
  bool get rewardedReady => _ad != null;

  @override
  Future<void> init() async {
    if (_initialized || !available) return;
    try {
      await MobileAds.instance.initialize();
      _initialized = true;
      loadRewarded();
    } catch (e) {
      debugPrint('MobileAds init failed: $e');
    }
  }

  @override
  void loadRewarded() {
    if (!available || _ad != null) return;
    RewardedAd.load(
      adUnitId: _unitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => _ad = ad,
        onAdFailedToLoad: (err) {
          _ad = null;
          debugPrint('Rewarded load failed: $err');
        },
      ),
    );
  }

  @override
  Future<bool> showRewarded() async {
    final ad = _ad;
    if (ad == null) {
      loadRewarded();
      return false;
    }
    _ad = null;
    final completer = Completer<bool>();
    var earned = false;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        loadRewarded();
        if (!completer.isCompleted) completer.complete(earned);
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        ad.dispose();
        loadRewarded();
        if (!completer.isCompleted) completer.complete(false);
      },
    );

    ad.show(onUserEarnedReward: (_, __) => earned = true);
    return completer.future;
  }

  @override
  void dispose() {
    _ad?.dispose();
    _ad = null;
  }
}

AdService createAdService() => MobileAdService();
