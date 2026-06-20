import 'package:flame/components.dart';

import '../config/game_config.dart';

/// 스폰 가능한 적 종류.
enum EnemyKind { drifter, chaser, swarm, turret, spinner, splitter }

/// 한 웨이브의 정의: 등장하는 적 종류 풀 + 스폰 간격 배율.
class WaveDef {
  const WaveDef(this.kinds, {this.spawnMultiplier = 1.0});

  /// 이 웨이브에서 뽑힐 수 있는 적 종류(가중 추첨용 풀, 중복으로 비중 조절).
  final List<EnemyKind> kinds;

  /// 스폰 간격 배율(작을수록 더 자주). intensity 위에 곱해진다.
  final double spawnMultiplier;
}

/// WaveManager — 일정 시간마다 웨이브를 전환하며 패턴 조합을 바꾼다.
/// 웨이브가 진행될수록 더 다양한 적이 섞여 나온다. 마지막 웨이브에 도달하면
/// 가장 다양한 조합을 유지하며 intensity가 난이도를 계속 끌어올린다.
class WaveManager extends Component {
  /// 웨이브 구성. 진행할수록 적 종류가 누적되며 빈도가 높아진다.
  static const List<WaveDef> _waves = [
    // 1: 직진 잡몹만.
    WaveDef([EnemyKind.drifter], spawnMultiplier: 1.0),
    // 2: 추적자 합류.
    WaveDef([EnemyKind.drifter, EnemyKind.drifter, EnemyKind.chaser],
        spawnMultiplier: 0.95),
    // 3: 편대 등장.
    WaveDef([EnemyKind.drifter, EnemyKind.chaser, EnemyKind.swarm],
        spawnMultiplier: 0.9),
    // 4: 포탑 합류(탄막 시작).
    WaveDef(
        [EnemyKind.drifter, EnemyKind.chaser, EnemyKind.swarm, EnemyKind.turret],
        spawnMultiplier: 0.85),
    // 5: 나선 탄막.
    WaveDef([
      EnemyKind.chaser,
      EnemyKind.swarm,
      EnemyKind.turret,
      EnemyKind.spinner,
    ], spawnMultiplier: 0.8),
    // 6+: 분열까지 전부.
    WaveDef([
      EnemyKind.drifter,
      EnemyKind.chaser,
      EnemyKind.swarm,
      EnemyKind.turret,
      EnemyKind.spinner,
      EnemyKind.splitter,
    ], spawnMultiplier: 0.72),
  ];

  double _elapsed = 0;

  /// 현재 웨이브 번호(1부터).
  int get waveNumber {
    final idx = (_elapsed / GameConfig.waveDuration).floor();
    return idx + 1;
  }

  /// 현재 웨이브 정의(마지막 웨이브 이후로는 마지막 구성을 유지).
  WaveDef get current {
    final idx = (_elapsed / GameConfig.waveDuration).floor();
    return _waves[idx.clamp(0, _waves.length - 1)];
  }

  void reset() => _elapsed = 0;

  @override
  void update(double dt) {
    _elapsed += dt;
  }
}
