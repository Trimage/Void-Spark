import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// 단순 발광 파티클 — 한 점에서 방사형으로 흩어지며 사라진다.
///
/// 성능: 폭발마다 대량 생성되므로 **오브젝트 풀**로 재사용한다.
/// 비활성([active]=false) 시 update/render를 건너뛴다.
class NeonParticle extends PositionComponent {
  NeonParticle() : super(anchor: Anchor.center, priority: 8);

  final Vector2 velocity = Vector2.zero();
  Color color = const Color(0xFFFFFFFF);
  double life = 0.5;
  double _age = 0;
  bool active = false;

  void spawn(Vector2 pos, Vector2 vel, Color c, double l) {
    position.setFrom(pos);
    velocity.setFrom(vel);
    color = c;
    life = l;
    _age = 0;
    active = true;
  }

  static final Paint _p = Paint();

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

  @override
  void render(Canvas canvas) {
    if (!active) return;
    final t = (1 - _age / life).clamp(0.0, 1.0);
    final r = 3.0 * t + 0.5;
    _p.color = color.withValues(alpha: t * 0.35);
    canvas.drawCircle(Offset.zero, r * 2.2, _p);
    _p.color = color.withValues(alpha: t);
    canvas.drawCircle(Offset.zero, r, _p);
  }
}
