import 'dart:ui';

import 'package:flame/components.dart';

import '../config/game_config.dart';
import '../config/palette.dart';
import '../void_spark_game.dart';
import 'neon.dart';

/// 풀링된 다수 엔티티(적탄·플레이어탄·점수오브)를 **한 컴포넌트에서 일괄 렌더**.
///
/// 성능: 엔티티 하나하나를 개별 컴포넌트로 그리면 Flame이 컴포넌트마다
/// canvas.save/transform/restore를 수행한다. 수백 개가 동시에 있는 고부하
/// 구간(깊은 섹터/보스)에서는 이 변환 오버헤드가 프레임을 끌어내린다.
/// 여기서 모든 활성 엔티티를 좌표 직접 지정으로 한 번에 그려 그 비용을 없앤다.
/// (개별 컴포넌트는 update만 수행하고 render는 비운다.)
class BatchLayer extends PositionComponent
    with HasGameReference<VoidSparkGame> {
  BatchLayer({super.priority});

  final Paint _p = Paint()..style = PaintingStyle.fill;

  @override
  void render(Canvas canvas) {
    final g = game;

    // 적탄(고정 색/크기).
    for (final b in g.ebPool) {
      if (!b.active) continue;
      _glowDot(canvas, b.position.x, b.position.y,
          GameConfig.enemyBulletRadius, Palette.corrupt, Palette.corruptGlow);
    }

    // 플레이어탄(스킨 색).
    final skin = g.skin;
    for (final b in g.pbPool) {
      if (!b.active) continue;
      _glowDot(canvas, b.position.x, b.position.y, GameConfig.bulletRadius,
          skin.color, skin.glow);
    }

    // 점수 오브(금색).
    for (final o in g.orbPool) {
      if (!o.active) continue;
      _glowDot(canvas, o.position.x, o.position.y, GameConfig.orbRadius,
          Palette.scoreOrb, Palette.scoreOrbGlow);
    }

    // 파티클(수명에 따라 페이드/축소).
    for (final p in g.pPool) {
      if (!p.active) continue;
      final t = p.fadeT;
      final r = 3.0 * t + 0.5;
      final center = Offset(p.position.x, p.position.y);
      _p.color = Neon.alpha(p.color, t * 0.35);
      canvas.drawCircle(center, r * 2.2, _p);
      _p.color = Neon.alpha(p.color, t);
      canvas.drawCircle(center, r, _p);
    }
  }

  /// 저비용 글로우(반투명 큰 원 1겹 + 본체) — blur 없음.
  void _glowDot(
      Canvas c, double x, double y, double r, Color body, Color glow) {
    final center = Offset(x, y);
    _p.color = Neon.alpha(glow, 0.26);
    c.drawCircle(center, r * 1.8, _p);
    _p.color = body;
    c.drawCircle(center, r, _p);
  }
}
