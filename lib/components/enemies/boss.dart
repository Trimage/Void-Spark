import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';

import '../../config/game_config.dart';
import '../../config/palette.dart';
import '../neon.dart';
import 'enemy.dart';

/// 보스 — 손상된 거대 도형. 화면 위쪽에서 좌우로 순항하며 체력 구간에 따라
/// 3페이즈로 탄막이 강해진다. 등장할 때마다 [variant]가 바뀌어(0=Monolith,
/// 1=Vortex) 패턴 세트와 외형이 달라진다.
class Boss extends Enemy {
  Boss({required super.position, this.variant = 0})
      : super(
          radius: GameConfig.bossRadius,
          maxHp: GameConfig.bossHp,
        );

  /// 보스 변형(0=Monolith, 1=Vortex).
  final int variant;

  bool _entered = false;
  double _dir = 1; // 좌우 순항 방향
  double _fireTimer = 0;
  double _spin = 0;
  double _ringAngle = 0;
  double _spiralAngle = 0;
  int _phase = 1;

  /// 체력 비율(0~1).
  double get hpRatio => hp / maxHp;

  /// 자리 잡기(하강 완료) 전까지는 무적 — 체력이 닳지 않는다.
  @override
  void takeDamage(int amount) {
    if (!_entered) return;
    super.takeDamage(amount);
  }

  /// 테스트용: 등장 완료 상태로 강제 전환.
  @visibleForTesting
  void debugMarkEntered() => _entered = true;

  int _phaseFor(double ratio) {
    if (ratio > 0.66) return 1;
    if (ratio > 0.33) return 2;
    return 3;
  }

  double get _fireInterval => switch (_phase) {
        1 => GameConfig.bossFireP1,
        2 => GameConfig.bossFireP2,
        _ => GameConfig.bossFireP3,
      };

  @override
  void update(double dt) {
    super.update(dt);
    _spin += dt * 0.5;

    // 진입: 호버 위치까지 하강.
    if (!_entered) {
      position.y += GameConfig.bossSpeed * dt;
      if (position.y >= GameConfig.bossHoverY) {
        position.y = GameConfig.bossHoverY;
        _entered = true;
      }
      return;
    }

    // 좌우 순항(가장자리에서 반전).
    position.x += _dir * GameConfig.bossSpeed * dt;
    if (position.x < radius) {
      position.x = radius;
      _dir = 1;
    } else if (position.x > game.size.x - radius) {
      position.x = game.size.x - radius;
      _dir = -1;
    }

    // 페이즈 전환 감지.
    final ph = _phaseFor(hpRatio);
    if (ph != _phase) {
      _phase = ph;
      game.onBossPhaseChange(_phase);
    }

    // 탄막 발사.
    _fireTimer += dt;
    if (_fireTimer >= _fireInterval) {
      _fireTimer = 0;
      _fire();
    }
  }

  void _fire() {
    if (variant == 1) {
      _fireVortex();
    } else {
      _fireMonolith();
    }
  }

  /// Monolith — 정통 링/조준 패턴.
  void _fireMonolith() {
    switch (_phase) {
      case 1:
        _ring(0);
      case 2:
        _aimedSpread(5, 0.26);
      default:
        // 링 + 회전 오프셋(나선) 동시.
        _ringAngle += 0.4;
        _ring(_ringAngle);
        _aimedSpread(3, 0.3);
    }
  }

  /// Vortex — 회전 나선/광역 패턴.
  void _fireVortex() {
    switch (_phase) {
      case 1:
        _spiral(3);
      case 2:
        _doubleSpiral();
      default:
        // 광역 부채꼴 + 역회전 나선 동시.
        _wideBarrage(9, 0.22);
        _spiral(4);
    }
  }

  /// 균등 방사 링 탄막.
  void _ring(double offset) {
    final n = GameConfig.bossRingBullets;
    for (var i = 0; i < n; i++) {
      final a = offset + (i / n) * 2 * math.pi;
      final dir = Vector2(math.cos(a), math.sin(a));
      game.spawnEnemyBullet(
          position.clone(), dir * GameConfig.enemyBulletSpeed);
    }
  }

  /// 코어를 향한 부채꼴 스프레드.
  void _aimedSpread(int count, double spread) {
    final toCore = game.core.position - position;
    if (toCore.length2 == 0) return;
    final base = math.atan2(toCore.y, toCore.x);
    for (var i = 0; i < count; i++) {
      final a = base + (i - (count - 1) / 2) * spread;
      final dir = Vector2(math.cos(a), math.sin(a));
      game.spawnEnemyBullet(
          position.clone(), dir * GameConfig.turretBulletSpeed);
    }
  }

  /// 넓은 광역 부채꼴(코어 조준 + 넓은 각도).
  void _wideBarrage(int count, double spread) => _aimedSpread(count, spread);

  /// 회전 나선 — [arms]개의 팔에서 점진 회전하며 탄을 흩뿌린다.
  void _spiral(int arms) {
    _spiralAngle += 0.32;
    for (var i = 0; i < arms; i++) {
      final a = _spiralAngle + (i / arms) * 2 * math.pi;
      final dir = Vector2(math.cos(a), math.sin(a));
      game.spawnEnemyBullet(
          position.clone(), dir * GameConfig.spinnerBulletSpeed);
    }
  }

  /// 서로 반대로 도는 이중 나선.
  void _doubleSpiral() {
    _spiralAngle += 0.4;
    for (var i = 0; i < 2; i++) {
      final base = _spiralAngle * (i.isEven ? 1 : -1) + i * math.pi;
      final dir = Vector2(math.cos(base), math.sin(base));
      game.spawnEnemyBullet(
          position.clone(), dir * GameConfig.spinnerBulletSpeed);
      final dir2 = Vector2(math.cos(base + math.pi), math.sin(base + math.pi));
      game.spawnEnemyBullet(
          position.clone(), dir2 * GameConfig.spinnerBulletSpeed);
    }
  }

  @override
  void onKilled() {
    // 보스는 일반 처치 로직 대신 전용 처리(보너스/정리/연출).
    game.onBossKilled(this);
    removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final c = Offset(size.x / 2, size.y / 2);
    // Vortex는 다른 형상(육각 별)과 색으로 구분.
    final sides = variant == 1 ? 6 : 8;
    final body = variant == 1 ? Palette.orb : Palette.corrupt;
    final glow = variant == 1 ? Palette.orb : Palette.corruptGlow;

    Neon.polygon(canvas, c, radius, sides, body,
        glow: glow, rotation: _spin, strokeWidth: 4);
    Neon.polygon(canvas, c, radius * 0.62, sides, glow,
        glow: glow, rotation: -_spin * 1.4, strokeWidth: 3);
    Neon.circle(canvas, c, radius * 0.28, Palette.danger,
        glow: Palette.danger, glowScale: 2.0);

    // 등장(자리 잡기) 전엔 무적 표시용 실드 링.
    if (!_entered) {
      Neon.circle(canvas, c, radius * 1.18, Palette.core,
          glow: Palette.coreGlow,
          filled: false,
          strokeWidth: 3,
          glowScale: 1.4,
          blur: false);
    }
  }
}
