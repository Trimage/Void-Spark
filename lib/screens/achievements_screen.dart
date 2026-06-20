import 'package:flutter/material.dart';

import '../config/achievements.dart';
import '../config/palette.dart';
import '../systems/save.dart';

/// 업적 목록 — 해금/미해금 + 보상 표시.
class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final save = SaveSystem.instance;
    final total = Achievements.all.length;
    final done = Achievements.all.where((a) => save.achievementUnlocked(a.id)).length;

    return Scaffold(
      backgroundColor: Palette.voidDeep,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Palette.textHi),
        title: const Text('ACHIEVEMENTS',
            style: TextStyle(letterSpacing: 3, fontWeight: FontWeight.w800)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 18),
            child: Center(
              child: Text('$done / $total',
                  style: const TextStyle(
                      color: Palette.accent,
                      fontSize: 15,
                      fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: Achievements.all.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final a = Achievements.all[i];
          final got = save.achievementUnlocked(a.id);
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Palette.voidMid.withValues(alpha: 0.5),
              border: Border.all(
                color: got ? Palette.accent.withValues(alpha: 0.5) : Colors.white12,
              ),
            ),
            child: Row(
              children: [
                Icon(got ? Icons.emoji_events : Icons.lock_outline,
                    color: got ? Palette.accent : Palette.textDim, size: 26),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a.name,
                          style: TextStyle(
                            color: got ? Palette.textHi : Palette.textDim,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          )),
                      const SizedBox(height: 3),
                      Text(a.desc,
                          style: const TextStyle(
                              color: Palette.textDim, fontSize: 12)),
                    ],
                  ),
                ),
                Text('+${a.reward} ◆',
                    style: TextStyle(
                      color: got ? Palette.orb : Palette.textDim,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    )),
              ],
            ),
          );
        },
      ),
    );
  }
}
