import 'package:flutter/material.dart';

import '../config/palette.dart';
import '../systems/leaderboard/leaderboard.dart';
import '../systems/loc.dart';
import '../systems/save.dart';

/// 리더보드 — 난이도별 로컬 TOP 기록 + (모바일) 글로벌 순위 + 이름 설정.
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  SaveSystem get save => SaveSystem.instance;
  late final TextEditingController _name =
      TextEditingController(text: save.playerName);

  // 보고 있는 난이도(기본: 현재 설정 난이도).
  late int _diff = save.difficulty;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entries = save.localTop(_diff);
    return Scaffold(
      backgroundColor: Palette.voidDeep,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Palette.textHi),
        title: const Text('RANKING',
            style: TextStyle(letterSpacing: 4, fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _nameField(),
          const SizedBox(height: 16),
          _difficultyTabs(),
          const SizedBox(height: 16),
          if (leaderboard.available)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GestureDetector(
                onTap: () => leaderboard.showGlobal(_diff),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: Palette.accent, width: 1.5),
                  ),
                  child: Text(
                      t('🌐 글로벌 순위 보기', '🌐 View Global Ranking'),
                      style: const TextStyle(
                        color: Palette.accent,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      )),
                ),
              ),
            ),
          Text(t('내 최고 기록 TOP 20', 'Your Best Scores — TOP 20'),
              style: const TextStyle(
                  color: Palette.textDim, fontSize: 12, letterSpacing: 3)),
          const SizedBox(height: 12),
          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Center(
                child: Text(t('아직 기록이 없어요', 'No records yet'),
                    style:
                        const TextStyle(color: Palette.textDim, fontSize: 14)),
              ),
            ),
          for (var i = 0; i < entries.length; i++) _row(i + 1, entries[i]),
        ],
      ),
    );
  }

  Widget _difficultyTabs() {
    const labels = ['EASY', 'NORMAL', 'HARD'];
    const colors = [Palette.accent, Palette.core, Palette.danger];
    return Row(
      children: [
        for (var i = 0; i < 3; i++)
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _diff = i),
              child: Container(
                margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: _diff == i
                      ? colors[i].withValues(alpha: 0.18)
                      : Colors.transparent,
                  border: Border.all(
                    color: _diff == i ? colors[i] : Palette.textDim,
                    width: _diff == i ? 2 : 1,
                  ),
                ),
                child: Text(labels[i],
                    style: TextStyle(
                      color: _diff == i ? colors[i] : Palette.textDim,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    )),
              ),
            ),
          ),
      ],
    );
  }

  Widget _nameField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Palette.voidMid.withValues(alpha: 0.5),
      ),
      child: Row(
        children: [
          Text(t('이름', 'Name'),
              style: const TextStyle(
                  color: Palette.textDim, fontSize: 14, letterSpacing: 1)),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _name,
              maxLength: 12,
              style: const TextStyle(
                  color: Palette.textHi, fontWeight: FontWeight.w700),
              cursorColor: Palette.core,
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
                hintText: 'PLAYER',
                hintStyle: TextStyle(color: Palette.textDim),
              ),
              onChanged: (v) => save.setPlayerName(v),
            ),
          ),
          const Icon(Icons.edit, color: Palette.textDim, size: 16),
        ],
      ),
    );
  }

  Widget _row(int rank, LeaderboardEntry e) {
    final medal = rank == 1
        ? Palette.scoreOrb
        : rank == 2
            ? Palette.textHi
            : rank == 3
                ? Palette.corrupt
                : Palette.textDim;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 34,
            child: Text('$rank',
                style: TextStyle(
                  color: medal,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                )),
          ),
          Expanded(
            child: Text(e.name,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Palette.textHi, fontWeight: FontWeight.w600)),
          ),
          Text('${e.score}',
              style: const TextStyle(
                  color: Palette.core,
                  fontSize: 16,
                  fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
