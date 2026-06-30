import 'package:flutter/material.dart';

import '../config/game_config.dart';
import '../config/palette.dart';
import '../systems/loc.dart';
import '../systems/save.dart';
import 'achievements_screen.dart';
import 'codex_screen.dart';
import 'game_screen.dart';
import 'leaderboard_screen.dart';
import 'settings_screen.dart';
import 'shop_screen.dart';
import 'widgets/neon_button.dart';

/// 메인 메뉴 — 타이틀, 시작, 최고 기록, 상점, 일일 도전.
class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  SaveSystem get save => SaveSystem.instance;

  Future<void> _push(Widget screen) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
    if (mounted) setState(() {}); // 돌아오면 기록/재화 갱신.
  }

  @override
  Widget build(BuildContext context) {
    final daily = save.daily;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Palette.voidMid, Palette.voidDeep],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                _topBar(),
                const Spacer(flex: 2),
                _title(),
                const Spacer(flex: 2),
                NeonButton(
                  label: 'START',
                  width: 240,
                  onTap: () => _push(const GameScreen()),
                ),
                const SizedBox(height: 16),
                NeonButton(
                  label: 'SHOP',
                  color: Palette.orb,
                  filled: false,
                  width: 240,
                  onTap: () => _push(const ShopScreen()),
                ),
                const Spacer(),
                _dailyCard(daily),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events_outlined,
                  color: Palette.accent, size: 18),
              const SizedBox(width: 6),
              Text(
                '${save.highScore}',
                style: const TextStyle(
                  color: Palette.textHi,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.diamond_outlined,
                  color: Palette.orb, size: 18),
              const SizedBox(width: 6),
              Text(
                '${save.shards}',
                style: const TextStyle(
                  color: Palette.orb,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 2),
              IconButton(
                icon: const Icon(Icons.leaderboard_outlined,
                    color: Palette.textDim, size: 20),
                tooltip: t('랭킹', 'Ranking'),
                onPressed: () => _push(const LeaderboardScreen()),
              ),
              IconButton(
                icon: const Icon(Icons.menu_book_outlined,
                    color: Palette.textDim, size: 20),
                tooltip: t('코덱스', 'Codex'),
                onPressed: () => _push(const CodexScreen()),
              ),
              IconButton(
                icon: const Icon(Icons.emoji_events_outlined,
                    color: Palette.textDim, size: 20),
                tooltip: t('업적', 'Achievements'),
                onPressed: () => _push(const AchievementsScreen()),
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined,
                    color: Palette.textDim, size: 20),
                onPressed: () => _push(const SettingsScreen()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _title() {
    return Column(
      children: [
        const Text(
          'VOID',
          style: TextStyle(
            color: Palette.textHi,
            fontSize: 58,
            fontWeight: FontWeight.w900,
            letterSpacing: 10,
            shadows: [Shadow(color: Palette.coreGlow, blurRadius: 28)],
          ),
        ),
        const Text(
          'SPARK',
          style: TextStyle(
            color: Palette.core,
            fontSize: 58,
            fontWeight: FontWeight.w900,
            letterSpacing: 10,
            shadows: [Shadow(color: Palette.coreGlow, blurRadius: 36)],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          t('마지막 빛이 꺼질 때까지', 'Until the last light fades',
              ja: '最後の光が消えるまで', zh: '直到最后的光熄灭'),
          style: const TextStyle(
            color: Palette.textDim,
            fontSize: 13,
            letterSpacing: 4,
          ),
        ),
      ],
    );
  }

  Widget _dailyCard(DailyChallenge daily) {
    final progress = save.dailyProgress.clamp(0, daily.target);
    final done = save.dailyComplete;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Palette.voidMid.withValues(alpha: 0.6),
        border: Border.all(
          color: (done ? Palette.accent : Palette.corrupt)
              .withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'DAILY CHALLENGE',
                style: TextStyle(
                  color: Palette.textDim,
                  fontSize: 11,
                  letterSpacing: 3,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                done
                    ? '${t('완료', 'DONE')} +${GameConfig.dailyReward} ◆'
                    : '+${GameConfig.dailyReward} ◆',
                style: TextStyle(
                  color: done ? Palette.accent : Palette.orb,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            daily.desc,
            style: const TextStyle(
              color: Palette.textHi,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: daily.target == 0 ? 0 : progress / daily.target,
              minHeight: 6,
              backgroundColor: Palette.voidDeep,
              color: done ? Palette.accent : Palette.corrupt,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$progress / ${daily.target}',
            style: const TextStyle(color: Palette.textDim, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
