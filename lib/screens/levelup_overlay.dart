import 'package:flutter/material.dart';

import '../config/palette.dart';
import '../config/run_upgrades.dart';
import '../systems/loc.dart';
import '../void_spark_game.dart';

/// 레벨업 시 인런 강화 3택 1 선택 오버레이.
class LevelUpOverlay extends StatelessWidget {
  const LevelUpOverlay({super.key, required this.game});

  final VoidSparkGame game;

  static const Map<String, IconData> _icons = {
    'bolt': Icons.bolt,
    'spread': Icons.open_in_full,
    'dmg': Icons.whatshot,
    'move': Icons.speed,
    'magnet': Icons.adjust,
    'combo': Icons.timer,
    'orb': Icons.diamond,
    'pierce': Icons.double_arrow,
    'back': Icons.swap_vert,
    'shield': Icons.shield,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Palette.voidDeep.withValues(alpha: 0.9),
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'LEVEL ${game.level}',
              style: const TextStyle(
                color: Palette.accent,
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
                shadows: [Shadow(color: Palette.accent, blurRadius: 18)],
              ),
            ),
            const SizedBox(height: 6),
            Text(t('강화를 선택하세요', 'Choose an upgrade',
                ja: '強化を選択', zh: '选择强化'),
                style: const TextStyle(color: Palette.textDim, fontSize: 13)),
            const SizedBox(height: 24),
            for (final u in game.levelChoices) ...[
              _card(u),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }

  Widget _card(RunUpgradeDef u) {
    return GestureDetector(
      onTap: () => game.chooseUpgrade(u),
      child: Container(
        width: 320,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Palette.voidMid.withValues(alpha: 0.7),
          border: Border.all(color: Palette.core, width: 1.5),
          boxShadow: [
            BoxShadow(
                color: Palette.coreGlow.withValues(alpha: 0.3), blurRadius: 16),
          ],
        ),
        child: Row(
          children: [
            Icon(_icons[u.icon] ?? Icons.star, color: Palette.core, size: 30),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(u.name,
                      style: const TextStyle(
                        color: Palette.textHi,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      )),
                  const SizedBox(height: 3),
                  Text(u.desc,
                      style: const TextStyle(
                          color: Palette.textDim, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
