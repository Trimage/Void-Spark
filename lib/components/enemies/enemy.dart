import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../../void_spark_game.dart';
import '../core.dart';

/// 모든 적의 베이스. 체력/충돌/사망 처리를 공통화한다.
/// 이동 로직은 서브클래스가 [update]에서 구현한다.
abstract class Enemy extends PositionComponent
    with HasGameReference<VoidSparkGame>, CollisionCallbacks {
  Enemy({
    required Vector2 position,
    required this.radius,
    required this.maxHp,
  })  : hp = maxHp,
        super(position: position, anchor: Anchor.center, priority: 6) {
    size = Vector2.all(radius * 2);
  }

  final double radius;
  final int maxHp;
  int hp;

  bool _dead = false;

  @override
  Future<void> onLoad() async {
    add(CircleHitbox(
      radius: radius,
      anchor: Anchor.center,
      position: size / 2,
    )..collisionType = CollisionType.active);
  }

  /// 데미지를 입는다. 체력이 0 이하가 되면 처치된다.
  void takeDamage(int amount) {
    if (_dead) return;
    hp -= amount;
    if (hp <= 0) {
      _dead = true;
      onKilled();
    }
  }

  /// 처치 시 호출. 기본은 점수 적립 + 제거. (파티클/오브는 이후 단계)
  void onKilled() {
    game.onEnemyKilled(this);
    removeFromParent();
  }

  /// 화면 아래로 완전히 벗어났을 때 정리하기 위한 헬퍼.
  bool isOffBottom(double margin) => position.y - radius > game.size.y + margin;

  /// Slow 파워업 등 시간 배율을 적 전체(자식 포함)에 일괄 적용한다.
  @override
  void updateTree(double dt) {
    super.updateTree(dt * game.enemyTimeScale);
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    // 코어와 접촉 → 플레이어 피격. (플레이어 총알 명중은 Bullet이 직접 처리)
    if (other is Core) {
      game.onPlayerHit();
    }
  }
}
