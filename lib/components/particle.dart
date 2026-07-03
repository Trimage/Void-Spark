import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// 단순 발광 파티클 — 한 점에서 방사형으로 흩어지며 사라진다.
///
/// 성능: 폭발마다 대량 생성되므로 **오브젝트 풀**로 재사용하고, 렌더는
/// BatchLayer가 일괄 처리한다(개별 컴포넌트 변환 오버헤드 제거).
class NeonParticle extends PositionComponent {
  NeonParticle() : super(anchor: Anchor.center, priority: 8);

  final Vector2 velocity = Vector2.zero();
  Color color = const Color(0xFFFFFFFF);
  double life = 0.5;
  double _age = 0;
  bool active = false;

  /// 남은 수명 비율(1=갓 생성, 0=소멸). BatchLayer의 페이드·크기 계산용.
  double get fadeT => (1 - _age / life).clamp(0.0, 1.0);

  void spawn(Vector2 pos, Vector2 vel, Color c, double l) {
    position.setFrom(pos);
    velocity.setFrom(vel);
    color = c;
    life = l;
    _age = 0;
    active = true;
  }

  @override
  void update(double dt) {
    if (!active) return;
    _age += dt;
    if (_age >= life) {
      active = false;
      return;
    }
    final drag = (1 - 2.2 * dt).clamp(0.0, 1.0);
    velocity.scale(drag);
    position.x += velocity.x * dt;
    position.y += velocity.y * dt;
  }

  // 렌더는 BatchLayer가 일괄 처리 — renderTree를 건너뛰어 변환 비용 제거.
  @override
  void renderTree(Canvas canvas) {}
}
