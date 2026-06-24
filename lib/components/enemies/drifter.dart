import 'dart:ui';

import 'package:flame/components.dart';

import '../../config/game_config.dart';
import '../../config/palette.dart';
import '../neon.dart';
import 'enemy.dart';

/// Drifter — 직선으로 느리게 진입하는 기본 잡몹.
/// 위에서 아래로(또는 주어진 [velocity] 방향) 등속 직진한다.
class Drifter extends Enemy {
  Drifter({required super.position, Vector2? velocity})
      : velocity = velocity ?? Vector2(0, GameConfig.drifterSpeed),
        super(
          radius: GameConfig.drifterRadius,
          maxHp: GameConfig.drifterHp,
        );

  final Vector2 velocity;
  double _spin = 0;

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;
    _spin += dt * 0.8;

    if (isOffBottom(GameConfig.enemyDespawnMargin)) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final c = Offset(size.x / 2, size.y / 2);
    // 손상된 도형 — 삼각형(가장 단순한 잡몹 형태)으로 표현.
    Neon.polygon(
      canvas,
      c,
      radius,
      3,
      Palette.corrupt,
      glow: Palette.corruptGlow,
      rotation: _spin,
      blur: false,
    );
  }
}
