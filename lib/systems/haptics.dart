import 'package:flutter/foundation.dart';
import 'package:vibration/vibration.dart';

/// 햅틱(진동) 래퍼. 주요 이벤트에만 사용한다(피격/보스/폭탄).
/// 웹 등 미지원 환경에서는 자동으로 무음 처리된다.
class HapticsSystem {
  bool enabled = true;
  bool _hasVibrator = false;

  Future<void> init() async {
    if (kIsWeb) return; // 웹은 미지원.
    try {
      _hasVibrator = await Vibration.hasVibrator();
    } catch (_) {
      _hasVibrator = false;
    }
  }

  void _buzz(int ms) {
    if (!enabled || !_hasVibrator) return;
    try {
      Vibration.vibrate(duration: ms);
    } catch (_) {}
  }

  void hit() => _buzz(70);
  void boss() => _buzz(140);
  void bomb() => _buzz(50);
}
