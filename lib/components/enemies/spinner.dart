import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import '../../config/game_config.dart';
import '../../config/palette.dart';
import '../neon.dart';
import 'enemy.dart';

/// Spinner — 천천히 이동하며 회전하는 나선 탄막을 흩뿌린다.
class Spinner extends Enemy {
  Spinner({required super.position})
      : super(
          radius: GameConfig.spinnerRadius,
          maxHp: GameConfig.spinnerHp,
        );

  double _fireTimer = 0;
  double _angle = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _angle += GameConfig.spinnerSpinSpeed * dt;
    position.y += GameConfig.spinnerSpeed * dt;

    if (position.y > radius) {
      _fireTimer += dt;
      if (_fireTimer >= GameConfig.spinnerFireInterval) {
        _fireTimer = 0;
        _emit();
      }
    }

    if (isOffBottom(GameConfig.enemyDespawnMargin)) {
      removeFromParent();
    }
  }

  /// 현재 각도를 기준으로 균등 분할된 방향으로 탄을 발사(나선 효과).
  void _emit() {
    final arms = GameConfig.spinnerArms;
    for (var i = 0; i < arms; i++) {
      final a = _angle + (i / arms) * 2 * math.pi;
      final dir = Vector2(math.cos(a), math.sin(a));
      game.spawnEnemyBullet(
        position.clone(),
        dir * GameConfig.spinnerBulletSpeed,
      );
    }
  }

  @override
  void render(Canvas canvas) {
    final c = Offset(size.x / 2, size.y / 2);
    // 오각별 느낌의 회전 다각형.
    Neon.polygon(
      canvas,
      c,
      radius,
      5,
      Palette.corrupt,
      glow: Palette.corruptGlow,
      rotation: _angle,
      blur: false,
    );
  }
}
