import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import '../../config/game_config.dart';
import '../../config/palette.dart';
import '../neon.dart';
import 'enemy.dart';

/// Splitter — 느리게 내려오다 처치되면 작은 자식 여러 마리로 분열한다.
class Splitter extends Enemy {
  Splitter({required super.position})
      : super(
          radius: GameConfig.splitterRadius,
          maxHp: GameConfig.splitterHp,
        );

  double _spin = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _spin += dt * 1.2;
    position.y += GameConfig.splitterSpeed * dt;
    if (isOffBottom(GameConfig.enemyDespawnMargin)) {
      removeFromParent();
    }
  }

  @override
  void onKilled() {
    // 사방으로 흩어지는 자식들을 생성한 뒤 일반 처치 처리.
    final n = GameConfig.splitterChildren;
    for (var i = 0; i < n; i++) {
      final a = (i / n) * 2 * math.pi + _spin;
      final vel = Vector2(math.cos(a), math.sin(a)) *
          GameConfig.splitterChildSpeed;
      game.add(SplitterChild(position: position.clone(), velocity: vel));
    }
    super.onKilled();
  }

  @override
  void render(Canvas canvas) {
    final c = Offset(size.x / 2, size.y / 2);
    Neon.polygon(
      canvas,
      c,
      radius,
      6,
      Palette.corrupt,
      glow: Palette.corruptGlow,
      rotation: _spin,
      strokeWidth: 3.5,
    );
  }
}

/// Splitter가 분열되며 생성하는 작은 적. 주어진 [velocity]로 직진한다.
class SplitterChild extends Enemy {
  SplitterChild({required super.position, required this.velocity})
      : super(
          radius: GameConfig.splitterChildRadius,
          maxHp: GameConfig.splitterChildHp,
        );

  final Vector2 velocity;

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;
    final m = GameConfig.enemyDespawnMargin;
    if (position.y > game.size.y + m ||
        position.y < -m ||
        position.x < -m ||
        position.x > game.size.x + m) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final c = Offset(size.x / 2, size.y / 2);
    Neon.polygon(
      canvas,
      c,
      radius,
      3,
      Palette.corrupt,
      glow: Palette.corruptGlow,
    );
  }
}
