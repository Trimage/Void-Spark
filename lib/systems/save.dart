import 'dart:math' as math;
import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';

import '../config/achievements.dart';
import '../config/game_config.dart';
import '../config/lore.dart';
import '../config/skins.dart';
import '../config/upgrades.dart';
import 'iap/iap_service.dart';
import 'loc.dart';

/// 일일 도전 측정 기준.
enum Metric { bosses, orbs, score }

/// 하루 1개의 일일 도전. 날짜에 따라 결정적으로 선택된다.
class DailyChallenge {
  const DailyChallenge(this._desc, this.target, this.metric);

  final Map<String, String> _desc;
  final int target;
  final Metric metric;

  String get desc => tr(_desc);

  static const List<DailyChallenge> _pool = [
    DailyChallenge(
        {'ko': '보스 2회 처치', 'en': 'Defeat 2 bosses', 'ja': 'ボスを2体撃破', 'zh': '击败2个Boss'},
        2,
        Metric.bosses),
    DailyChallenge(
        {'ko': '오브 200개 획득', 'en': 'Collect 200 orbs', 'ja': 'オーブ200個獲得', 'zh': '收集200光球'},
        200,
        Metric.orbs),
    DailyChallenge(
        {'ko': '한 판에 3000점 달성', 'en': 'Score 3000 in a run', 'ja': '1回で3000点', 'zh': '单局达成3000分'},
        3000,
        Metric.score),
  ];

  static DailyChallenge forDate(DateTime d) {
    final doy = d.difference(DateTime(d.year)).inDays;
    return _pool[doy % _pool.length];
  }
}

/// 로컬 리더보드 1행.
class LeaderboardEntry {
  const LeaderboardEntry(this.name, this.score);
  final String name;
  final int score;

  static const String _sep = '\u0001';

  String encode() => '$name$_sep$score';

  static LeaderboardEntry decode(String s) {
    final parts = s.split(_sep);
    return LeaderboardEntry(
      parts.isNotEmpty ? parts[0] : 'PLAYER',
      parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0,
    );
  }
}

/// 한 판 종료 결과 — 게임오버 화면 표시용.
class RunResult {
  const RunResult({
    required this.score,
    required this.newHighScore,
    required this.shardsEarned,
    required this.dailyCompleted,
    required this.dailyReward,
    this.newAchievements = const [],
  });

  final int score;
  final bool newHighScore;
  final int shardsEarned;
  final bool dailyCompleted;
  final int dailyReward;

  /// 이번 판에 새로 해금된 업적 이름들.
  final List<String> newAchievements;
}

/// 로컬 저장(shared_preferences) — 기록/재화/해금/일일도전/설정/리더보드.
class SaveSystem {
  SaveSystem._();
  static final SaveSystem instance = SaveSystem._();

  late SharedPreferences _p;

  Future<void> load() async {
    _p = await SharedPreferences.getInstance();
    await _ensureDaily();
  }

  // ---- 기록 / 재화 ----
  int get highScore => _p.getInt('highScore') ?? 0;
  int get shards => _p.getInt('shards') ?? 0;

  // ---- 누적 통계 / 업적 / 코덱스 ----
  int get totalBossKills => _p.getInt('totalBossKills') ?? 0;

  List<String> get _achievements => _p.getStringList('achievements') ?? const [];
  bool achievementUnlocked(String id) => _achievements.contains(id);

  /// 누적 보스 처치 수에 비례해 코덱스 항목이 순서대로 해금된다.
  int get loreUnlockedCount => totalBossKills.clamp(0, Lore.entries.length);

  // ---- 설정 ----
  bool get soundOn => _p.getBool('soundOn') ?? true;
  bool get hapticsOn => _p.getBool('hapticsOn') ?? true;
  bool get relativeDrag => _p.getBool('relativeDrag') ?? true;
  double get sfxVolume => _p.getDouble('sfxVolume') ?? 0.7;
  double get bgmVolume => _p.getDouble('bgmVolume') ?? 0.5;

  /// 조작 버튼(폭탄) 배치 — true=오른쪽 하단(기본), false=왼쪽 하단.
  bool get controlsOnRight => _p.getBool('controlsOnRight') ?? true;

  /// 아슬아슬 회피 슬로우모션 연출 사용 여부.
  bool get slowMoOn => _p.getBool('slowMoOn') ?? true;

  /// 언어 ('ko' / 'en'). 미설정 시 기기 언어 기반 기본값.
  String get lang =>
      _p.getString('lang') ??
      (PlatformDispatcher.instance.locale.languageCode == 'ko' ? 'ko' : 'en');
  Future<void> setLang(String v) => _p.setString('lang', v);

  /// 접근성 — 번쩍임 줄이기(플래시 off + 흔들림 감쇠), 화면 흔들림 강도(0~1).
  bool get reduceFlashing => _p.getBool('reduceFlashing') ?? false;
  double get shakeIntensity => _p.getDouble('shakeIntensity') ?? 1.0;

  Future<void> setSound(bool v) => _p.setBool('soundOn', v);
  Future<void> setHaptics(bool v) => _p.setBool('hapticsOn', v);
  Future<void> setRelativeDrag(bool v) => _p.setBool('relativeDrag', v);
  Future<void> setSfxVolume(double v) => _p.setDouble('sfxVolume', v);
  Future<void> setBgmVolume(double v) => _p.setDouble('bgmVolume', v);
  Future<void> setControlsOnRight(bool v) => _p.setBool('controlsOnRight', v);
  Future<void> setSlowMo(bool v) => _p.setBool('slowMoOn', v);
  Future<void> setReduceFlashing(bool v) => _p.setBool('reduceFlashing', v);
  Future<void> setShakeIntensity(double v) => _p.setDouble('shakeIntensity', v);

  // ---- 튜토리얼 ----
  bool get tutorialSeen => _p.getBool('tutorialSeen') ?? false;
  Future<void> setTutorialSeen() => _p.setBool('tutorialSeen', true);
  Future<void> resetTutorial() => _p.setBool('tutorialSeen', false);

  // ---- 플레이어 이름 / 로컬 리더보드 ----
  String get playerName => _p.getString('playerName') ?? '';
  Future<void> setPlayerName(String v) =>
      _p.setString('playerName', v.trim().replaceAll('\u0001', ''));

  String _lbKey(int difficulty) => 'lb_$difficulty';

  /// 지정 난이도의 로컬 TOP 20.
  List<LeaderboardEntry> localTop(int difficulty) =>
      (_p.getStringList(_lbKey(difficulty)) ?? const [])
          .map(LeaderboardEntry.decode)
          .toList();

  /// 현재 난이도 로컬 리더보드에 점수를 등록하고 순위(1부터)를 반환. 미진입 시 -1.
  Future<int> submitLocalScore(int score) async {
    final d = difficulty;
    final name = playerName.isEmpty ? 'PLAYER' : playerName;
    final list = localTop(d)..add(LeaderboardEntry(name, score));
    list.sort((a, b) => b.score.compareTo(a.score));
    final top = list.take(20).toList();
    await _p.setStringList(_lbKey(d), top.map((e) => e.encode()).toList());
    final rank = top.indexWhere((e) => e.score == score && e.name == name);
    return rank < 0 ? -1 : rank + 1;
  }

  // ---- 전세계 순위 변동 추적(난이도별 마지막으로 본 순위) ----
  /// 마지막으로 표시한 전세계 순위(없으면 0). 변동(▲▼) 계산에 사용.
  int prevGlobalRank(int difficulty) => _p.getInt('grank_$difficulty') ?? 0;
  Future<void> setPrevGlobalRank(int difficulty, int rank) =>
      _p.setInt('grank_$difficulty', rank);

  // ---- 난이도 (0=Easy, 1=Normal, 2=Hard) ----
  int get difficulty => (_p.getInt('difficulty') ?? 1).clamp(0, 2);
  Future<void> setDifficulty(int v) => _p.setInt('difficulty', v.clamp(0, 2));

  /// 난이도별 파편 보상 배율(어려울수록 보상↑).
  double get difficultyShardMul => const [0.8, 1.0, 1.25][difficulty];

  // ---- 영구 업그레이드 ----
  int upgradeLevel(String id) => _p.getInt(id) ?? 0;

  /// 다음 레벨 비용(최대면 null).
  int? upgradeCost(UpgradeDef u) {
    final lvl = upgradeLevel(u.id);
    return lvl >= u.maxLevel ? null : u.costs[lvl];
  }

  Future<bool> buyUpgrade(UpgradeDef u) async {
    final lvl = upgradeLevel(u.id);
    if (lvl >= u.maxLevel) return false;
    final cost = u.costs[lvl];
    if (shards < cost) return false;
    await _p.setInt('shards', shards - cost);
    await _p.setInt(u.id, lvl + 1);
    return true;
  }

  // ---- 시작 보너스: 시작 실드 ----
  bool get startShieldUnlocked => _p.getBool('startShield') ?? false;

  Future<bool> buyStartShield() async {
    if (startShieldUnlocked || shards < GameConfig.startShieldPrice) {
      return false;
    }
    await _p.setInt('shards', shards - GameConfig.startShieldPrice);
    await _p.setBool('startShield', true);
    return true;
  }

  bool get startBombUnlocked => _p.getBool('startBomb') ?? false;

  Future<bool> buyStartBomb() async {
    if (startBombUnlocked || shards < GameConfig.startBombPrice) return false;
    await _p.setInt('shards', shards - GameConfig.startBombPrice);
    await _p.setBool('startBomb', true);
    return true;
  }

  bool get startComboUnlocked => _p.getBool('startCombo') ?? false;

  Future<bool> buyStartCombo() async {
    if (startComboUnlocked || shards < GameConfig.startComboPrice) return false;
    await _p.setInt('shards', shards - GameConfig.startComboPrice);
    await _p.setBool('startCombo', true);
    return true;
  }

  // ---- 인앱결제 권한 / 지급 ----
  bool get doubleShards => _p.getBool('iap_double_shards') ?? false;
  bool get premiumSkinsOwned => _p.getBool('iap_premium_skins') ?? false;
  bool get skinPack2Owned => _p.getBool('iap_skin_pack2') ?? false;

  Future<void> addShards(int n) => _p.setInt('shards', shards + n);

  /// 결제 완료/복원 시 보상 지급(비소비성은 idempotent).
  Future<void> deliverPurchase(String productId) async {
    final p = IapCatalog.byId(productId);
    if (p == null) return;
    switch (p.kind) {
      case IapKind.consumableShards:
        await addShards(p.shards);
      case IapKind.entitlement:
        if (p.id == IapCatalog.doubleShards.id) {
          await _p.setBool('iap_double_shards', true);
        } else if (p.id == IapCatalog.premiumSkins.id) {
          await _p.setBool('iap_premium_skins', true);
        } else if (p.id == IapCatalog.skinPack2.id) {
          await _p.setBool('iap_skin_pack2', true);
        } else if (p.id == IapCatalog.foundersPack.id) {
          // 번들: 프리미엄 스킨 + 파편 2배 + 보너스 파편(1회).
          await _p.setBool('iap_premium_skins', true);
          await _p.setBool('iap_double_shards', true);
          if (!(_p.getBool('iap_founders') ?? false)) {
            await _p.setBool('iap_founders', true);
            await addShards(2000);
          }
        }
    }
  }

  bool get foundersOwned => _p.getBool('iap_founders') ?? false;

  // ---- 스킨 ----
  int get skinIndex => _p.getInt('skinIndex') ?? 0;

  Set<int> get _owned =>
      (_p.getStringList('owned') ?? const ['0']).map(int.parse).toSet();

  bool isSkinOwned(int index) => index == 0 || _owned.contains(index);

  /// 장착 가능 여부 — 프리미엄 스킨은 해당 IAP 팩 보유 시에만.
  bool skinAvailable(int index) {
    final s = Skins.at(index);
    final pack = s.packId;
    if (pack == null) return isSkinOwned(index);
    return skinPackOwned(pack);
  }

  bool skinPackOwned(String packId) => switch (packId) {
        'premium_skins' => premiumSkinsOwned,
        'skin_pack2' => skinPack2Owned,
        _ => false,
      };

  Future<bool> buySkin(int index, int price) async {
    if (Skins.at(index).premium) return false; // 프리미엄은 파편 구매 불가
    if (isSkinOwned(index) || shards < price) return false;
    await _p.setInt('shards', shards - price);
    final s = _owned..add(index);
    await _p.setStringList('owned', s.map((e) => '$e').toList());
    return true;
  }

  Future<void> equipSkin(int index) async {
    if (skinAvailable(index)) await _p.setInt('skinIndex', index);
  }

  // ---- 일일 도전 ----
  String get _today {
    final d = DateTime.now();
    return '${d.year}-${d.month}-${d.day}';
  }

  Future<void> _ensureDaily() async {
    if (_p.getString('dailyDate') != _today) {
      await _p.setString('dailyDate', _today);
      await _p.setInt('dailyProgress', 0);
      await _p.setBool('dailyClaimed', false);
    }
  }

  DailyChallenge get daily => DailyChallenge.forDate(DateTime.now());
  int get dailyProgress => _p.getInt('dailyProgress') ?? 0;
  bool get dailyClaimed => _p.getBool('dailyClaimed') ?? false;
  bool get dailyComplete => dailyProgress >= daily.target;

  /// 일일 도전 진행 누적 계산(쓰지 않음).
  int _projectedDaily(int bossKills, int orbs, int score) {
    final ch = daily;
    var prog = dailyProgress;
    switch (ch.metric) {
      case Metric.bosses:
        prog += bossKills;
      case Metric.orbs:
        prog += orbs;
      case Metric.score:
        prog = math.max(prog, score);
    }
    return prog;
  }

  /// 한 판 결과를 *저장하지 않고* 미리 계산(게임오버 화면 표시용).
  RunResult previewRun({
    required int score,
    required int bossKills,
    required int orbs,
    int maxCombo = 0,
    int graze = 0,
    bool reachedEnding = false,
    int shardMultiplier = 1,
  }) {
    final earned = ((score ~/ GameConfig.shardDivisor) *
            shardMultiplier *
            difficultyShardMul *
            (doubleShards ? 2 : 1))
        .round();
    final prog = _projectedDaily(bossKills, orbs, score);
    final dailyJustDone = !dailyClaimed && prog >= daily.target;

    final ctx = AchievementContext(
      score: score,
      bossKills: bossKills,
      maxCombo: maxCombo,
      graze: graze,
      reachedEnding: reachedEnding,
      totalBossKills: totalBossKills + bossKills,
    );
    final newNames = [
      for (final a in Achievements.all)
        if (!achievementUnlocked(a.id) && a.test(ctx)) a.name,
    ];

    return RunResult(
      score: score,
      newHighScore: score > highScore,
      shardsEarned: earned,
      dailyCompleted: dailyJustDone,
      dailyReward: dailyJustDone ? GameConfig.dailyReward : 0,
      newAchievements: newNames,
    );
  }

  // ---- 한 판 확정 기록 ----
  Future<RunResult> recordRun({
    required int score,
    required int bossKills,
    required int orbs,
    int maxCombo = 0,
    int graze = 0,
    bool reachedEnding = false,
    int shardMultiplier = 1,
  }) async {
    final newHigh = score > highScore;
    if (newHigh) await _p.setInt('highScore', score);

    final newTotalBoss = totalBossKills + bossKills;
    await _p.setInt('totalBossKills', newTotalBoss);

    final earned = ((score ~/ GameConfig.shardDivisor) *
            shardMultiplier *
            difficultyShardMul *
            (doubleShards ? 2 : 1))
        .round();
    await _p.setInt('shards', shards + earned);

    final prog = _projectedDaily(bossKills, orbs, score);
    await _p.setInt('dailyProgress', prog);

    var dailyJustDone = false;
    var reward = 0;
    if (!dailyClaimed && prog >= daily.target) {
      dailyJustDone = true;
      reward = GameConfig.dailyReward;
      await _p.setBool('dailyClaimed', true);
      await _p.setInt('shards', shards + reward);
    }

    final ctx = AchievementContext(
      score: score,
      bossKills: bossKills,
      maxCombo: maxCombo,
      graze: graze,
      reachedEnding: reachedEnding,
      totalBossKills: newTotalBoss,
    );
    final unlocked = List<String>.from(_achievements);
    final newNames = <String>[];
    for (final a in Achievements.all) {
      if (!unlocked.contains(a.id) && a.test(ctx)) {
        unlocked.add(a.id);
        newNames.add(a.name);
        await _p.setInt('shards', shards + a.reward);
      }
    }
    if (newNames.isNotEmpty) {
      await _p.setStringList('achievements', unlocked);
    }

    // 로컬 리더보드 등록.
    await submitLocalScore(score);

    return RunResult(
      score: score,
      newHighScore: newHigh,
      shardsEarned: earned,
      dailyCompleted: dailyJustDone,
      dailyReward: reward,
      newAchievements: newNames,
    );
  }
}
