import 'dart:math' as math;
import 'dart:ui';

import '../config/game_config.dart';

/// 화면 연출(손맛)을 모아 관리하는 단순 상태 객체.
/// 게임 트리의 update가 멈추는 히트스톱 중에도 동작해야 하므로
/// Component가 아니라 게임이 직접 실시간으로 갱신한다([updateRealtime]).
class JuiceSystem {
  final math.Random _rng = math.Random();

  /// 화면 흔들림 강도 배율(설정 슬라이더; 0이면 흔들림 없음).
  double intensityScale = 1.0;

  /// 가장자리 붉은 플래시 사용 여부(번쩍임 줄이기 설정 시 false).
  bool flashEnabled = true;

  double _shakeTime = 0;
  double _shakeMag = 0;
  double _hitStop = 0;
  double _edgeFlash = 0;
  double _slowMo = 0;

  /// 트리 업데이트를 완전히 멈춰야 하는가(히트스톱).
  bool get frozen => _hitStop > 0;

  /// close-call 슬로우모 등으로 인한 전역 시간 배율.
  double get globalTimeScale =>
      _slowMo > 0 ? GameConfig.closeCallTimeScale : 1.0;

  /// 현재 프레임의 화면 흔들림 오프셋(강도 설정 반영).
  Offset get shakeOffset {
    if (_shakeTime <= 0 || intensityScale <= 0) return Offset.zero;
    final amt =
        _shakeMag * intensityScale * (_shakeTime / GameConfig.shakeDuration);
    return Offset(
      (_rng.nextDouble() * 2 - 1) * amt,
      (_rng.nextDouble() * 2 - 1) * amt,
    );
  }

  /// 가장자리 붉은 플래시 알파(0~1).
  double get edgeFlashAlpha =>
      (_edgeFlash / GameConfig.edgeFlashDuration).clamp(0.0, 1.0);

  // ---- 트리거 ----

  void shake(double magnitude) {
    // 더 큰 흔들림이 들어오면 덮어쓴다.
    if (magnitude >= _shakeMag || _shakeTime <= 0) {
      _shakeMag = magnitude;
    }
    _shakeTime = GameConfig.shakeDuration;
  }

  void hitStop(double duration) {
    if (duration > _hitStop) _hitStop = duration;
  }

  void edgeFlash() {
    if (!flashEnabled) return;
    _edgeFlash = GameConfig.edgeFlashDuration;
  }

  void slowMo(double duration) {
    if (duration > _slowMo) _slowMo = duration;
  }

  void reset() {
    _shakeTime = _shakeMag = _hitStop = _edgeFlash = _slowMo = 0;
  }

  /// 실시간(프레임) dt로 모든 연출 타이머를 감쇠시킨다.
  void updateRealtime(double dt) {
    if (_shakeTime > 0) _shakeTime -= dt;
    if (_hitStop > 0) _hitStop -= dt;
    if (_edgeFlash > 0) _edgeFlash -= dt;
    if (_slowMo > 0) _slowMo -= dt;
  }
}
