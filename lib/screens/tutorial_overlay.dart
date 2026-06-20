import 'package:flutter/material.dart';

import '../config/palette.dart';
import '../systems/loc.dart';
import '../void_spark_game.dart';
import 'widgets/neon_button.dart';

/// 첫 플레이 안내 — 조작/규칙을 간단히 설명한 뒤 시작.
class TutorialOverlay extends StatelessWidget {
  const TutorialOverlay({super.key, required this.game});

  final VoidSparkGame game;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Palette.voidDeep.withValues(alpha: 0.92),
      alignment: Alignment.center,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'HOW TO PLAY',
              style: TextStyle(
                color: Palette.core,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
                shadows: [Shadow(color: Palette.coreGlow, blurRadius: 20)],
              ),
            ),
            const SizedBox(height: 28),
            _Row(
                Icons.touch_app,
                t('드래그로 이동', 'Drag to move', ja: 'ドラッグで移動', zh: '拖动移动'),
                t('화면을 끌면 코어가 손가락을 따라 움직여요.',
                    'Drag anywhere — the core follows your finger.',
                    ja: '画面をドラッグするとコアが指に追従します。',
                    zh: '拖动屏幕，核心会跟随你的手指。')),
            _Row(
                Icons.auto_awesome,
                t('사격은 자동', 'Auto-fire', ja: '射撃は自動', zh: '自动射击'),
                t('적은 알아서 조준·발사돼요. 회피에 집중!',
                    'Shooting is automatic — focus on dodging!',
                    ja: '射撃は自動。回避に集中！', zh: '自动瞄准射击，专注闪避！')),
            _Row(
                Icons.diamond_outlined,
                t('오브를 주워 점수', 'Collect orbs', ja: 'オーブで得点', zh: '拾取光球'),
                t('처치 시 떨어지는 빛 조각을 직접 닿아 모아요.',
                    'Touch the light shards dropped by kills to score.',
                    ja: '撃破で落ちる光をコアで集めよう。',
                    zh: '触碰击杀掉落的光之碎片来得分。')),
            _Row(
                Icons.bolt,
                t('폭탄으로 위기 탈출', 'Bomb to escape', ja: 'ボムで脱出', zh: '炸弹脱险'),
                t('좌하단 버튼으로 화면의 적·탄을 한 번에 제거.',
                    'Clear all enemies & bullets with the corner button.',
                    ja: 'ボタンで敵と弾を一掃。', zh: '用按钮一次清除敌人和子弹。')),
            _Row(
                Icons.warning_amber,
                t('오래 버틸수록 강해짐', 'It ramps up', ja: '時間で激化', zh: '越久越难'),
                t('시간이 갈수록 적이 빨라지고 많아져요.',
                    'Enemies get faster and denser over time.',
                    ja: '時間とともに敵が速く多くなる。', zh: '随时间推移敌人更快更多。')),
            const SizedBox(height: 32),
            NeonButton(
              label: 'START',
              color: Palette.core,
              width: 220,
              onTap: game.dismissTutorial,
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.icon, this.title, this.body);
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Palette.core, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                      color: Palette.textHi,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    )),
                const SizedBox(height: 3),
                Text(body,
                    style: const TextStyle(
                        color: Palette.textDim, fontSize: 13, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
