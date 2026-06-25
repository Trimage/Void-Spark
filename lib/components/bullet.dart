import 'dart:ui';

import 'package:flame/components.dart';

import '../config/game_config.dart';
import '../void_spark_game.dart';

/// 플레이어가 발사하는 총알.
///
/// 성능: 확산·연사로 매우 많이 생성되므로 **오브젝트 풀**로 재사용하고,
/// Flame 충돌 시스템 대신 **적과의 거리 검사**로 명중 판정한다(밀집 시
/// broadphase가 O(n²)로 폭주하는 것을 막는다).
class Bullet extends PositionComponent with HasGameReference<VoidSparkGame> {
  Bullet() : super(anchor: Anchor.center, priority: 5);

  final Vector2 velocity = Vector2.zero();
  int damage = 1;
  bool active = false;

  void spawn(Vector2 pos, Vector2 vel, int dmg) {
    position.setFrom(pos);
    velocity.setFrom(vel);
    damage = dmg;
    active = true;
  }

  @override
  Future<void> onLoad() async {
    size = Vector2.all(GameConfig.bulletRadius * 2);
  }

  @override
  void update(double dt) {
    if (!active) return;
    position.x += velocity.x * dt;
    position.y += velocity.y * dt;

    // 적 명중 판정(프레임 시작 시점의 적 목록을 거리 비교).
    final pierce = game.runMods.pierce || game.powerups.pierceActive;
    for (final e in game.activeEnemies) {
      final rr = e.radius + GameConfig.bulletRadius;
      if (position.distanceToSquared(e.position) <= rr * rr) {
        e.takeDamage(damage);
        if (!pierce) {
          active = false;
          return;
        }
      }
    }

    final m = GameConfig.enemyDespawnMargin;
    if (position.y < -m ||
        position.y > game.size.y + m ||
        position.x < -m ||
        position.x > game.size.x + m) {
      active = false;
    }
  }

  // 렌더는 BatchLayer가 일괄 처리. renderTree 자체를 건너뛰어 컴포넌트별
  // save/transform/restore 비용까지 제거한다(고부하 구간 프레임 비용↓).
  @override
  void renderTree(Canvas canvas) {}
}
