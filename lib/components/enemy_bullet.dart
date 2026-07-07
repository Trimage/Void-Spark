import 'dart:ui';

import 'package:flame/components.dart';

import '../config/game_config.dart';
import '../void_spark_game.dart';

/// 적이 발사하는 탄. 코어에만 충돌(거리 검사)한다.
///
/// 성능: 매 프레임 대량 생성/소멸되므로 **오브젝트 풀**로 재사용한다.
/// 게임이 최대 수만큼 미리 생성해 트리에 두고, [active] 플래그로 켜고 끈다.
/// 비활성 시 update/render를 즉시 건너뛰어 사실상 비용이 없다.
class EnemyBullet extends PositionComponent with HasGameReference<VoidSparkGame> {
  EnemyBullet() : super(anchor: Anchor.center, priority: 4);

  final Vector2 velocity = Vector2.zero();
  bool active = false;
  bool _grazed = false;

  /// 코어를 조준한 '피하기 어려운' 탄 여부(다른 색으로 렌더).
  bool aimed = false;

  /// 풀에서 꺼내 재사용.
  void spawn(Vector2 pos, Vector2 vel, {bool aimed = false}) {
    position.setFrom(pos);
    velocity.setFrom(vel);
    _grazed = false;
    this.aimed = aimed;
    active = true;
  }

  @override
  Future<void> onLoad() async {
    size = Vector2.all(GameConfig.enemyBulletRadius * 2);
  }

  /// 비활성이면 갱신 자체를 건너뜀. 활성 시 Slow/오버드라이브 시간 배율 적용.
  @override
  void updateTree(double dt) {
    if (!active) return;
    super.updateTree(dt * game.enemyTimeScale);
  }

  @override
  void update(double dt) {
    position.x += velocity.x * dt;
    position.y += velocity.y * dt;

    const hitR = GameConfig.coreRadius + GameConfig.enemyBulletRadius;
    final dsq = position.distanceToSquared(game.core.position);
    if (dsq <= hitR * hitR) {
      active = false; // 풀로 반환
      game.onPlayerHit();
      return;
    }
    if (!_grazed && dsq <= GameConfig.grazeRadius * GameConfig.grazeRadius) {
      _grazed = true;
      game.onGraze();
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
