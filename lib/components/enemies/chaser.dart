import 'dart:ui';

import '../../config/game_config.dart';
import '../../config/palette.dart';
import '../neon.dart';
import 'enemy.dart';

/// Chaser — 플레이어(코어)를 지속적으로 추적한다.
class Chaser extends Enemy {
  Chaser({required super.position})
      : super(
          radius: GameConfig.chaserRadius,
          maxHp: GameConfig.chaserHp,
        );

  double _spin = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _spin += dt * 2.0;

    final dir = game.core.position - position;
    if (dir.length2 > 1) {
      position += dir.normalized() * GameConfig.chaserSpeed * dt;
    }
  }

  @override
  void render(Canvas canvas) {
    final c = Offset(size.x / 2, size.y / 2);
    // 추적자 — 회전하는 사각형(다이아몬드).
    Neon.polygon(
      canvas,
      c,
      radius,
      4,
      Palette.corrupt,
      glow: Palette.corruptGlow,
      rotation: _spin,
      blur: false,
    );
  }
}
