import 'dart:ui';

import '../../config/game_config.dart';
import '../../config/palette.dart';
import '../neon.dart';
import 'enemy.dart';

/// Turret — 천천히 내려오며 플레이어를 조준해 단발을 쏜다.
class Turret extends Enemy {
  Turret({required super.position})
      : super(
          radius: GameConfig.turretRadius,
          maxHp: GameConfig.turretHp,
        );

  double _fireTimer = 0;
  double _spin = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _spin += dt * 0.6;
    // 천천히 아래로 진입.
    position.y += GameConfig.turretSpeed * dt;

    // 화면 안에 들어온 뒤부터 조준 사격.
    if (position.y > radius) {
      _fireTimer += dt;
      if (_fireTimer >= GameConfig.turretFireInterval) {
        _fireTimer = 0;
        _fireAtCore();
      }
    }

    if (isOffBottom(GameConfig.enemyDespawnMargin)) {
      removeFromParent();
    }
  }

  void _fireAtCore() {
    final dir = game.core.position - position;
    if (dir.length2 == 0) return;
    game.spawnEnemyBullet(
      position.clone(),
      dir.normalized() * GameConfig.turretBulletSpeed,
    );
  }

  @override
  void render(Canvas canvas) {
    final c = Offset(size.x / 2, size.y / 2);
    // 육각형 + 내부 코어 점(포신 느낌).
    Neon.polygon(
      canvas,
      c,
      radius,
      6,
      Palette.corrupt,
      glow: Palette.corruptGlow,
      rotation: _spin,
      blur: false,
    );
    Neon.circle(canvas, c, radius * 0.35, Palette.corruptGlow,
        glow: Palette.corruptGlow, glowScale: 1.6, blur: false);
  }
}
