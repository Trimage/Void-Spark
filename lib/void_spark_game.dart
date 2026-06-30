import 'dart:math' as math;

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/painting.dart';

import 'components/batch_layer.dart';
import 'components/bullet.dart';
import 'components/core.dart';
import 'components/core_trail.dart';
import 'components/enemies/boss.dart';
import 'components/enemies/enemy.dart';
import 'components/enemy_bullet.dart';
import 'components/hud.dart';
import 'components/neon_background.dart';
import 'components/particle.dart';
import 'components/powerup.dart';
import 'components/score_orb.dart';
import 'config/game_config.dart';
import 'config/palette.dart';
import 'config/run_upgrades.dart';
import 'config/skins.dart';
import 'systems/analytics.dart';
import 'systems/audio.dart';
import 'systems/combo.dart';
import 'systems/haptics.dart';
import 'systems/intensity.dart';
import 'systems/juice.dart';
import 'systems/leaderboard/leaderboard.dart';
import 'systems/ads/ad_factory.dart';
import 'systems/ads/ad_service.dart';
import 'systems/powerups.dart';
import 'systems/run_mods.dart';
import 'systems/save.dart';
import 'systems/spawner.dart';
import 'systems/wave_manager.dart';

/// 게임 진행 상태.
enum GameState { playing, paused, gameOver }

/// VOID SPARK 메인 게임.
///
/// 4단계: 손맛(파티클/히트스톱/화면흔들림/엣지플래시/close-call 슬로우모) +
/// 합성 사운드 + 햅틱 + 보스(체력 + 3페이즈 패턴).
class VoidSparkGame extends FlameGame
    with DragCallbacks, HasCollisionDetection {
  static const String gameOverOverlay = 'gameOver';
  static const String controlsOverlay = 'controls';
  static const String pauseOverlay = 'paused';
  static const String tutorialOverlay = 'tutorial';
  static const String victoryOverlay = 'victory';
  static const String levelUpOverlay = 'levelUp';

  late final Core core;
  late final CoreTrail _coreTrail;
  late final Spawner _spawner;
  late final Hud _hud;
  late final IntensitySystem intensity;
  late final WaveManager waves;
  late final ComboSystem combo;
  late final PowerupSystem powerups;

  // 인런 로그라이트 강화(레벨업 3택 1로 누적).
  final RunMods runMods = RunMods();
  int _xp = 0;
  int level = 1;
  int _xpNext = GameConfig.xpBase;
  double _regenTimer = 0;

  /// 레벨업 화면에 제시할 3개 선택지.
  List<RunUpgradeDef> levelChoices = const [];

  /// 현재 레벨의 XP 진행도(0~1) — HUD 표시용.
  double get xpProgress => (_xp / _xpNext).clamp(0.0, 1.0);

  // 손맛/오디오/햅틱(컴포넌트가 아닌 게임 소유 객체).
  final JuiceSystem juice = JuiceSystem();
  final AudioSystem audio = AudioSystem();
  final HapticsSystem haptics = HapticsSystem();

  /// 보상형 광고(플랫폼별 구현 주입; 웹은 무동작).
  final AdService ads = createAdService();

  GameState state = GameState.playing;
  bool relativeDrag = GameConfig.relativeDragDefault;
  bool slowMoEnabled = true;
  int score = 0;

  /// 로컬 저장(기록/재화/해금).
  SaveSystem get save => SaveSystem.instance;

  /// 현재 장착된 코어 스킨.
  CoreSkin get skin => Skins.at(save.skinIndex);

  /// 이번 판 통계(일일 도전/파편 계산 + 결과 요약용).
  int bossKillsThisRun = 0;
  int orbsThisRun = 0;
  int enemiesKilledThisRun = 0;
  int grazeThisRun = 0;
  int maxComboThisRun = 0;
  double runTime = 0;

  // 보스 등장 경고 배너.
  double bossWarnTimer = 0;
  String bossWarnName = '';

  /// 엔딩(빛의 귀환) 도달 여부 — 한 판 1회.
  bool victoryReached = false;

  /// 현재 섹터(보스를 처치할수록 증가).
  int get sector => bossKillsThisRun + 1;

  // 한 판 확정/광고 보상 상태.
  bool _runFinalized = false;
  int _shardMultiplier = 1;
  bool _revivedThisRun = false;

  /// 광고 부활 가능 여부(판당 1회).
  bool get canRevive => state == GameState.gameOver && !_revivedThisRun;

  /// 파편 2배 광고를 이미 받았는가.
  bool get shardsDoubled => _shardMultiplier > 1;

  /// 게임오버 화면 표시용 결과 미리보기(확정 전).
  RunResult get runPreview => save.previewRun(
        score: score,
        bossKills: bossKillsThisRun,
        orbs: orbsThisRun,
        maxCombo: maxComboThisRun,
        graze: grazeThisRun,
        reachedEnding: victoryReached,
        shardMultiplier: _shardMultiplier,
      );

  final math.Random _rng = math.Random();

  // 오브젝트 풀(적탄·플레이어탄·파티클·점수오브) — 재사용으로 GC/충돌/churn 부담 제거.
  late final List<EnemyBullet> _ebPool;
  late final List<Bullet> _pbPool;
  late final List<NeonParticle> _pPool;
  late final List<ScoreOrb> _orbPool;

  // 배치 렌더러(BatchLayer)가 일괄로 그리도록 풀을 공개.
  List<EnemyBullet> get ebPool => _ebPool;
  List<Bullet> get pbPool => _pbPool;
  List<ScoreOrb> get orbPool => _orbPool;

  /// 프레임마다 갱신되는 활성 적 목록(플레이어 총알 명중 판정용).
  final List<Enemy> activeEnemies = [];

  /// 상단 안전영역 인셋(노치·다이나믹 아일랜드). GameScreen이 MediaQuery로 주입.
  /// HUD가 이 값만큼 상단 요소를 내려 가려지지 않게 한다.
  double topInset = 0;

  double _invuln = 0;
  bool get invulnerable => _invuln > 0;

  // 보스 상태.
  Boss? boss;
  bool bossActive = false;
  int _nextBossWave = GameConfig.bossEveryWaves;
  int _bossCount = 0;

  double _closeCallCd = 0;
  // 처치 화면흔들림 쿨다운 — 고밀도 구간에서 흔들림이 끊임없이 리셋되는 것 방지.
  double _killShakeCd = 0;

  // ---- 영구 업그레이드 / 난이도 적용값 ----
  double get effectiveFireInterval =>
      GameConfig.fireInterval * (1 - 0.12 * save.upgradeLevel('up_fire'));
  double get effectiveFollow =>
      GameConfig.coreFollowStiffness +
      2.0 * save.upgradeLevel('up_speed') +
      runMods.followBonus;
  int get maxBombs => GameConfig.bombMax + save.upgradeLevel('up_bomb');
  double get orbAssistRadius =>
      GameConfig.orbAssistRadius +
      22.0 * save.upgradeLevel('up_magnet') +
      runMods.assistBonus;

  /// 난이도별 스폰 간격/속도 배율. (값↓=스폰 더 잦음, 속도↑=더 빠름)
  double get difficultySpawnMul => const [1.15, 0.9, 0.72][save.difficulty];
  double get difficultySpeedMul => const [0.95, 1.12, 1.3][save.difficulty];

  /// 적/탄에 적용되는 시간 배율 — Slow면 느려지고, 오버드라이브·난이도로 빨라진다.
  double get enemyTimeScale => powerups.slowActive
      ? GameConfig.slowTimeScale
      : intensity.enemySpeedMul * difficultySpeedMul;

  @override
  Color backgroundColor() => Palette.voidDeep;

  @override
  Future<void> onLoad() async {
    await add(NeonBackground());

    intensity = IntensitySystem();
    waves = WaveManager();
    combo = ComboSystem();
    powerups = PowerupSystem();
    await addAll([intensity, waves, combo, powerups]);

    core = Core();
    await add(core);
    _coreTrail = CoreTrail();
    await add(_coreTrail);

    _spawner = Spawner();
    await add(_spawner);

    _hud = Hud();
    await add(_hud);

    // 풀 사전 생성(비활성 상태로 트리에 상주).
    _ebPool = List.generate(GameConfig.maxEnemyBullets, (_) => EnemyBullet());
    _pbPool = List.generate(GameConfig.maxPlayerBullets, (_) => Bullet());
    _pPool = List.generate(GameConfig.maxParticles, (_) => NeonParticle());
    _orbPool = List.generate(GameConfig.maxOrbs, (_) => ScoreOrb());
    await addAll(_ebPool);
    await addAll(_pbPool);
    await addAll(_pPool);
    await addAll(_orbPool);
    // 적탄·플레이어탄·오브를 일괄 렌더(개별 컴포넌트 변환 오버헤드 제거).
    // priority 5 → 적(6) 아래, 배경 위.
    await add(BatchLayer(priority: 5));

    _applyStartBonus();
    _applySettings();

    await audio.preload();
    await haptics.init();
    await ads.init();

    audio.startBgm();

    // 첫 플레이라면 잠시 멈춘다. 튜토리얼 오버레이는 화면 레이어에서
    // initialActiveOverlays로 띄운다(빌더가 등록된 곳에서만).
    if (!save.tutorialSeen) pauseEngine();

    Analytics.instance.runStart(save.difficulty);
  }

  /// 시작 보너스 적용 — 해금 시 실드/폭탄/콤보를 들고 시작.
  void _applyStartBonus() {
    if (save.startShieldUnlocked) powerups.shield = true;
    if (save.startBombUnlocked && powerups.bombs < 1) powerups.bombs = 1;
    if (save.startComboUnlocked) combo.seed(GameConfig.startComboCount);
  }

  /// 파워업 드롭 확률(행운 업그레이드 반영).
  double get powerupDropChance =>
      GameConfig.powerupDropChance + 0.03 * save.upgradeLevel('up_luck');

  /// 저장된 설정 적용(사운드/햅틱/드래그 모드/볼륨). aim은 코어가 실시간 참조.
  void _applySettings() {
    audio.enabled = save.soundOn;
    audio.sfxVolume = save.sfxVolume;
    audio.bgmVolume = save.bgmVolume;
    haptics.enabled = save.hapticsOn;
    relativeDrag = save.relativeDrag;
    slowMoEnabled = save.slowMoOn;
    // 접근성: 흔들림 강도 + 번쩍임 줄이기.
    juice.intensityScale =
        save.shakeIntensity * (save.reduceFlashing ? 0.4 : 1.0);
    juice.flashEnabled = !save.reduceFlashing;
    powerups.maxBombs = maxBombs;
  }

  /// 튜토리얼 닫기 — 이후 다시 보지 않도록 저장하고 게임 시작.
  void dismissTutorial() {
    save.setTutorialSeen();
    overlays.remove(tutorialOverlay);
    resumeEngine();
  }

  // ---- 일시정지 ----
  void pauseGame() {
    if (state != GameState.playing) return;
    state = GameState.paused;
    audio.pauseBgm();
    overlays.add(pauseOverlay);
    pauseEngine();
  }

  void resumeGame() {
    if (state != GameState.paused) return;
    state = GameState.playing;
    overlays.remove(pauseOverlay);
    audio.resumeBgm();
    resumeEngine();
  }

  @override
  void update(double dt) {
    // dt 상한 — 프레임 끊김 후 거대한 dt가 들어와 순간이동·즉사하는 것을 방지.
    if (dt > GameConfig.maxFrameDt) dt = GameConfig.maxFrameDt;

    // 연출 타이머는 실시간으로 진행(히트스톱 중에도).
    juice.updateRealtime(dt);
    if (juice.frozen) return; // 히트스톱: 월드 정지.

    // 플레이어 총알 명중 판정용 활성 적 목록 갱신(프레임당 1회).
    activeEnemies
      ..clear()
      ..addAll(children.whereType<Enemy>());

    final scaled = dt * juice.globalTimeScale;
    super.update(scaled);

    if (_invuln > 0) _invuln -= scaled;
    if (_closeCallCd > 0) _closeCallCd -= dt;
    if (_killShakeCd > 0) _killShakeCd -= dt;
    if (bossWarnTimer > 0) bossWarnTimer -= dt;
    if (state == GameState.playing) {
      runTime += dt;
      _updateShieldRegen(dt);
      _maybeLevelUp();
    }

    _maybeSpawnBoss();
    _checkCloseCall();
  }

  // ---- 보스 ----

  void _maybeSpawnBoss() {
    if (state != GameState.playing || boss != null) return;
    if (waves.waveNumber >= _nextBossWave) {
      _nextBossWave += GameConfig.bossEveryWaves;
      _spawnBoss();
    }
  }

  void _spawnBoss() {
    bossActive = true;
    final b = Boss(
      position: Vector2(size.x / 2, -GameConfig.bossRadius),
      variant: _bossCount % 2, // 등장마다 Monolith ↔ Vortex 교대.
    );
    _bossCount++;
    boss = b;
    add(b);
    bossWarnName = b.variant == 1 ? 'VORTEX' : 'MONOLITH';
    bossWarnTimer = 2.6;
    audio.boss();
    haptics.boss();
    juice.shake(GameConfig.shakeBig);
  }

  void onBossPhaseChange(int phase) {
    juice.shake(GameConfig.shakeKill * 2);
    audio.boss();
  }

  void onBossKilled(Boss b) {
    score += GameConfig.bossScore;
    bossKillsThisRun++;
    boss = null;
    bossActive = false;
    // 엔딩 도달 — 목표 보스 수 달성 시 1회 승리 연출.
    Analytics.instance.bossKill(sector);
    if (!victoryReached && bossKillsThisRun >= GameConfig.victoryBossCount) {
      victoryReached = true;
      Analytics.instance.victory(score);
      _showVictory();
    }
    spawnBurst(b.position, Palette.danger, count: 48, speedScale: 1.6);
    audio.kill();
    haptics.boss();
    juice.shake(GameConfig.shakeBig);
    juice.hitStop(GameConfig.hitStopHit);
  }

  // ---- 게임 이벤트 ----

  /// 적 탄을 아슬아슬하게 스쳤을 때(그레이즈) — 보너스 점수.
  void onGraze() {
    if (state != GameState.playing) return;
    grazeThisRun++;
    score += GameConfig.grazeScore;
  }

  // ---- 인런 레벨업 ----
  void _gainXp(int n) =>
      _xp += (n * (1 + 0.15 * save.upgradeLevel('up_xp'))).round();

  void _updateShieldRegen(double dt) {
    if (runMods.shieldRegen <= 0 || powerups.shield) {
      _regenTimer = 0;
      return;
    }
    _regenTimer += dt;
    if (_regenTimer >= runMods.shieldRegen) {
      _regenTimer = 0;
      powerups.shield = true;
    }
  }

  void _maybeLevelUp() {
    if (_xp < _xpNext) return;
    // 3택 1 선택지 생성 후 잠시 멈춘다.
    _xp -= _xpNext;
    level++;
    _xpNext = (_xpNext * GameConfig.xpGrowth).round();
    levelChoices = _rollChoices();
    pauseEngine();
    overlays.add(levelUpOverlay);
  }

  List<RunUpgradeDef> _rollChoices() {
    final pool = RunUpgrades.all.where((u) => !u.exhausted(runMods)).toList()
      ..shuffle(_rng);
    return pool.take(3).toList();
  }

  /// 레벨업 선택 적용 후 게임 재개.
  void chooseUpgrade(RunUpgradeDef u) {
    u.apply(runMods);
    Analytics.instance.levelUp(level, u.id);
    combo.timeoutBonus = runMods.comboTimeoutBonus;
    overlays.remove(levelUpOverlay);
    resumeEngine();
  }

  /// 적 처치 — 오브/파워업 드롭 + 파티클·사운드·미세 히트스톱.
  void onEnemyKilled(Enemy enemy) {
    if (state != GameState.playing) return;
    enemiesKilledThisRun++;
    _gainXp(GameConfig.xpPerKill);
    _spawnOrb(enemy.position.clone());
    if (_rng.nextDouble() < powerupDropChance) {
      add(Powerup(position: enemy.position.clone(), type: _randomPowerup()));
    }
    spawnBurst(enemy.position, Palette.corruptGlow);
    audio.kill();
    // 처치 흔들림은 쿨다운으로 제한(고밀도 구간에서 흔들림이 멈추지 않는 문제 방지).
    // 처치당 히트스톱은 제거 — 빠른 연속 처치 시 월드가 계속 정지하던 원인.
    if (_killShakeCd <= 0) {
      juice.shake(GameConfig.shakeKill);
      _killShakeCd = GameConfig.killShakeCooldown;
    }
  }

  void _spawnOrb(Vector2 position) {
    // 풀에서 비활성 오브를 재사용. 가득 차면 가장 오래된 것을 교체.
    ScoreOrb? oldest;
    for (final o in _orbPool) {
      if (!o.active) {
        o.spawn(position, GameConfig.scorePerKill);
        return;
      }
      if (oldest == null || o.life > oldest.life) oldest = o;
    }
    oldest?.spawn(position, GameConfig.scorePerKill);
  }

  PowerupType _randomPowerup() =>
      PowerupType.values[_rng.nextInt(PowerupType.values.length)];

  void collectOrb(int value) {
    if (state != GameState.playing) return;
    combo.register();
    score += ((value + runMods.orbBonus) * combo.multiplier).round();
    orbsThisRun++;
    if (combo.count > maxComboThisRun) maxComboThisRun = combo.count;
    _gainXp(GameConfig.xpPerOrb);
    audio.collect();
  }

  void collectPowerup(PowerupType type) {
    if (state != GameState.playing) return;
    powerups.apply(type);
    audio.powerup();
  }

  /// 폭탄 — 화면 내 적/탄막 제거 + 강한 연출.
  void useBomb() {
    if (state != GameState.playing || powerups.bombs <= 0) return;
    powerups.bombs--;
    for (final e in children.whereType<Enemy>().toList()) {
      // 보스는 폭탄에 큰 데미지를 받되 즉사하지 않음.
      if (e is Boss) {
        e.takeDamage(20);
        continue;
      }
      score += (GameConfig.scorePerKill * combo.multiplier).round();
      spawnBurst(e.position, Palette.corruptGlow, count: 8);
      e.removeFromParent();
    }
    for (final b in _ebPool) {
      b.active = false;
    }
    audio.bomb();
    haptics.bomb();
    juice.shake(GameConfig.shakeBig);
    juice.edgeFlash();
  }

  void spawnEnemyBullet(Vector2 position, Vector2 velocity) {
    if (state != GameState.playing) return;
    // 풀에서 비활성 탄을 찾아 재사용(없으면 상한 도달 → 무시).
    for (final b in _ebPool) {
      if (!b.active) {
        b.spawn(position, velocity);
        return;
      }
    }
  }

  /// 플레이어 총알 발사(풀에서 재사용; 없으면 상한 도달로 무시).
  void spawnPlayerBullet(Vector2 position, Vector2 velocity, int damage) {
    for (final b in _pbPool) {
      if (!b.active) {
        b.spawn(position, velocity, damage);
        return;
      }
    }
  }

  /// 보스를 제외한 현재 일반 적 수.
  int get activeEnemyCount =>
      children.whereType<Enemy>().where((e) => e is! Boss).length;

  /// 파티클 폭발 — 풀에서 [count]개를 방사형으로 활성화(블러 없는 저비용).
  void spawnBurst(Vector2 position, Color color,
      {int count = GameConfig.killParticles, double speedScale = 1.0}) {
    var spawned = 0;
    for (final p in _pPool) {
      if (spawned >= count) break;
      if (p.active) continue;
      final a = _rng.nextDouble() * 2 * math.pi;
      final speed = (GameConfig.particleSpeedMin +
              _rng.nextDouble() *
                  (GameConfig.particleSpeedMax - GameConfig.particleSpeedMin)) *
          speedScale;
      p.spawn(
        position,
        Vector2(math.cos(a), math.sin(a)) * speed,
        color,
        GameConfig.particleLife * (0.6 + _rng.nextDouble() * 0.6),
      );
      spawned++;
    }
  }

  /// 피격 — 무적 무시 / 실드 소모 / 게임오버.
  void onPlayerHit() {
    if (state != GameState.playing || _invuln > 0) return;
    if (powerups.shield) {
      powerups.shield = false;
      _invuln = GameConfig.invulnDuration;
      _damageFeedback();
      return;
    }
    _damageFeedback();
    audio.gameOver();
    _gameOver();
  }

  void _damageFeedback() {
    audio.hit();
    haptics.hit();
    juice.shake(GameConfig.shakeHit);
    juice.edgeFlash();
    juice.hitStop(GameConfig.hitStopHit);
    spawnBurst(core.position, Palette.danger, count: 18);
  }

  /// close-call — 적 탄이 코어를 아슬아슬하게 스치면 짧은 슬로우모.
  void _checkCloseCall() {
    if (!slowMoEnabled) return;
    if (state != GameState.playing || _closeCallCd > 0) return;
    final minSafe = GameConfig.coreRadius + GameConfig.enemyBulletRadius;
    for (final b in _ebPool) {
      if (!b.active) continue;
      final d = b.position.distanceTo(core.position);
      if (d > minSafe && d < GameConfig.closeCallRadius) {
        juice.slowMo(GameConfig.closeCallDuration);
        _closeCallCd = GameConfig.closeCallCooldown;
        return;
      }
    }
  }

  void _gameOver() {
    state = GameState.gameOver;
    Analytics.instance.runEnd(score, sector, waves.waveNumber);
    audio.pauseBgm();
    pauseEngine();
    // 확정 기록은 부활/파편2배 광고 기회를 준 뒤(RETRY/MENU 시) 수행한다.
    overlays.add(gameOverOverlay);
  }

  /// 광고 보상: 파편 2배(이번 판 1회).
  void applyDoubleShards() {
    if (_shardMultiplier == 1) _shardMultiplier = 2;
  }

  /// 광고 보상: 부활(판당 1회). 위협을 정리하고 실드+무적으로 이어한다.
  void revive() {
    if (!canRevive) return;
    _revivedThisRun = true;
    // 화면의 적 탄막 제거 + 보스를 제외한 적 정리로 숨통을 틔운다.
    for (final b in _ebPool) {
      b.active = false;
    }
    for (final e in children.whereType<Enemy>().toList()) {
      if (e is Boss) continue;
      e.removeFromParent();
    }
    powerups.shield = true;
    _invuln = 2.0;
    core.position = size / 2;
    core.target = size / 2;
    _coreTrail.reset();
    state = GameState.playing;
    overlays.remove(gameOverOverlay);
    audio.resumeBgm();
    resumeEngine();
  }

  /// 엔딩(빛의 귀환) 도달 연출 — 잠시 멈추고 승리 오버레이를 띄운다.
  void _showVictory() {
    audio.pauseBgm();
    pauseEngine();
    overlays.add(victoryOverlay);
    juice.shake(GameConfig.shakeBig);
  }

  /// 승리 후 계속(무한 모드로 이어가기).
  void continueEndless() {
    overlays.remove(victoryOverlay);
    audio.resumeBgm();
    resumeEngine();
  }

  /// 판 확정 기록(파편/최고기록/일일도전/업적). RETRY/MENU 진입 시 1회 호출.
  Future<void> finalizeRun() async {
    if (_runFinalized) return;
    _runFinalized = true;
    await save.recordRun(
      score: score,
      bossKills: bossKillsThisRun,
      orbs: orbsThisRun,
      maxCombo: maxComboThisRun,
      graze: grazeThisRun,
      reachedEnding: victoryReached,
      shardMultiplier: _shardMultiplier,
    );
    // 글로벌 리더보드(난이도별)에도 제출(웹/미지원은 무동작).
    leaderboard.submit(score, save.difficulty);
  }

  /// 전세계 리더보드 사용 가능 여부(로그인+설정 완료 시 true). UI 노출 판단용.
  bool get leaderboardAvailable => leaderboard.available;

  /// 게임오버 화면용: 이번 점수를 제출한 뒤 **전세계 순위 + 직전 대비 변동**을
  /// 불러온다. 미로그인/미지원/미설정 시 null(=표시 안 함).
  Future<GlobalRankInfo?> loadGlobalRank() async {
    if (!leaderboard.available) return null;
    final d = save.difficulty;
    // 이번 판 점수를 먼저 제출(최고점이면 갱신) → 순위가 이번 기록을 반영.
    await leaderboard.submit(score, d);
    final rank = await leaderboard.playerGlobalRank(d);
    if (rank == null) return null;
    final prev = save.prevGlobalRank(d); // 0 = 첫 표시(변동 없음)
    await save.setPrevGlobalRank(d, rank);
    return GlobalRankInfo(
      rank: rank,
      prevRank: prev > 0 ? prev : null,
      isNewBest: runPreview.newHighScore,
    );
  }

  /// 다시하기: 전체 초기화 후 재개.
  void restart() {
    children.whereType<Enemy>().forEach((e) => e.removeFromParent());
    children.whereType<Powerup>().forEach((p) => p.removeFromParent());
    // 풀(적탄·플레이어탄·파티클·점수오브)은 제거 대신 비활성화.
    for (final b in _ebPool) {
      b.active = false;
    }
    for (final b in _pbPool) {
      b.active = false;
    }
    for (final p in _pPool) {
      p.active = false;
    }
    for (final o in _orbPool) {
      o.active = false;
    }
    score = 0;
    _invuln = 0;
    _closeCallCd = 0;
    _killShakeCd = 0;
    boss = null;
    bossActive = false;
    _nextBossWave = GameConfig.bossEveryWaves;
    _bossCount = 0;
    bossKillsThisRun = 0;
    orbsThisRun = 0;
    enemiesKilledThisRun = 0;
    grazeThisRun = 0;
    maxComboThisRun = 0;
    runTime = 0;
    bossWarnTimer = 0;
    victoryReached = false;
    _runFinalized = false;
    _shardMultiplier = 1;
    _revivedThisRun = false;
    runMods.reset();
    combo.timeoutBonus = 0;
    _xp = 0;
    level = 1;
    _xpNext = GameConfig.xpBase;
    _regenTimer = 0;
    intensity.reset();
    waves.reset();
    combo.reset();
    powerups.reset();
    juice.reset();
    _applyStartBonus();
    _applySettings();
    core.position = size / 2;
    core.target = size / 2;
    _coreTrail.reset();
    state = GameState.playing;
    overlays.remove(gameOverOverlay);
    audio.resumeBgm();
    Analytics.instance.runStart(save.difficulty);
    resumeEngine();
  }

  @override
  void onRemove() {
    audio.stopBgm();
    ads.dispose();
    super.onRemove();
  }

  // ---- 렌더(화면 흔들림 + 엣지 플래시) ----

  @override
  void render(Canvas canvas) {
    final shake = juice.shakeOffset;
    canvas.save();
    canvas.translate(shake.dx, shake.dy);
    super.render(canvas);
    canvas.restore();

    final flash = juice.edgeFlashAlpha;
    if (flash > 0) _renderEdgeFlash(canvas, flash);
  }

  void _renderEdgeFlash(Canvas canvas, double alpha) {
    final rect = Offset.zero & Size(size.x, size.y);
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          Palette.danger.withValues(alpha: 0),
          Palette.danger.withValues(alpha: 0.55 * alpha),
        ],
        stops: const [0.55, 1.0],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.x / 2, size.y / 2),
          radius: size.x * 0.75,
        ),
      );
    canvas.drawRect(rect, paint);
  }

  // ---- 드래그 입력 ----

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (!relativeDrag) {
      core.target = event.localPosition.clone();
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (relativeDrag) {
      final t = core.target ?? core.position.clone();
      core.target = t + event.localDelta;
    } else {
      core.target = event.localEndPosition.clone();
    }
  }
}

/// 게임오버 화면에 표시할 전세계 순위 정보.
class GlobalRankInfo {
  const GlobalRankInfo({
    required this.rank,
    required this.prevRank,
    required this.isNewBest,
  });

  /// 현재 전세계 순위(최고점 기준, 1부터).
  final int rank;

  /// 직전에 본 순위(없으면 null = 첫 표시).
  final int? prevRank;

  /// 이번 판이 개인 신기록인지(현재 점수 = 최고점).
  final bool isNewBest;

  /// 순위 변동(양수=상승, 음수=하락, 0=동일). prevRank 없으면 null.
  int? get delta => prevRank == null ? null : prevRank! - rank;
}
