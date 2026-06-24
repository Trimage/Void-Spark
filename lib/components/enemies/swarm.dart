import 'dart:ui';

import 'package:flame/components.dart';

import '../../config/game_config.dart';
import '../../config/palette.dart';
import '../neon.dart';
import 'enemy.dart';

/// Swarm — 작고 빠른 잡몹. 편대(여러 마리)로 함께 스폰되며,
/// 가볍게 플레이어 쪽으로 휘어 들어온다. 스폰 묶음은 Spawner가 담당.
class Swarm extends Enemy {
  Swarm({required super.position})
      : super(
          radius: GameConfig.swarmRadius,
          maxHp: GameConfig.swarmHp,
        );

  @override
  void update(double dt) {
    super.update(dt);
    // 코어 방향으로 약하게 유도되는 빠른 직진.
    final toCore = (game.core.position - position);
    final dir = toCore.length2 > 1 ? toCore.normalized() : Vector2(0, 1);
    position += dir * GameConfig.swarmSpeed * dt;
  }

  @override
  void render(Canvas canvas) {
    final c = Offset(size.x / 2, size.y / 2);
    Neon.circle(
      canvas,
      c,
      radius,
      Palette.corrupt,
      glow: Palette.corruptGlow,
      glowScale: 2.0,
      blur: false,
    );
  }
}
