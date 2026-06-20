import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../config/game_config.dart';
import '../config/palette.dart';
import '../void_spark_game.dart';
import 'neon.dart';

/// 파워업 종류.
enum PowerupType { spread, rapid, shield, bomb, slow, magnet, pierce, aim }

extension PowerupVisual on PowerupType {
  /// 픽업에 표시할 글리프.
  String get glyph => switch (this) {
        PowerupType.spread => 'W',
        PowerupType.rapid => 'R',
        PowerupType.shield => '+',
        PowerupType.bomb => 'B',
        PowerupType.slow => '~',
        PowerupType.magnet => 'M',
        PowerupType.pierce => '»',
        PowerupType.aim => '◎',
      };

  /// 픽업 색상.
  Color get color => switch (this) {
        PowerupType.spread => Palette.core,
        PowerupType.rapid => Palette.accent,
        PowerupType.shield => Palette.textHi,
        PowerupType.bomb => Palette.danger,
        PowerupType.slow => Palette.orb,
        PowerupType.magnet => Palette.corrupt,
        PowerupType.pierce => Palette.coreGlow,
        PowerupType.aim => Palette.accent,
      };
}

/// 적 처치 시 일정 확률로 떨어지는 파워업 아이템. 코어가 닿으면 획득.
/// (코어와만 상호작용 — 충돌 시스템 대신 거리 검사 사용)
class Powerup extends PositionComponent with HasGameReference<VoidSparkGame> {
  Powerup({required Vector2 position, required this.type})
      : super(position: position, anchor: Anchor.center, priority: 4);

  final PowerupType type;
  double _life = 0;
  double _spin = 0;

  late final TextPaint _glyphPaint = TextPaint(
    style: TextStyle(
      color: Palette.textHi,
      fontSize: 14,
      fontWeight: FontWeight.w800,
      shadows: [Shadow(color: type.color, blurRadius: 8)],
    ),
  );

  @override
  Future<void> onLoad() async {
    size = Vector2.all(GameConfig.powerupRadius * 2);
  }

  @override
  void update(double dt) {
    _life += dt;
    _spin += dt;
    position.y += GameConfig.powerupFallSpeed * dt;

    // 코어 획득 판정(거리).
    const pickR = GameConfig.coreRadius + GameConfig.powerupRadius;
    if (position.distanceToSquared(game.core.position) <= pickR * pickR) {
      game.collectPowerup(type);
      removeFromParent();
      return;
    }

    if (_life >= GameConfig.powerupLifetime ||
        position.y > game.size.y + GameConfig.enemyDespawnMargin) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final c = Offset(size.x / 2, size.y / 2);
    final r = GameConfig.powerupRadius;
    // 회전하는 발광 링.
    Neon.polygon(canvas, c, r, 6, type.color,
        glow: type.color, rotation: _spin, strokeWidth: 2.5);
    // 가운데 글리프.
    _glyphPaint.render(
      canvas,
      type.glyph,
      Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
    );
  }
}
