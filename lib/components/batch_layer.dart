import 'dart:typed_data';
import 'dart:ui';

import 'package:flame/components.dart';

import '../config/game_config.dart';
import '../config/palette.dart';
import '../void_spark_game.dart';
import 'bullet.dart';
import 'enemy_bullet.dart';
import 'neon.dart';
import 'score_orb.dart';

/// 풀링된 다수 엔티티(적탄·플레이어탄·점수오브·파티클)를 **한 컴포넌트에서 일괄 렌더**.
///
/// 성능: 같은 종류의 탄/오브는 좌표만 버퍼에 모아 `drawRawPoints`로 **한 번에** 그린다.
/// 이렇게 하면 (1) 엔티티마다 Offset을 새로 만드는 프레임당 할당이 사라지고,
/// (2) 수백 번의 drawCircle 호출이 종류당 2번(글로우+본체)으로 줄어든다.
/// 고밀도 구간(깊은 섹터/보스)에서 프레임이 끊기던 문제를 크게 완화한다.
class BatchLayer extends PositionComponent
    with HasGameReference<VoidSparkGame> {
  BatchLayer({super.priority});

  final Paint _dot = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;
  final Paint _fill = Paint()..style = PaintingStyle.fill;

  // 좌표 버퍼 재사용(가장 큰 풀 크기로 확보 — 한 종류를 다 그린 뒤 다음에 재사용).
  late final Float32List _buf = Float32List(GameConfig.maxEnemyBullets * 2);

  @override
  void render(Canvas canvas) {
    final g = game;

    // 적탄 — 일반(분홍)과 조준탄(붉은 경고색)을 분리해 각각 한 번에.
    _blitEnemyBullets(canvas, g.ebPool,
        aimed: false, body: Palette.corrupt, glow: Palette.corruptGlow);
    _blitEnemyBullets(canvas, g.ebPool,
        aimed: true, body: Palette.aimedBullet, glow: Palette.aimedBulletGlow);

    // 플레이어탄(스킨 색).
    final skin = g.skin;
    _blitPlayerBullets(canvas, g.pbPool, body: skin.color, glow: skin.glow);

    // 점수 오브(금색).
    _blitOrbs(canvas, g.orbPool,
        body: Palette.scoreOrb, glow: Palette.scoreOrbGlow);

    // 파티클(수명에 따라 페이드·축소하므로 개별 드로).
    for (final p in g.pPool) {
      if (!p.active) continue;
      final t = p.fadeT;
      final r = 3.0 * t + 0.5;
      final c = Offset(p.position.x, p.position.y);
      _fill.color = Neon.alpha(p.color, t * 0.35);
      canvas.drawCircle(c, r * 2.2, _fill);
      _fill.color = Neon.alpha(p.color, t);
      canvas.drawCircle(c, r, _fill);
    }
  }

  /// 버퍼에 담은 점들을 글로우 1겹 + 본체로 한 번에 그린다(점 크기=지름).
  void _blit(Canvas c, int count, double r, Color body, Color glow) {
    if (count == 0) return;
    final pts = Float32List.view(_buf.buffer, 0, count * 2);
    _dot
      ..color = Neon.alpha(glow, 0.26)
      ..strokeWidth = r * 3.6;
    c.drawRawPoints(PointMode.points, pts, _dot);
    _dot
      ..color = body
      ..strokeWidth = r * 2;
    c.drawRawPoints(PointMode.points, pts, _dot);
  }

  void _blitEnemyBullets(Canvas c, List<EnemyBullet> pool,
      {required bool aimed, required Color body, required Color glow}) {
    var n = 0;
    for (final b in pool) {
      if (!b.active || b.aimed != aimed) continue;
      _buf[n * 2] = b.position.x;
      _buf[n * 2 + 1] = b.position.y;
      n++;
    }
    _blit(c, n, GameConfig.enemyBulletRadius, body, glow);
  }

  void _blitPlayerBullets(Canvas c, List<Bullet> pool,
      {required Color body, required Color glow}) {
    var n = 0;
    for (final b in pool) {
      if (!b.active) continue;
      _buf[n * 2] = b.position.x;
      _buf[n * 2 + 1] = b.position.y;
      n++;
    }
    _blit(c, n, GameConfig.bulletRadius, body, glow);
  }

  void _blitOrbs(Canvas c, List<ScoreOrb> pool,
      {required Color body, required Color glow}) {
    var n = 0;
    for (final o in pool) {
      if (!o.active) continue;
      _buf[n * 2] = o.position.x;
      _buf[n * 2 + 1] = o.position.y;
      n++;
    }
    _blit(c, n, GameConfig.orbRadius, body, glow);
  }
}
