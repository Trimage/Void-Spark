import 'package:flutter/material.dart';

import '../config/palette.dart';
import '../systems/loc.dart';
import '../void_spark_game.dart';
import 'widgets/neon_button.dart';

/// 엔딩(빛의 귀환) 오버레이 — 계속(무한 모드) / 종료(메인).
class VictoryOverlay extends StatelessWidget {
  const VictoryOverlay({super.key, required this.game, required this.onMenu});

  final VoidSparkGame game;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Palette.voidDeep.withValues(alpha: 0.9),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'LIGHT RESTORED',
            style: TextStyle(
              color: Palette.core,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
              shadows: [Shadow(color: Palette.coreGlow, blurRadius: 28)],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            t('빛을 되찾았다 — 그러나 공허는 끝나지 않는다',
                'Light restored — but the Void is not done',
                ja: '光を取り戻した — だが虚空は終わらない',
                zh: '夺回了光明 — 但虚空仍未终结'),
            style: const TextStyle(color: Palette.textDim, fontSize: 13),
          ),
          const SizedBox(height: 14),
          Text(
            'SCORE  ${game.score}',
            style: const TextStyle(
              color: Palette.textHi,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 40),
          NeonButton(
            label: 'CONTINUE',
            color: Palette.core,
            width: 240,
            onTap: game.continueEndless,
          ),
          const SizedBox(height: 14),
          NeonButton(
            label: 'FINISH',
            color: Palette.accent,
            filled: false,
            width: 240,
            onTap: () async {
              await game.finalizeRun();
              onMenu();
            },
          ),
        ],
      ),
    );
  }
}
