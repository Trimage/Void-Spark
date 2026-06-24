import 'dart:math' as math;

import 'package:flutter/material.dart';

/// 네온 발광 도형을 그리는 공통 헬퍼.
/// 이미지 에셋 없이 [Canvas] 위에 글로우 + 본체를 합성한다.
///
/// 성능: Paint 객체를 매 프레임 새로 만들지 않도록 정적으로 재사용한다
/// (렌더는 단일 스레드 순차 실행이라 공유가 안전). 또한 총알/탄/오브처럼
/// 화면에 많은 작은 오브젝트는 [blur]=false 로 호출해 비싼 MaskFilter.blur
/// 대신 반투명 원 두 겹의 저렴한 글로우를 쓴다.
class Neon {
  Neon._();

  static final Paint _glow = Paint();
  static final Paint _body = Paint();
  static final Paint _hi = Paint();
  static final Paint _fill = Paint();

  // 매 프레임 Color 할당을 줄이기 위한 상수.
  static const Color _white90 = Color(0xE6FFFFFF);

  // ---- 할당 캐시(매 프레임 객체 생성 방지 → GC 멈춤 제거) ----
  // 같은 (RGB, alpha) 조합의 Color, 같은 sigma의 MaskFilter를 재사용한다.
  // 팔레트·크기 종류가 한정적이라 캐시는 수십~수백 개로 수렴한다.
  static final Map<int, Color> _colorCache = {};
  static final Map<int, MaskFilter> _blurCache = {};

  static Color _withAlpha(Color c, double alpha) {
    final argb = ((alpha * 255).round().clamp(0, 255) << 24) |
        (c.toARGB32() & 0x00FFFFFF);
    return _colorCache[argb] ??= Color(argb);
  }

  static MaskFilter _blur(double sigma) {
    final key = sigma.round().clamp(1, 300);
    return _blurCache[key] ??= MaskFilter.blur(BlurStyle.normal, key.toDouble());
  }

  /// 외부(파티클 등)에서도 캐시된 알파 적용 색을 쓰도록 공개.
  static Color alpha(Color c, double a) => _withAlpha(c, a);

  // 폴리곤용 재사용 Path(매 프레임 새 Path 할당 방지).
  static final Path _poly = Path();

  /// 발광하는 원.
  /// [blur]=false면 다수의 작은 오브젝트용 초저비용 경로(글로우 1겹 + 본체).
  static void circle(
    Canvas canvas,
    Offset center,
    double radius,
    Color color, {
    Color? glow,
    double glowScale = 2.0,
    bool filled = true,
    double strokeWidth = 2.5,
    bool blur = true,
  }) {
    final glowColor = glow ?? color;

    if (blur) {
      _glow
        ..color = _withAlpha(glowColor, 0.55)
        ..style = PaintingStyle.fill
        ..maskFilter = _blur(radius * glowScale);
      canvas.drawCircle(center, radius, _glow);

      _body
        ..maskFilter = null
        ..color = color;
      if (filled) {
        _body.style = PaintingStyle.fill;
      } else {
        _body
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth;
      }
      canvas.drawCircle(center, radius, _body);

      if (filled) {
        _hi
          ..maskFilter = null
          ..style = PaintingStyle.fill
          ..color = _white90;
        canvas.drawCircle(center, radius * 0.45, _hi);
      }
    } else {
      // 초저비용 경로: 반투명 글로우 1겹 + 본체(하이라이트·블러 없음).
      _glow
        ..maskFilter = null
        ..style = PaintingStyle.fill
        ..color = _withAlpha(glowColor, 0.26);
      canvas.drawCircle(center, radius * 1.8, _glow);

      _body
        ..maskFilter = null
        ..style = PaintingStyle.fill
        ..color = color;
      canvas.drawCircle(center, radius, _body);
    }
  }

  /// 발광하는 정다각형(손상된 도형 적 표현).
  static void polygon(
    Canvas canvas,
    Offset center,
    double radius,
    int sides,
    Color color, {
    Color? glow,
    double rotation = 0,
    double glowScale = 1.8,
    double strokeWidth = 2.5,
    bool blur = true,
  }) {
    final path = _poly..reset();
    for (var i = 0; i < sides; i++) {
      final a = rotation + (i / sides) * 2 * math.pi;
      final px = center.dx + radius * math.cos(a);
      final py = center.dy + radius * math.sin(a);
      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    path.close();

    final glowColor = glow ?? color;
    _glow
      ..color = _withAlpha(glowColor, blur ? 0.5 : 0.22)
      ..style = PaintingStyle.fill
      ..maskFilter = blur ? _blur(radius * glowScale * 0.6) : null;
    canvas.drawPath(path, _glow);

    _body
      ..maskFilter = null
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, _body);

    _fill
      ..maskFilter = null
      ..style = PaintingStyle.fill
      ..color = _withAlpha(color, 0.18);
    canvas.drawPath(path, _fill);
  }
}
