import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:void_spark/components/enemies/boss.dart';
import 'package:void_spark/components/powerup.dart';
import 'package:void_spark/config/achievements.dart';
import 'package:void_spark/config/game_config.dart';
import 'package:void_spark/systems/loc.dart';
import 'package:void_spark/config/skins.dart';
import 'package:void_spark/config/run_upgrades.dart';
import 'package:void_spark/config/upgrades.dart';
import 'package:void_spark/systems/run_mods.dart';
import 'package:void_spark/systems/combo.dart';
import 'package:void_spark/systems/intensity.dart';
import 'package:void_spark/systems/juice.dart';
import 'package:void_spark/systems/powerups.dart';
import 'package:void_spark/systems/save.dart';
import 'package:void_spark/systems/wave_manager.dart';
import 'package:void_spark/void_spark_game.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> freshSave() async {
    SharedPreferences.setMockInitialValues({});
    await SaveSystem.instance.load();
  }

  test('VoidSparkGame loads core and starts in playing state', () async {
    await freshSave();
    final game = VoidSparkGame();
    await game.onLoad();
    expect(game.core, isNotNull);
    expect(game.state, GameState.playing);
  });

  test('save records run: shards earned and high score updated', () async {
    await freshSave();
    final s = SaveSystem.instance;
    expect(s.highScore, 0);
    final r = await s.recordRun(score: 1000, bossKills: 0, orbs: 0);
    expect(r.newHighScore, isTrue);
    expect(r.shardsEarned, 1000 ~/ GameConfig.shardDivisor);
    expect(s.highScore, 1000);
    expect(s.shards, greaterThanOrEqualTo(r.shardsEarned));
  });

  test('shop: buy and equip skin spends shards', () async {
    await freshSave();
    final s = SaveSystem.instance;
    await s.recordRun(score: 100000, bossKills: 0, orbs: 0); // 파편 확보
    final before = s.shards;
    const idx = 1;
    final ok = await s.buySkin(idx, Skins.all[idx].price);
    expect(ok, isTrue);
    expect(s.isSkinOwned(idx), isTrue);
    expect(s.shards, before - Skins.all[idx].price);
    await s.equipSkin(idx);
    expect(s.skinIndex, idx);
  });

  test('previewRun does not persist and multiplier doubles shards', () async {
    await freshSave();
    final s = SaveSystem.instance;
    final base = s.previewRun(score: 1000, bossKills: 0, orbs: 0);
    final doubled =
        s.previewRun(score: 1000, bossKills: 0, orbs: 0, shardMultiplier: 2);
    expect(doubled.shardsEarned, base.shardsEarned * 2);
    expect(s.shards, 0); // 미리보기는 저장하지 않음.
    expect(s.highScore, 0);
  });

  test('settings persist', () async {
    await freshSave();
    final s = SaveSystem.instance;
    expect(s.soundOn, isTrue);
    expect(s.relativeDrag, isTrue); // 상대 드래그 기본 ON
    await s.setSound(false);
    await s.setControlsOnRight(false);
    expect(s.soundOn, isFalse);
    expect(s.controlsOnRight, isFalse);
  });

  test('combo multiplier rises with collected orbs and resets on timeout', () {
    final c = ComboSystem();
    expect(c.multiplier, 1.0);
    c.register();
    c.register();
    expect(c.multiplier, closeTo(1 + 2 * GameConfig.comboStep, 0.0001));
    // 타임아웃 경과 → 리셋.
    c.update(GameConfig.comboTimeout + 0.1);
    expect(c.multiplier, 1.0);
  });

  test('powerups apply, expire, and stock bombs', () {
    final p = PowerupSystem();
    p.apply(PowerupType.spread);
    expect(p.spreadActive, isTrue);
    p.update(GameConfig.spreadDuration + 0.1);
    expect(p.spreadActive, isFalse);

    p.apply(PowerupType.shield);
    expect(p.shield, isTrue);

    for (var i = 0; i < GameConfig.bombMax + 2; i++) {
      p.apply(PowerupType.bomb);
    }
    expect(p.bombs, GameConfig.bombMax); // 상한 초과 비축 불가
  });

  test('intensity ramps from 0 to clamped 1', () {
    final i = IntensitySystem();
    expect(i.value, 0);
    i.elapsed = GameConfig.intensityRampSeconds / 2;
    expect(i.value, closeTo(0.5, 0.001));
    i.elapsed = GameConfig.intensityRampSeconds * 5;
    expect(i.value, 1.0);
    // 강도가 오르면 스폰 간격은 짧아진다.
    expect(i.spawnInterval, lessThan(GameConfig.baseSpawnInterval));
  });

  test('wave advances over time and gains enemy variety', () {
    final w = WaveManager();
    expect(w.waveNumber, 1);
    expect(w.current.kinds, [EnemyKind.drifter]);
    // 5 웨이브 분량 시간 경과.
    for (var t = 0.0; t < GameConfig.waveDuration * 5; t += 1.0) {
      w.update(1.0);
    }
    expect(w.waveNumber, 6);
    expect(w.current.kinds.length, greaterThan(1));
  });

  test('boss is invincible until entered, then takes damage', () {
    final b = Boss(position: Vector2.zero());
    expect(b.hpRatio, 1.0);
    // 등장(자리 잡기) 전에는 무적 — 데미지 무시.
    b.takeDamage(GameConfig.bossHp ~/ 2);
    expect(b.hpRatio, 1.0);
    // 자리 잡은 뒤에는 체력이 닳는다.
    b.debugMarkEntered();
    b.takeDamage(GameConfig.bossHp ~/ 2);
    expect(b.hpRatio, closeTo(0.5, 0.05));
  });

  test('local leaderboard is per-difficulty and sorted', () async {
    await freshSave();
    final s = SaveSystem.instance;
    await s.setPlayerName('ACE');
    await s.setDifficulty(1); // Normal
    await s.submitLocalScore(100);
    await s.submitLocalScore(500);
    await s.setDifficulty(2); // Hard
    await s.submitLocalScore(300);
    expect(s.localTop(1).first.score, 500); // Normal 정렬
    expect(s.localTop(1).length, 2);
    expect(s.localTop(2).single.score, 300); // Hard 분리 저장
    expect(s.localTop(0).isEmpty, isTrue); // Easy 비어있음
  });

  test('localization switches by language setting', () async {
    await freshSave();
    final s = SaveSystem.instance;
    await s.setLang('en');
    expect(t('안녕', 'hello'), 'hello');
    expect(Achievements.all.first.name, 'First Crack');
    await s.setLang('ko');
    expect(t('안녕', 'hello'), '안녕');
    expect(Achievements.all.first.name, '첫 균열');
  });

  test('run upgrade applies and pierce is non-repeatable', () {
    final m = RunMods();
    expect(m.fireIntervalMul, 1.0);
    RunUpgrades.all.firstWhere((u) => u.id == 'fire').apply(m);
    expect(m.fireIntervalMul, lessThan(1.0));
    final pierce = RunUpgrades.all.firstWhere((u) => u.id == 'pierce');
    expect(pierce.exhausted(m), isFalse);
    pierce.apply(m);
    expect(m.pierce, isTrue);
    expect(pierce.exhausted(m), isTrue); // 이미 보유 → 선택지 제외
  });

  test('juice hitstop freezes then clears', () {
    final j = JuiceSystem();
    expect(j.frozen, isFalse);
    j.hitStop(0.1);
    expect(j.frozen, isTrue);
    j.updateRealtime(0.2);
    expect(j.frozen, isFalse);
  });

  test('pierce powerup activates and expires', () {
    final p = PowerupSystem();
    expect(p.pierceActive, isFalse);
    p.apply(PowerupType.pierce);
    expect(p.pierceActive, isTrue);
    p.update(GameConfig.pierceDuration + 0.1);
    expect(p.pierceActive, isFalse);
  });

  test('upgrades: buy raises level and spends shards', () async {
    await freshSave();
    final s = SaveSystem.instance;
    await s.recordRun(score: 100000, bossKills: 0, orbs: 0); // 파편 확보
    final before = s.shards;
    expect(s.upgradeLevel(Upgrades.fireRate.id), 0);
    final ok = await s.buyUpgrade(Upgrades.fireRate);
    expect(ok, isTrue);
    expect(s.upgradeLevel(Upgrades.fireRate.id), 1);
    expect(s.shards, before - Upgrades.fireRate.costs[0]);
  });

  test('achievements unlock on qualifying run', () async {
    await freshSave();
    final s = SaveSystem.instance;
    expect(s.achievementUnlocked('first_boss'), isFalse);
    final r = await s.recordRun(score: 6000, bossKills: 1, orbs: 0);
    // 보스 1회 + 5000점 → 최소 2개 업적 해금.
    expect(s.achievementUnlocked('first_boss'), isTrue);
    expect(s.achievementUnlocked('score5000'), isTrue);
    expect(r.newAchievements, isNotEmpty);
    // 누적 보스 → 코덱스 1개 해금.
    expect(s.loreUnlockedCount, greaterThanOrEqualTo(1));
  });

  test('difficulty changes shard reward multiplier', () async {
    await freshSave();
    final s = SaveSystem.instance;
    await s.setDifficulty(2); // Hard
    expect(s.difficulty, 2);
    final hard = s.previewRun(score: 1000, bossKills: 0, orbs: 0);
    await s.setDifficulty(0); // Easy
    final easy = s.previewRun(score: 1000, bossKills: 0, orbs: 0);
    expect(hard.shardsEarned, greaterThan(easy.shardsEarned));
  });

  test('intensity keeps escalating after ramp (overdrive)', () {
    final i = IntensitySystem();
    // 램프 한참 초과 — 오버드라이브.
    i.elapsed = GameConfig.intensityRampSeconds * 3;
    expect(i.value, 1.0); // HUD 게이지는 1로 고정.
    expect(i.overdrive, isTrue);
    expect(i.enemySpeedMul, greaterThan(1.0));
    // 스폰 간격은 최저 간격보다도 더 짧아진다.
    expect(i.spawnInterval, lessThan(GameConfig.minSpawnInterval));
    expect(i.spawnInterval,
        greaterThanOrEqualTo(GameConfig.absoluteMinSpawnInterval));
  });
}
