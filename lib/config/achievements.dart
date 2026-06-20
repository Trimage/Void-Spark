import '../systems/loc.dart';

/// 업적 평가에 필요한 한 판의 스냅샷 + 누적 통계.
class AchievementContext {
  const AchievementContext({
    required this.score,
    required this.bossKills,
    required this.maxCombo,
    required this.graze,
    required this.reachedEnding,
    required this.totalBossKills,
  });

  final int score;
  final int bossKills;
  final int maxCombo;
  final int graze;
  final bool reachedEnding;
  final int totalBossKills;
}

/// 업적 정의(다국어 맵). [test]가 참이 되면 해금되고 [reward] 파편을 1회 지급.
class AchievementDef {
  AchievementDef(this.id, this._name, this._desc, this.reward, this.test);

  final String id;
  final Map<String, String> _name;
  final Map<String, String> _desc;
  final int reward;
  final bool Function(AchievementContext c) test;

  String get name => tr(_name);
  String get desc => tr(_desc);
}

class Achievements {
  Achievements._();

  static final List<AchievementDef> all = [
    AchievementDef(
        'first_boss',
        {'ko': '첫 균열', 'en': 'First Crack', 'ja': '最初の亀裂', 'zh': '初次裂痕'},
        {'ko': '보스를 처음 처치', 'en': 'Defeat your first boss', 'ja': '初めてボスを撃破', 'zh': '首次击败Boss'},
        50,
        (c) => c.bossKills >= 1),
    AchievementDef(
        'ending',
        {'ko': '빛의 귀환', 'en': 'Light Restored', 'ja': '光の帰還', 'zh': '光之归来'},
        {'ko': '한 판에 보스 3회 처치', 'en': 'Defeat 3 bosses in one run', 'ja': '1回で3体撃破', 'zh': '单局击败3个Boss'},
        200,
        (c) => c.reachedEnding),
    AchievementDef(
        'combo30',
        {'ko': '연쇄 반응', 'en': 'Chain Reaction', 'ja': '連鎖反応', 'zh': '连锁反应'},
        {'ko': '한 판에 콤보 30', 'en': 'Reach a 30 combo', 'ja': 'コンボ30達成', 'zh': '达成30连击'},
        80,
        (c) => c.maxCombo >= 30),
    AchievementDef(
        'graze100',
        {'ko': '칼날 위에서', 'en': 'On the Edge', 'ja': '紙一重', 'zh': '游走刀尖'},
        {'ko': '한 판에 그레이즈 100', 'en': 'Graze 100 bullets', 'ja': 'グレイズ100回', 'zh': '擦弹100次'},
        80,
        (c) => c.graze >= 100),
    AchievementDef(
        'score5000',
        {'ko': '빛나는 기록', 'en': 'Brilliant', 'ja': '輝く記録', 'zh': '闪耀纪录'},
        {'ko': '한 판에 5000점', 'en': 'Score 5000 in a run', 'ja': '5000点達成', 'zh': '单局5000分'},
        60,
        (c) => c.score >= 5000),
    AchievementDef(
        'veteran',
        {'ko': '공허의 베테랑', 'en': 'Void Veteran', 'ja': '虚空の古強者', 'zh': '虚空老兵'},
        {'ko': '누적 보스 10회 처치', 'en': 'Defeat 10 bosses total', 'ja': '累計10体撃破', 'zh': '累计击败10个Boss'},
        150,
        (c) => c.totalBossKills >= 10),
  ];
}
