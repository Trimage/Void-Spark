import 'dart:ui';

import 'package:flame/components.dart';

import '../config/game_config.dart';
import '../void_spark_game.dart';

/// 코어 뒤에 남는 잔상(트레일). 스킨 색으로 그려져 스킨마다 다른 느낌을 준다.
/// 코어의 최근 위치를 모아 점점 옅어지는 원으로 렌더(블러 없이 저비용).
class CoreTrail extends PositionComponent with HasGameReference<VoidSparkGame> {
  CoreTrail() : super(priority: 9);

  final List<Vector2> _pts = [];
  static final Paint _paint = Paint();

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
  }

  void reset() => _pts.clear();

  @override
  void update(double dt) {
    _pts.add(game.core.position.clone());
    final maxLen = game.skin.trailLength;
    while (_pts.length > maxLen) {
      _pts.removeAt(0);
    }
  }

  @override
  void render(Canvas canvas) {
    final n = _pts.length;
    if (n < 2) return;
    final glow = game.skin.glow;
    for (var i = 0; i < n; i++) {
      final f = i / (n - 1); // 0=가장 오래됨, 1=최신(코어 근처)
      _paint.color = glow.withValues(alpha: 0.22 * f);
      canvas.drawCircle(
        Offset(_pts[i].x, _pts[i].y),
        GameConfig.coreRadius * 0.55 * f,
        _paint,
      );
    }
  }
}
