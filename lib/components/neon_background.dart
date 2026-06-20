import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../config/game_config.dart';
import '../config/palette.dart';
import '../void_spark_game.dart';

/// 디지털 공허 배경. 어두운 그라데이션 + 미세한 그리드 + 펄스.
/// 섹터가 오를수록 그리드·비네트 색조가 바뀐다.
class NeonBackground extends PositionComponent
    with HasGameReference<VoidSparkGame> {
  NeonBackground() : super(priority: -100);

  double _t = 0;

  // 섹터별 강조 색(순환).
  static const List<Color> _sectorColors = [
    Palette.coreGlow, // 1: 시안
    Color(0xFF8BFF00), // 2: 라임
    Color(0xFFB388FF), // 3: 바이올렛
    Color(0xFFFF6B2E), // 4: 오렌지
    Color(0xFFFF2EC4), // 5: 마젠타
  ];

  Color get _sectorColor =>
      _sectorColors[(game.sector - 1) % _sectorColors.length];

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
  }

  @override
  void update(double dt) {
    _t += dt;
  }

  @override
  void render(Canvas canvas) {
    final w = size.x;
    final h = size.y;
    final rect = Rect.fromLTWH(0, 0, w, h);

    // 펄스(번쩍임 줄이기 시 약하게).
    final pulseAmp = game.juice.flashEnabled ? 1.0 : 0.3;
    final pulse = (0.5 +
            0.5 * math.sin(_t * 2 * math.pi / GameConfig.bgPulsePeriod)) *
        pulseAmp;
    final accent = _sectorColor;

    // 세로 그라데이션 배경.
    final bg = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Palette.voidMid, Palette.voidDeep],
      ).createShader(rect);
    canvas.drawRect(rect, bg);

    // 미세 그리드(섹터 색).
    final gridPaint = Paint()
      ..color = accent.withValues(alpha: 0.05 + 0.03 * pulse)
      ..strokeWidth = 1;
    const spacing = 48.0;
    for (double x = 0; x <= w; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, h), gridPaint);
    }
    for (double y = 0; y <= h; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    // 중심부 발광 비네트(섹터 색, 펄스).
    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          accent.withValues(alpha: 0.10 + 0.06 * pulse),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(center: Offset(w / 2, h * 0.55), radius: w * 0.8),
      );
    canvas.drawRect(rect, glow);
  }
}
