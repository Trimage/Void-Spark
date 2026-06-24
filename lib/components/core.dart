import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../config/game_config.dart';
import '../config/palette.dart';
import '../void_spark_game.dart';
import 'enemies/enemy.dart';
import 'neon.dart';

/// 플레이어 — 마지막 빛의 입자 "코어".
/// 드래그한 목표점([target])으로 부드럽게 보간 이동하고, 자동으로 사격한다.
class Core extends PositionComponent
    with HasGameReference<VoidSparkGame>, CollisionCallbacks {
  Core() : super(anchor: Anchor.center, priority: 10);

  /// 드래그로 지정된 목표 위치(월드 좌표). null이면 제자리 유지.
  Vector2? target;

  double _pulse = 0;
  double _fireTimer = 0;

  /// 충돌 판정용 반지름.
  double get radius => GameConfig.coreRadius;

  @override
  Future<void> onLoad() async {
    size = Vector2.all(GameConfig.coreRadius * 2);
    position = game.size / 2;
    target = position.clone();
    add(CircleHitbox(
      radius: GameConfig.coreRadius,
      anchor: Anchor.center,
      position: size / 2,
    )..collisionType = CollisionType.active);
  }

  @override
  void update(double dt) {
    _pulse += dt;

    final t = target;
    if (t != null) {
      // dt 기반 지수 보간: 프레임레이트에 독립적인 부드러운 추적(기동 업그레이드 반영).
      final factor = 1 - math.exp(-game.effectiveFollow * dt);
      position += (t - position) * factor;
    }

    // 화면 경계 클램프.
    final pad = GameConfig.coreEdgePadding + radius;
    position.x = position.x.clamp(pad, game.size.x - pad);
    position.y = position.y.clamp(pad, game.size.y - pad);

    _updateFiring(dt);
  }

  void _updateFiring(double dt) {
    // 플레이 중일 때만 발사·사격음(사망/일시정지 시 소리 누수 방지).
    if (game.state != GameState.playing) return;
    _fireTimer += dt;
    final base = game.effectiveFireInterval * game.runMods.fireIntervalMul;
    final interval =
        game.powerups.rapidActive ? base * GameConfig.rapidFireFactor : base;
    if (_fireTimer < interval) return;
    _fireTimer = 0;
    _fire();
    game.audio.shoot();
  }

  void _fire() {
    final mods = game.runMods;
    final dmg = 1 + mods.damageBonus;
    // 양옆 추가 탄(쌍) = 인런 확산 + Spread 파워업 (상한 적용).
    final sidePairs = (mods.extraSpread + (game.powerups.spreadActive ? 1 : 0))
        .clamp(0, GameConfig.maxSidePairs);
    _fireVolley(_aimDirection(), dmg, sidePairs);
    if (mods.backShot) _fireVolley(Vector2(0, 1), dmg, sidePairs);
  }

  void _fireVolley(Vector2 dir, int dmg, int sidePairs) {
    _spawnBullet(dir, dmg);
    for (var i = 1; i <= sidePairs; i++) {
      _spawnBullet(_rotate(dir, GameConfig.spreadAngle * i), dmg);
      _spawnBullet(_rotate(dir, -GameConfig.spreadAngle * i), dmg);
    }
  }

  void _spawnBullet(Vector2 dir, int dmg) {
    // 풀에서 재사용(상한은 풀 크기 maxPlayerBullets로 자동 제한).
    game.spawnPlayerBullet(
        position, _bulletVel..setFrom(dir)..scale(GameConfig.bulletSpeed), dmg);
  }

  final Vector2 _bulletVel = Vector2.zero();

  Vector2 _rotate(Vector2 v, double a) {
    final cosA = math.cos(a);
    final sinA = math.sin(a);
    return Vector2(v.x * cosA - v.y * sinA, v.x * sinA + v.y * cosA);
  }

  /// 조준 방향. 기본은 정면(위쪽). 옵션 시 가장 가까운 적을 조준.
  Vector2 _aimDirection() {
    // 자동 조준은 Aim 파워업이 활성일 때만(평소엔 정면 발사).
    if (!game.powerups.aimActive) {
      return Vector2(0, -1);
    }
    Enemy? nearest;
    double best = double.infinity;
    for (final e in game.activeEnemies) {
      final d = e.position.distanceToSquared(position);
      if (d < best) {
        best = d;
        nearest = e;
      }
    }
    if (nearest == null) return Vector2(0, -1);
    final dir = nearest.position - position;
    if (dir.length2 == 0) return Vector2(0, -1);
    return dir.normalized();
  }

  @override
  void render(Canvas canvas) {
    final c = Offset(size.x / 2, size.y / 2);

    // 무적(피격 직후) 동안은 빠르게 점멸.
    if (game.invulnerable && (_pulse * 20).floor().isEven) {
      return;
    }

    // 숨쉬는 듯한 미세 펄스. 색은 장착한 스킨을 따른다.
    final breathe = 1 + 0.08 * math.sin(_pulse * 4);
    final skin = game.skin;
    Neon.circle(
      canvas,
      c,
      radius * breathe,
      skin.color,
      glow: skin.glow,
      glowScale: 2.4,
    );

    // 실드 보유 시 보호 링.
    if (game.powerups.shield) {
      final ringPaint = Paint()
        ..color = Palette.textHi.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawCircle(c, radius * 1.9, ringPaint);
    }
  }
}
