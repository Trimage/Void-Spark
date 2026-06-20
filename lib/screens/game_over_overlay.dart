import 'package:flutter/material.dart';

import '../config/palette.dart';
import '../systems/loc.dart';
import '../void_spark_game.dart';
import 'widgets/neon_button.dart';

/// 게임오버 오버레이 — 점수·최고기록(갱신 강조)·획득 파편·일일도전 +
/// 보상형 광고(부활 / 파편 2배, 둘 다 opt-in) + 다시하기/메인.
class GameOverOverlay extends StatefulWidget {
  const GameOverOverlay({
    super.key,
    required this.game,
    required this.onMenu,
  });

  final VoidSparkGame game;
  final VoidCallback onMenu;

  @override
  State<GameOverOverlay> createState() => _GameOverOverlayState();
}

class _GameOverOverlayState extends State<GameOverOverlay> {
  bool _busy = false;

  VoidSparkGame get game => widget.game;

  Future<void> _exit(Future<void> Function() after) async {
    if (_busy) return;
    setState(() => _busy = true);
    await game.finalizeRun();
    await after();
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(msg),
        duration: const Duration(milliseconds: 1400),
        backgroundColor: Palette.voidMid,
      ));
  }

  Future<void> _watchRevive() async {
    if (_busy) return;
    if (!game.ads.rewardedReady) {
      _snack(t('광고를 불러오는 중이에요. 잠시 후 다시 시도해 주세요.',
          'Ad is loading. Please try again shortly.'));
      return;
    }
    setState(() => _busy = true);
    final ok = await game.ads.showRewarded();
    if (ok) {
      game.revive(); // 오버레이가 제거되고 게임 재개.
    } else {
      _snack(t('보상이 확인되지 않았어요. 광고를 끝까지 봐야 부활해요.',
          'No reward — watch the full ad to revive.'));
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _watchDoubleShards() async {
    if (_busy) return;
    if (!game.ads.rewardedReady) {
      _snack(t('광고를 불러오는 중이에요. 잠시 후 다시 시도해 주세요.',
          'Ad is loading. Please try again shortly.'));
      return;
    }
    setState(() => _busy = true);
    final ok = await game.ads.showRewarded();
    if (ok) {
      game.applyDoubleShards();
    } else {
      _snack(t('보상이 확인되지 않았어요. 광고를 끝까지 봐야 받을 수 있어요.',
          'No reward — watch the full ad to claim.'));
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final result = game.runPreview;
    final isRecord = result.newHighScore;
    final adsOn = game.ads.available;

    return Container(
      color: Palette.voidDeep.withValues(alpha: 0.88),
      alignment: Alignment.center,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'VOID COLLAPSED',
              style: TextStyle(
                color: Palette.danger,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: 3,
                shadows: [Shadow(color: Palette.danger, blurRadius: 20)],
              ),
            ),
            const SizedBox(height: 24),
            if (isRecord)
              const Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Text(
                  '★ NEW RECORD ★',
                  style: TextStyle(
                    color: Palette.accent,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                    shadows: [Shadow(color: Palette.accent, blurRadius: 14)],
                  ),
                ),
              ),
            Text(
              '${game.score}',
              style: TextStyle(
                color: isRecord ? Palette.accent : Palette.textHi,
                fontSize: 58,
                fontWeight: FontWeight.w900,
                shadows: [
                  Shadow(
                    color: isRecord ? Palette.accent : Palette.coreGlow,
                    blurRadius: 26,
                  ),
                ],
              ),
            ),
            Text(
              'BEST  ${game.save.highScore}',
              style: const TextStyle(
                color: Palette.textDim,
                fontSize: 13,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 14),
            _RunStats(game: game),
            const SizedBox(height: 14),
            _ShardRow(earned: result.shardsEarned, doubled: game.shardsDoubled),
            if (result.dailyCompleted)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  '${t('일일 도전 완료!', 'Daily challenge done!')}  +${result.dailyReward} ◆',
                  style: const TextStyle(
                    color: Palette.accent,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            for (final a in result.newAchievements)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '🏆 ${t('업적 해금', 'Achievement')} — $a',
                  style: const TextStyle(
                    color: Palette.accent,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            const SizedBox(height: 28),

            // 보상형 광고(opt-in) — 지원 플랫폼에서만 노출.
            if (adsOn && game.canRevive) ...[
              _AdButton(
                label: t('부활하기', 'Revive', ja: '復活', zh: '复活'),
                icon: Icons.favorite,
                color: Palette.danger,
                onTap: _watchRevive,
              ),
              const SizedBox(height: 12),
            ],
            if (adsOn && !game.shardsDoubled) ...[
              _AdButton(
                label: t('파편 2배', 'Double Shards', ja: '破片2倍', zh: '碎片翻倍'),
                icon: Icons.diamond_outlined,
                color: Palette.orb,
                onTap: _watchDoubleShards,
              ),
              const SizedBox(height: 20),
            ],

            NeonButton(
              label: 'RETRY',
              color: Palette.core,
              onTap: () => _exit(() async {
                game.overlays.remove(VoidSparkGame.gameOverOverlay);
                game.restart();
              }),
            ),
            const SizedBox(height: 14),
            NeonButton(
              label: 'MENU',
              color: Palette.textDim,
              filled: false,
              onTap: () => _exit(() async => widget.onMenu()),
            ),
          ],
        ),
      ),
    );
  }
}

/// 보상형 광고 버튼 — "광고" 라벨로 광고임을 명확히 표기.
class _AdButton extends StatelessWidget {
  const _AdButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          color: color.withValues(alpha: 0.12),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: Palette.textHi,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                t('광고', 'AD'),
                style: const TextStyle(
                  color: Palette.textHi,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 런 결과 요약 — 처치/최대 콤보/그레이즈/생존 시간.
class _RunStats extends StatelessWidget {
  const _RunStats({required this.game});
  final VoidSparkGame game;

  @override
  Widget build(BuildContext context) {
    final secs = game.runTime.floor();
    final time = '${(secs ~/ 60)}:${(secs % 60).toString().padLeft(2, '0')}';
    Widget cell(String label, String value) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value,
                style: const TextStyle(
                  color: Palette.textHi,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                )),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    color: Palette.textDim, fontSize: 11, letterSpacing: 1)),
          ],
        );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        cell(t('처치', 'Kills', ja: '撃破', zh: '击杀'),
            '${game.enemiesKilledThisRun}'),
        cell(t('최대 콤보', 'Max Combo', ja: '最大コンボ', zh: '最大连击'),
            '${game.maxComboThisRun}'),
        cell(t('그레이즈', 'Graze', ja: 'グレイズ', zh: '擦弹'),
            '${game.grazeThisRun}'),
        cell(t('생존', 'Time', ja: '生存', zh: '存活'), time),
      ],
    );
  }
}

class _ShardRow extends StatelessWidget {
  const _ShardRow({required this.earned, required this.doubled});
  final int earned;
  final bool doubled;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.diamond_outlined, color: Palette.orb, size: 18),
        const SizedBox(width: 6),
        Text(
          '+$earned ${t('파편', 'shards')}',
          style: const TextStyle(
            color: Palette.orb,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (doubled) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: Palette.accent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              '×2',
              style: TextStyle(
                color: Palette.accent,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
