import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../config/palette.dart';
import '../void_spark_game.dart';

/// 인게임 상단 HUD — 점수 + 웨이브 + Intensity 바.
/// (콤보/폭탄 버튼 등은 이후 단계에서 확장)
class Hud extends PositionComponent with HasGameReference<VoidSparkGame> {
  Hud() : super(priority: 100);

  late final TextComponent _score;
  late final TextComponent _wave;
  late final TextComponent _combo;

  @override
  Future<void> onLoad() async {
    _score = TextComponent(
      text: '0',
      anchor: Anchor.topCenter,
      position: Vector2(game.size.x / 2, 40),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Palette.textHi,
          fontSize: 34,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
          shadows: [Shadow(color: Palette.coreGlow, blurRadius: 16)],
        ),
      ),
    );
    _wave = TextComponent(
      text: 'WAVE 1',
      anchor: Anchor.topCenter,
      position: Vector2(game.size.x / 2, 80),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Palette.textDim,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 4,
        ),
      ),
    );
    _combo = TextComponent(
      text: '',
      anchor: Anchor.topCenter,
      position: Vector2(game.size.x / 2, 100),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Palette.accent,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
          shadows: [Shadow(color: Palette.accent, blurRadius: 12)],
        ),
      ),
    );
    await addAll([_score, _wave, _combo]);
  }

  @override
  void update(double dt) {
    final inset = game.topInset;
    _score.text = '${game.score}';
    _score.position = Vector2(game.size.x / 2, 40 + inset);
    _wave.text = 'SECTOR ${game.sector} · WAVE ${game.waves.waveNumber}';
    _wave.position = Vector2(game.size.x / 2, 80 + inset);

    // 콤보 배율(1.0 초과일 때만 표시).
    final mult = game.combo.multiplier;
    _combo.text = mult > 1.0 ? '×${mult.toStringAsFixed(1)}' : '';
    _combo.position = Vector2(game.size.x / 2, 100 + inset);
  }

  @override
  void render(Canvas canvas) {
    // 상단 Intensity 바.
    final w = game.size.x;
    final t = game.intensity.value;
    const margin = 24.0;
    final top = 18.0 + game.topInset;
    final barW = w - margin * 2;
    const barH = 4.0;

    final track = Paint()..color = Palette.textDim.withValues(alpha: 0.25);
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(margin, top, barW, barH),
      const Radius.circular(2),
    );
    canvas.drawRRect(rrect, track);

    // 강도에 따라 색이 시안→마젠타로 보간.
    final fillColor = Color.lerp(Palette.coreGlow, Palette.corruptGlow, t)!;
    final fill = Paint()
      ..color = fillColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    final fillRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(margin, top, barW * t, barH),
      const Radius.circular(2),
    );
    canvas.drawRRect(fillRect, fill);
    canvas.drawRRect(fillRect, Paint()..color = fillColor);

    _renderActivePowerups(canvas, w);
    _renderBossBar(canvas, w);
    _renderBossWarning(canvas, w);
    _renderLevelBar(canvas, w);
  }

  /// 상단 Intensity 바 아래 얇은 레벨 XP 바 + LV 라벨.
  void _renderLevelBar(Canvas canvas, double w) {
    const margin = 24.0;
    final top = 26.0 + game.topInset;
    final barW = w - margin * 2;
    const barH = 3.0;
    final p = game.xpProgress;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(margin, top, barW, barH),
        const Radius.circular(2),
      ),
      Paint()..color = Palette.textDim.withValues(alpha: 0.2),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(margin, top, barW * p, barH),
        const Radius.circular(2),
      ),
      Paint()..color = Palette.accent,
    );
    _lvPaint.render(canvas, 'LV ${game.level}', Vector2(margin, top + 6));
  }

  final TextPaint _lvPaint = TextPaint(
    style: const TextStyle(
      color: Palette.accent,
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 1,
    ),
  );

  /// 보스 등장 경고 배너(짧게 표시 후 사라짐).
  void _renderBossWarning(Canvas canvas, double w) {
    final t = game.bossWarnTimer;
    if (t <= 0) return;
    // 깜빡임(번쩍임 줄이기 설정이면 깜빡이지 않고 고정).
    final blink = game.juice.flashEnabled ? (t * 6).floor().isEven : true;
    if (!blink) return;
    _warnPaint.render(
      canvas,
      '⚠ WARNING ⚠',
      Vector2(w / 2, game.size.y * 0.34),
      anchor: Anchor.center,
    );
    _warnNamePaint.render(
      canvas,
      game.bossWarnName,
      Vector2(w / 2, game.size.y * 0.34 + 30),
      anchor: Anchor.center,
    );
  }

  final TextPaint _warnPaint = TextPaint(
    style: const TextStyle(
      color: Palette.danger,
      fontSize: 24,
      fontWeight: FontWeight.w900,
      letterSpacing: 6,
      shadows: [Shadow(color: Palette.danger, blurRadius: 18)],
    ),
  );

  final TextPaint _warnNamePaint = TextPaint(
    style: const TextStyle(
      color: Palette.textHi,
      fontSize: 16,
      fontWeight: FontWeight.w700,
      letterSpacing: 4,
    ),
  );

  /// 보스 등장 시 하단에 체력바 표시.
  void _renderBossBar(Canvas canvas, double w) {
    final boss = game.boss;
    if (boss == null) return;
    const margin = 40.0;
    final y = game.size.y - 54;
    final barW = w - margin * 2;
    const barH = 8.0;

    final track = RRect.fromRectAndRadius(
      Rect.fromLTWH(margin, y, barW, barH),
      const Radius.circular(4),
    );
    canvas.drawRRect(track, Paint()..color = Palette.danger.withValues(alpha: 0.18));
    canvas.drawRRect(
      track,
      Paint()
        ..color = Palette.danger.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    final ratio = boss.hpRatio.clamp(0.0, 1.0);
    final fill = RRect.fromRectAndRadius(
      Rect.fromLTWH(margin, y, barW * ratio, barH),
      const Radius.circular(4),
    );
    canvas.drawRRect(
      fill,
      Paint()
        ..color = Palette.corruptGlow
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawRRect(fill, Paint()..color = Palette.corrupt);

    _bossPaint.render(
      canvas,
      'CORRUPTED MONOLITH',
      Vector2(w / 2, y - 12),
      anchor: Anchor.bottomCenter,
    );
  }

  final TextPaint _bossPaint = TextPaint(
    style: const TextStyle(
      color: Palette.danger,
      fontSize: 12,
      fontWeight: FontWeight.w800,
      letterSpacing: 3,
      shadows: [Shadow(color: Palette.danger, blurRadius: 10)],
    ),
  );

  /// 우상단에 활성 지속형 파워업을 잔여시간 게이지와 함께 표시.
  void _renderActivePowerups(Canvas canvas, double w) {
    final p = game.powerups;
    final chips = <(String, Color, double)>[
      if (p.spreadActive)
        ('W', Palette.core, p.spreadRemaining / 8.0),
      if (p.rapidActive)
        ('R', Palette.accent, p.rapidRemaining / 7.0),
      if (p.slowActive)
        ('~', Palette.orb, p.slowRemaining / 4.0),
      if (p.magnetActive)
        ('M', Palette.corrupt, p.magnetRemaining / 7.0),
      if (p.pierceActive)
        ('»', Palette.coreGlow, p.pierceRemaining / 7.0),
      if (p.aimActive)
        ('◎', Palette.accent, p.aimRemaining / 8.0),
    ];

    const size = 26.0;
    const gap = 8.0;
    var x = w - 24 - size;
    final y = 36.0 + game.topInset;
    for (final (glyph, color, ratio) in chips) {
      final rect = Rect.fromLTWH(x, y, size, size);
      final rr = RRect.fromRectAndRadius(rect, const Radius.circular(7));
      canvas.drawRRect(
        rr,
        Paint()..color = color.withValues(alpha: 0.18),
      );
      canvas.drawRRect(
        rr,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
      // 하단 잔여시간 게이지.
      final g = ratio.clamp(0.0, 1.0);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y + size - 3, size * g, 3),
          const Radius.circular(2),
        ),
        Paint()..color = color,
      );
      _chipPaint.render(canvas, glyph, Vector2(x + size / 2, y + size / 2 - 1),
          anchor: Anchor.center);
      x -= size + gap;
    }
  }

  final TextPaint _chipPaint = TextPaint(
    style: const TextStyle(
      color: Palette.textHi,
      fontSize: 14,
      fontWeight: FontWeight.w800,
    ),
  );
}
