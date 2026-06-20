import 'dart:math' as math;

import 'package:flame/components.dart';

import '../config/game_config.dart';

/// Intensity(강도) 시스템 — 생존 시간이 길수록 난이도가 끝없이 상승한다.
/// 0→1 램프 구간 이후에도 '오버드라이브'로 스폰·적 속도가 계속 가팔라진다.
class IntensitySystem extends Component {
  double elapsed = 0;

  /// 무한 상승하는 난이도 계수(0=시작). 1을 넘으면 오버드라이브.
  double get difficulty => elapsed / GameConfig.intensityRampSeconds;

  /// HUD 게이지용 정규값(0~1).
  double get value => difficulty.clamp(0.0, 1.0);

  /// 오버드라이브 진입 여부(생존이 충분히 길어진 상태).
  bool get overdrive => difficulty > 1.0;

  /// 현재 강도에 맞춘 스폰 간격(초). 오버드라이브에서도 하한까지 계속 짧아진다.
  double get spawnInterval {
    final t = value;
    var interval = GameConfig.baseSpawnInterval +
        (GameConfig.minSpawnInterval - GameConfig.baseSpawnInterval) * t;
    if (overdrive) {
      interval /= (1 + (difficulty - 1) * GameConfig.overdriveSpawnGain);
    }
    return interval.clamp(
      GameConfig.absoluteMinSpawnInterval,
      GameConfig.baseSpawnInterval,
    );
  }

  /// 적/탄의 이동·발사 속도 배율(오버드라이브에서 1.0 이상으로 상승).
  double get enemySpeedMul {
    if (!overdrive) return 1.0;
    final mul = 1 + (difficulty - 1) * GameConfig.overdriveSpeedGain;
    return math.min(mul, GameConfig.enemySpeedMaxMul);
  }

  void reset() => elapsed = 0;

  @override
  void update(double dt) {
    elapsed += dt;
  }
}
