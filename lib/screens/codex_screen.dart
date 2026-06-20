import 'package:flutter/material.dart';

import '../config/lore.dart';
import '../config/palette.dart';
import '../systems/loc.dart';
import '../systems/save.dart';

/// 코덱스 — 누적 보스 처치로 해금되는 세계관 기록.
class CodexScreen extends StatelessWidget {
  const CodexScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final unlocked = SaveSystem.instance.loreUnlockedCount;
    return Scaffold(
      backgroundColor: Palette.voidDeep,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Palette.textHi),
        title: const Text('CODEX',
            style: TextStyle(letterSpacing: 4, fontWeight: FontWeight.w800)),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: Lore.entries.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final e = Lore.entries[i];
          final locked = i >= unlocked;
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Palette.voidMid.withValues(alpha: 0.5),
              border: Border.all(
                color: locked ? Colors.white12 : Palette.core.withValues(alpha: 0.4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(locked ? Icons.lock_outline : Icons.menu_book,
                        color: locked ? Palette.textDim : Palette.core,
                        size: 18),
                    const SizedBox(width: 8),
                    Text(
                      locked ? '???' : e.title,
                      style: TextStyle(
                        color: locked ? Palette.textDim : Palette.textHi,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  locked
                      ? t('누적 보스 처치로 해금됩니다.',
                          'Unlocked by defeating bosses over time.')
                      : e.body,
                  style: const TextStyle(
                      color: Palette.textDim, fontSize: 13, height: 1.4),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
