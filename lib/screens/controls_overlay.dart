import 'dart:async';

import 'package:flutter/material.dart';

import '../config/palette.dart';
import '../void_spark_game.dart';

/// 인게임 컨트롤 오버레이 — 우상단 일시정지 + 좌하단 폭탄 버튼.
class ControlsOverlay extends StatefulWidget {
  const ControlsOverlay({super.key, required this.game});

  final VoidSparkGame game;

  @override
  State<ControlsOverlay> createState() => _ControlsOverlayState();
}

class _ControlsOverlayState extends State<ControlsOverlay> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(
      const Duration(milliseconds: 120),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final playing = game.state == GameState.playing;
    // 조작 버튼은 설정에 따라 좌/우 배치. 일시정지는 반대편 상단.
    final right = game.save.controlsOnRight;

    return SafeArea(
      child: Stack(
        children: [
          // 일시정지: 항상 좌상단, 강도/XP 바(상단 전체폭) 아래로 내려 겹침 방지.
          // 우상단은 파워업 칩 영역이라 피한다.
          if (playing)
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 14, top: 48),
                child: _RoundButton(
                  icon: Icons.pause,
                  color: Palette.textDim,
                  onTap: game.pauseGame,
                ),
              ),
            ),
          // 폭탄(설정한 손 쪽 하단).
          Align(
            alignment: right ? Alignment.bottomRight : Alignment.bottomLeft,
            child: Padding(
              padding: EdgeInsets.only(
                left: right ? 0 : 24,
                right: right ? 24 : 0,
                bottom: 36,
              ),
              child: _BombButton(game: game),
            ),
          ),
        ],
      ),
    );
  }
}

class _BombButton extends StatelessWidget {
  const _BombButton({required this.game});
  final VoidSparkGame game;

  @override
  Widget build(BuildContext context) {
    final bombs = game.powerups.bombs;
    final enabled = bombs > 0 && game.state == GameState.playing;
    final color = enabled ? Palette.danger : Palette.textDim;

    return GestureDetector(
      onTap: enabled ? game.useBomb : null,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Palette.voidDeep.withValues(alpha: 0.6),
          border: Border.all(color: color, width: 2),
          boxShadow: enabled
              ? [BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 18)]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bolt, color: color, size: 24),
            Text(
              'x$bombs',
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Palette.voidDeep.withValues(alpha: 0.55),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}
