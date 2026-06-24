/// VOID SPARK — 모든 튜닝 수치를 한 곳에 모은 설정.
/// 속도/체력/스폰간격/드롭확률/난이도곡선 등은 전부 여기서 조정한다.
class GameConfig {
  GameConfig._();

  // ---- 코어(플레이어) ----
  /// 코어 반지름(논리 px).
  static const double coreRadius = 14.0;

  /// 드래그 목표점으로 따라가는 보간 강성(클수록 즉각적).
  /// dt 기반 지수 보간에 사용한다.
  static const double coreFollowStiffness = 14.0;

  /// 코어가 화면 가장자리에서 유지하는 최소 여백.
  static const double coreEdgePadding = 8.0;

  /// 상대 드래그 모드(손가락이 코어를 가리지 않도록 시작점 기준 상대 이동).
  /// 설정에서 토글 예정. 기본은 절대 좌표 추적.
  static const bool relativeDragDefault = false;

  // ---- 사격 ----
  /// 자동 사격 간격(초).
  static const double fireInterval = 0.18;

  /// 총알 속도(px/s). 세로 화면이므로 위쪽으로 발사.
  static const double bulletSpeed = 620.0;

  /// 총알 반지름.
  static const double bulletRadius = 4.0;

  /// 가장 가까운 적 자동 조준 사용 여부(기본은 정면 발사).
  static const bool aimAtNearestDefault = false;

  // ---- 적: Drifter (직진 잡몹) ----
  static const double drifterRadius = 16.0;
  static const double drifterSpeed = 90.0;
  static const int drifterHp = 1;

  // ---- 적: Chaser (플레이어 추적) ----
  static const double chaserRadius = 14.0;
  static const double chaserSpeed = 130.0;
  static const int chaserHp = 2;

  // ---- 적: Turret (천천히 이동하며 조준 사격) ----
  static const double turretRadius = 18.0;
  static const double turretSpeed = 45.0;
  static const int turretHp = 4;
  static const double turretFireInterval = 1.6;
  static const double turretBulletSpeed = 220.0;

  // ---- 적: Spinner (원형/나선 탄막) ----
  static const double spinnerRadius = 20.0;
  static const double spinnerSpeed = 40.0;
  static const int spinnerHp = 5;
  static const double spinnerFireInterval = 0.14;
  static const double spinnerBulletSpeed = 150.0;

  /// 한 번에 흩뿌리는 탄 수(나선).
  static const int spinnerArms = 3;

  /// 나선 회전 속도(라디안/초).
  static const double spinnerSpinSpeed = 2.4;

  // ---- 적: Splitter (처치 시 분열) ----
  static const double splitterRadius = 22.0;
  static const double splitterSpeed = 70.0;
  static const int splitterHp = 3;

  /// 분열 시 생성되는 자식 수.
  static const int splitterChildren = 3;
  static const double splitterChildRadius = 11.0;
  static const double splitterChildSpeed = 150.0;
  static const int splitterChildHp = 1;

  // ---- 적: Swarm (작고 빠른 편대) ----
  static const double swarmRadius = 9.0;
  static const double swarmSpeed = 190.0;
  static const int swarmHp = 1;

  /// 한 편대로 함께 스폰되는 수.
  static const int swarmFormationSize = 6;

  // ---- 적 탄막 ----
  static const double enemyBulletRadius = 6.0;
  static const double enemyBulletSpeed = 252.0;

  // ---- 스폰 / 난이도 ----
  /// 초기(intensity 0) 스폰 간격(초).
  static const double baseSpawnInterval = 1.05;

  /// 최대 강도에서의 스폰 간격(초) — 가장 빡센 상태.
  static const double minSpawnInterval = 0.25;

  /// 오버드라이브(강도 1 초과)에서도 스폰 간격이 더 줄어드는 절대 하한(초).
  static const double absoluteMinSpawnInterval = 0.16;

  // ---- Intensity 시스템 (생존 시간이 길수록 무한히 상승) ----
  /// 강도가 0→1(최대치 근접)에 도달하기까지 걸리는 시간(초).
  static const double intensityRampSeconds = 90.0;

  /// 강도 1 도달 후, 생존 시간에 비례해 추가로 빨라지는 정도(클수록 가파름).
  static const double overdriveSpawnGain = 0.9;

  /// 오버드라이브 구간에서 적/탄 이동·발사가 빨라지는 배율 상한.
  static const double enemySpeedMaxMul = 2.7;

  /// 오버드라이브 1당 적 속도 증가율.
  static const double overdriveSpeedGain = 0.24;

  // ---- Wave 시스템 ----
  /// 한 웨이브의 지속 시간(초). 이 시간마다 다음 웨이브로 전환.
  static const double waveDuration = 18.0;

  /// 적이 화면 아래로 완전히 벗어나는 여유(이만큼 지나면 제거).
  static const double enemyDespawnMargin = 60.0;

  // ---- 점수 / 오브 ----
  /// 적 처치 시 떨어지는 오브 1개의 기본 점수.
  static const int scorePerKill = 10;

  // ---- 그레이즈(스침 보상) ----
  /// 적 탄이 코어 중심에서 이 거리 안(피격 반경 밖)을 지나면 그레이즈로 인정.
  static const double grazeRadius = 38.0;

  /// 그레이즈 1회당 점수.
  static const int grazeScore = 3;

  /// 오브 반지름.
  static const double orbRadius = 7.0;

  /// 오브가 사라지기까지의 수명(초). 이 시간이 지나면 소멸.
  static const double orbLifetime = 6.0;

  /// 자석 없이도 코어가 이 거리 안에 들면 약하게 빨려온다(획득 보조).
  static const double orbAssistRadius = 92.0;

  /// 보조 흡입 속도(px/s).
  static const double orbAssistSpeed = 160.0;

  /// 자석(Magnet) 발동 시 흡입 속도(px/s).
  static const double orbMagnetSpeed = 620.0;

  // ---- 콤보 ----
  /// 오브 획득당 배율 증가폭.
  static const double comboStep = 0.1;

  /// 콤보 배율 상한.
  static const double comboMax = 6.0;

  /// 마지막 획득 후 콤보가 유지되는 시간(초). 초과 시 리셋.
  static const double comboTimeout = 2.5;

  // ---- 파워업 ----
  /// 적 처치 시 파워업이 드롭될 확률.
  static const double powerupDropChance = 0.10;

  /// 파워업 픽업 반지름.
  static const double powerupRadius = 13.0;

  /// 파워업 낙하 속도(px/s).
  static const double powerupFallSpeed = 60.0;

  /// 파워업이 사라지기까지의 수명(초).
  static const double powerupLifetime = 8.0;

  // 지속형 파워업 시간(초).
  static const double spreadDuration = 8.0;
  static const double rapidDuration = 7.0;
  static const double slowDuration = 4.0;
  static const double magnetDuration = 7.0;
  static const double pierceDuration = 7.0;
  static const double aimDuration = 8.0;

  /// Rapid 발동 시 사격 간격 배율(작을수록 빠름).
  static const double rapidFireFactor = 0.5;

  /// Spread 3-way 발사 각도(라디안).
  static const double spreadAngle = 0.32;

  /// Slow 발동 시 적/탄 시간 배율.
  static const double slowTimeScale = 0.35;

  /// 폭탄 최대 비축 수.
  static const int bombMax = 3;

  /// 피격(실드 소모 등) 후 무적 시간(초).
  static const double invulnDuration = 0.9;

  // ---- 연출 / 손맛(Juice) ----
  /// 배경 펄스 주기(초).
  static const double bgPulsePeriod = 3.2;

  /// 적 처치 파티클 수.
  static const int killParticles = 10;

  // ---- 성능 상한(동시 존재 가능한 최대 수) ----
  /// 화면에 동시에 존재 가능한 적 탄막 수(초과 시 신규 발사 무시).
  static const int maxEnemyBullets = 200;

  /// 동시에 존재 가능한 일반 적 수(보스 제외, 초과 시 스폰 보류).
  static const int maxEnemies = 48;

  /// 동시에 존재 가능한 파티클 수(초과분은 생성하지 않음).
  static const int maxParticles = 160;

  /// 동시에 존재 가능한 점수 오브 수(초과 시 가장 오래된 것부터 정리).
  static const int maxOrbs = 45;

  /// 동시에 존재 가능한 플레이어 총알 수(확산·후방·연사 누적 폭증 방지).
  static const int maxPlayerBullets = 140;

  /// 한 번 발사 시 한쪽 추가 탄(쌍)의 상한(확산 무한 누적 방지).
  static const int maxSidePairs = 6;

  /// 한 프레임 dt 상한(초). 끊김 직후 거대한 dt가 들어와 적·탄이 순간이동하며
  /// 즉사하는 것을 막는다(~30fps 스텝으로 제한).
  static const double maxFrameDt = 1 / 30;

  /// 파티클 수명(초).
  static const double particleLife = 0.6;

  /// 파티클 초기 속도 범위.
  static const double particleSpeedMin = 90.0;
  static const double particleSpeedMax = 300.0;

  /// 화면 흔들림: 처치 / 피격 / 폭탄·보스 강도(px)와 지속시간(초).
  static const double shakeKill = 5.0;
  static const double shakeHit = 22.0;
  static const double shakeBig = 30.0;
  static const double shakeDuration = 0.35;

  /// 히트스톱(미세 정지) 시간(초).
  static const double hitStopKill = 0.04;
  static const double hitStopHit = 0.12;

  /// 피격 가장자리 붉은 플래시 지속(초).
  static const double edgeFlashDuration = 0.5;

  /// close-call(아슬아슬 회피): 코어 중심에서 이 거리 안으로 적 탄이 스치면 발동.
  /// 너무 자주 발동하지 않도록 반경은 좁게, 쿨다운은 길게.
  static const double closeCallRadius = 26.0;

  /// close-call 슬로우모 지속(초)과 시간 배율(1에 가까울수록 약함), 재발동 쿨다운(초).
  static const double closeCallDuration = 0.22;
  static const double closeCallTimeScale = 0.55;
  static const double closeCallCooldown = 2.5;

  // ---- 보스 ----
  /// 보스가 등장하는 웨이브 간격(이 배수의 웨이브마다 등장).
  static const int bossEveryWaves = 4;

  static const double bossRadius = 56.0;
  static const int bossHp = 140;
  static const double bossSpeed = 70.0;

  /// 보스 진입 후 좌우 순항 시 화면 위쪽에 유지하는 y 위치.
  static const double bossHoverY = 130.0;

  /// 페이즈별 발사 간격(초). 진행할수록 빨라진다.
  static const double bossFireP1 = 1.4;
  static const double bossFireP2 = 1.0;
  static const double bossFireP3 = 0.7;

  /// 보스 링 탄막 1회 탄 수.
  static const int bossRingBullets = 18;

  /// 보스 처치 보너스 점수.
  static const int bossScore = 500;

  /// 한 판에 이 수만큼 보스를 처치하면 엔딩(빛의 귀환) 도달 — 이후 무한 모드.
  static const int victoryBossCount = 3;

  // ---- 인런 레벨업(로그라이트 3택 1) ----
  /// 처치/획득으로 얻는 XP. 누적이 임계치에 도달하면 레벨업 → 업그레이드 선택.
  static const int xpPerKill = 1;
  static const int xpPerOrb = 2;

  /// 1레벨업에 필요한 기본 XP와 레벨마다의 증가 배율.
  /// (간격을 넉넉하게 — 초반도 너무 자주 레벨업하지 않도록)
  static const int xpBase = 55;
  static const double xpGrowth = 1.7;

  // ---- 메타 진행 ----
  /// 파편(Shard) 환산: 점수 ÷ 이 값 = 획득 파편. (낮을수록 더 많이 획득)
  static const int shardDivisor = 40;

  /// 시작 실드 보너스 해금 가격(파편).
  static const int startShieldPrice = 150;

  /// 시작 폭탄 보너스 해금 가격(파편).
  static const int startBombPrice = 200;

  /// 시작 콤보 보너스 — 해금 가격(파편)과 시작 콤보 수치.
  static const int startComboPrice = 250;
  static const int startComboCount = 10;

  /// 일일 도전 완료 보상(파편).
  static const int dailyReward = 150;

  // ---- 리더보드 (글로벌 순위, 난이도별) ----
  /// !!! Play Console / App Store Connect에 난이도별로 3개씩 등록 후 교체.
  /// 인덱스: 0=Easy, 1=Normal, 2=Hard.
  static const List<String> androidLeaderboardIds = [
    'CgkI_VOIDSPARK_EASY',
    'CgkI_VOIDSPARK_NORMAL',
    'CgkI_VOIDSPARK_HARD',
  ];
  static const List<String> iosLeaderboardIds = [
    'voidspark.high.easy',
    'voidspark.high.normal',
    'voidspark.high.hard',
  ];

  static String androidLeaderboardId(int difficulty) =>
      androidLeaderboardIds[difficulty.clamp(0, 2)];
  static String iosLeaderboardId(int difficulty) =>
      iosLeaderboardIds[difficulty.clamp(0, 2)];
}
