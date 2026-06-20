import 'dart:math' as math;

import 'package:flame/components.dart';

import '../components/enemies/chaser.dart';
import '../components/enemies/drifter.dart';
import '../components/enemies/spinner.dart';
import '../components/enemies/splitter.dart';
import '../components/enemies/swarm.dart';
import '../components/enemies/turret.dart';
import '../config/game_config.dart';
import '../void_spark_game.dart';
import 'wave_manager.dart';

/// 적 스폰 담당. Intensity로 간격을, WaveManager로 종류 구성을 정한다.
class Spawner extends Component with HasGameReference<VoidSparkGame> {
  final math.Random _rng = math.Random();
  double _timer = 0;

  @override
  void update(double dt) {
    // 보스 등장 중에는 일반 적 스폰을 멈춰 호흡을 끊는다.
    if (game.bossActive) return;
    // 적이 상한에 도달하면 스폰을 보류(과부하 방지).
    if (game.activeEnemyCount >= GameConfig.maxEnemies) return;
    _timer += dt;
    final interval = game.intensity.spawnInterval *
        game.waves.current.spawnMultiplier *
        game.difficultySpawnMul;
    if (_timer >= interval) {
      _timer -= interval;
      _spawnFromWave();
    }
  }

  void _spawnFromWave() {
    final wave = game.waves.current;
    final kind = wave.kinds[_rng.nextInt(wave.kinds.length)];
    switch (kind) {
      case EnemyKind.drifter:
        game.add(Drifter(position: _topSpawn()));
      case EnemyKind.chaser:
        game.add(Chaser(position: _topSpawn()));
      case EnemyKind.turret:
        game.add(Turret(position: _topSpawn()));
      case EnemyKind.spinner:
        game.add(Spinner(position: _topSpawn()));
      case EnemyKind.splitter:
        game.add(Splitter(position: _topSpawn()));
      case EnemyKind.swarm:
        _spawnSwarmFormation();
    }
  }

  /// 화면 위쪽 임의 x 위치(약간 화면 밖에서 진입).
  Vector2 _topSpawn() {
    final w = game.size.x;
    final x = 24 + _rng.nextDouble() * (w - 48);
    return Vector2(x, -40);
  }

  /// Swarm은 편대로 함께 스폰 — 가로로 살짝 퍼진 무리.
  void _spawnSwarmFormation() {
    final w = game.size.x;
    final n = GameConfig.swarmFormationSize;
    final cx = 60 + _rng.nextDouble() * (w - 120);
    const gap = 26.0;
    for (var i = 0; i < n; i++) {
      final offset = (i - (n - 1) / 2) * gap;
      final pos = Vector2(
        (cx + offset).clamp(16.0, w - 16.0),
        -40 - (i.isEven ? 0 : 22),
      );
      game.add(Swarm(position: pos));
    }
  }
}
