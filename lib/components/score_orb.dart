import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import '../config/game_config.dart';
import '../config/palette.dart';
import '../void_spark_game.dart';
import 'neon.dart';

/// 점수 오브 — 적 처치 시 떨어진다. 코어가 닿아야 점수를 획득한다.
/// (위험한 곳으로 움직이도록 유도하는 핵심 장치)
/// 자석(Magnet) 발동 시 코어로 빠르게 빨려오고, 평소엔 근접 시에만 약하게 끌린다.
///
/// 성능: 매 처치마다 대량 생성/소멸되므로 **오브젝트 풀**로 재사용한다.
/// 게임이 maxOrbs만큼 미리 생성해 트리에 두고 [active] 플래그로 켜고 끈다.
/// 비활성 시 update/render를 건너뛰어 add/remove churn(멈춤 원인)을 없앤다.
class ScoreOrb extends PositionComponent with HasGameReference<VoidSparkGame> {
  ScoreOrb() : super(anchor: Anchor.center, priority: 3);

  int value = GameConfig.scorePerKill;
  bool active = false;
  double life = 0; // 누적 수명(가득 찼을 때 가장 오래된 것 교체용)
  double _pulse = 0;

  /// 풀에서 꺼내 재사용.
  void spawn(Vector2 pos, int v) {
    position.setFrom(pos);
    value = v;
    life = 0;
    _pulse = 0;
    active = true;
  }

  @override
  Future<void> onLoad() async {
    size = Vector2.all(GameConfig.orbRadius * 2);
  }

  @override
  void update(double dt) {
    if (!active) return;
    life += dt;
    _pulse += dt;
    if (life >= GameConfig.orbLifetime) {
      active = false;
      return;
    }

    // 매 프레임 Vector2 할당을 피하려 스칼라(dx/dy)로 직접 계산.
    final core = game.core.position;
    final dx = core.x - position.x;
    final dy = core.y - position.y;
    final dist = math.sqrt(dx * dx + dy * dy);

    // 코어 획득 판정.
    const pickR = GameConfig.coreRadius + GameConfig.orbRadius;
    if (dist <= pickR) {
      game.collectOrb(value);
      active = false;
      return;
    }

    if (dist > 0.01) {
      final inv = 1 / dist; // 정규화 방향(dx*inv, dy*inv)
      final assistR = game.orbAssistRadius; // 자력 업그레이드 반영
      if (game.powerups.magnetActive) {
        final s = GameConfig.orbMagnetSpeed * dt;
        position.x += dx * inv * s;
        position.y += dy * inv * s;
      } else if (dist < assistR) {
        // 가까울수록 강해지는 보조 흡입.
        final s = GameConfig.orbAssistSpeed * (1 - dist / assistR) * dt;
        position.x += dx * inv * s;
        position.y += dy * inv * s;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    if (!active) return;
    final c = Offset(size.x / 2, size.y / 2);
    final breathe = 1 + 0.18 * (0.5 + 0.5 * math.sin(_pulse * 6));
    Neon.circle(
      canvas,
      c,
      GameConfig.orbRadius * breathe,
      Palette.scoreOrb,
      glow: Palette.scoreOrbGlow,
      glowScale: 2.4,
      blur: false,
    );
  }
}
