import 'package:flutter/material.dart';

import '../config/palette.dart';
import '../void_spark_game.dart';
import 'widgets/neon_button.dart';

/// 일시정지 오버레이 — 계속하기 / 메인으로.
class PauseOverlay extends StatelessWidget {
  const PauseOverlay({super.key, required this.game, required this.onMenu});

  final VoidSparkGame game;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Palette.voidDeep.withValues(alpha: 0.84),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'PAUSED',
            style: TextStyle(
              color: Palette.textHi,
              fontSize: 30,
              fontWeight: FontWeight.w900,
              letterSpacing: 6,
              shadows: [Shadow(color: Palette.coreGlow, blurRadius: 22)],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'SCORE  ${game.score}',
            style: const TextStyle(
              color: Palette.textDim,
              fontSize: 13,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 40),
          NeonButton(
            label: 'RESUME',
            color: Palette.core,
            width: 220,
            onTap: game.resumeGame,
          ),
          const SizedBox(height: 14),
          NeonButton(
            label: 'MENU',
            color: Palette.textDim,
            filled: false,
            width: 220,
            onTap: () async {
              // 중도 종료도 기록으로 인정.
              await game.finalizeRun();
              onMenu();
            },
          ),
        ],
      ),
    );
  }
}
