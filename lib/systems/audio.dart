import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';

/// 합성 SFX/BGM 재생 래퍼.
///
/// 성능: 자주 나는 효과음(사격/처치/획득)을 매번 새 플레이어로 재생하면
/// 모바일 오디오 스택이 포화돼 수 초간 멈추는 현상이 생긴다. 그래서
/// - 사격음은 [AudioPool]로 소수 플레이어를 재사용하고,
/// - 처치/획득/사격은 최소 간격으로 쓰로틀해 한 프레임에 폭주하지 않게 한다.
/// 모든 호출은 try/catch로 감싸 오디오 실패가 게임을 멈추지 않게 한다.
class AudioSystem {
  bool enabled = true;
  double sfxVolume = 0.7;
  double bgmVolume = 0.5;

  bool _ready = false;
  bool _bgmPlaying = false;
  // 자주 나는 효과음은 풀로 플레이어를 재사용한다(매번 새 네이티브 플레이어
  // 생성 시 모바일 오디오 스택이 포화돼 프레임이 멈추는 것을 방지).
  AudioPool? _shootPool;
  AudioPool? _killPool;
  AudioPool? _collectPool;

  // 재생 중인 풀 효과음의 정지 함수들 — 게임오버/일시정지/백그라운드 시 즉시 끊기 위함.
  final List<Future<void> Function()> _activeStops = [];

  // 사운드별 마지막 재생 시각(ms) — 쓰로틀용.
  final Map<String, int> _lastMs = {};

  static const String _bgmFile = 'bgm.wav';
  static const List<String> _files = [
    'shoot.wav',
    'kill.wav',
    'collect.wav',
    'hit.wav',
    'powerup.wav',
    'gameover.wav',
    'boss.wav',
    'bomb.wav',
    _bgmFile,
  ];

  Future<void> preload() async {
    try {
      await FlameAudio.audioCache.loadAll(_files);
      // 격렬한 구간에 효과음이 끊기지 않도록 풀 플레이어 수를 넉넉히.
      _shootPool = await FlameAudio.createPool('shoot.wav', maxPlayers: 8);
      _killPool = await FlameAudio.createPool('kill.wav', maxPlayers: 8);
      _collectPool = await FlameAudio.createPool('collect.wav', maxPlayers: 8);
      _ready = true;
    } catch (e) {
      debugPrint('AudioSystem preload skipped: $e');
    }
  }

  int get _now => DateTime.now().millisecondsSinceEpoch;

  /// [minGapMs] 내 재재생을 막는 쓰로틀. true면 재생해도 됨.
  bool _allow(String key, int minGapMs) {
    final t = _now;
    final last = _lastMs[key] ?? 0;
    if (t - last < minGapMs) return false;
    _lastMs[key] = t;
    return true;
  }

  void _play(String file, double volume, int minGapMs) {
    if (!enabled || !_ready) return;
    if (!_allow(file, minGapMs)) return;
    try {
      FlameAudio.play(file, volume: volume * sfxVolume);
    } catch (_) {}
  }

  // ---- SFX ----
  void shoot() => _playPooled(_shootPool, 'shoot', 0.18, 70); // 초당 ~14회로 제한

  /// 풀에서 플레이어를 재사용해 재생(네이티브 플레이어 생성 churn 제거).
  /// 재생 정지 함수를 보관해 게임오버/일시정지/백그라운드 시 즉시 끊을 수 있게 한다.
  void _playPooled(AudioPool? pool, String key, double volume, int minGapMs) {
    if (!enabled || !_ready || pool == null) return;
    if (!_allow(key, minGapMs)) return;
    pool.start(volume: volume * sfxVolume).then((stop) {
      _activeStops.add(stop);
      if (_activeStops.length > 16) _activeStops.removeAt(0);
    }).catchError((_) {});
  }

  /// 재생 중인 모든 풀 효과음을 즉시 멈춘다(사격음 누수·백그라운드 소리 방지).
  void stopSfx() {
    final stops = List.of(_activeStops);
    _activeStops.clear();
    for (final stop in stops) {
      stop().catchError((_) {});
    }
  }

  void kill() => _playPooled(_killPool, 'kill', 0.5, 45);
  void collect() => _playPooled(_collectPool, 'collect', 0.4, 45);
  void hit() => _play('hit.wav', 0.8, 0);
  void powerup() => _play('powerup.wav', 0.7, 60);
  void gameOver() => _play('gameover.wav', 0.9, 0);
  void boss() => _play('boss.wav', 0.9, 0);
  void bomb() => _play('bomb.wav', 0.8, 0);

  // ---- BGM ----
  void startBgm() {
    if (!enabled || !_ready || _bgmPlaying || bgmVolume <= 0) return;
    try {
      FlameAudio.bgm.play(_bgmFile, volume: bgmVolume);
      _bgmPlaying = true;
    } catch (e) {
      debugPrint('BGM start skipped: $e');
    }
  }

  void stopBgm() {
    if (!_bgmPlaying) return;
    try {
      FlameAudio.bgm.stop();
    } catch (_) {}
    _bgmPlaying = false;
  }

  void pauseBgm() {
    if (!_bgmPlaying) return;
    try {
      FlameAudio.bgm.pause();
    } catch (_) {}
  }

  void resumeBgm() {
    if (!enabled || bgmVolume <= 0) return;
    if (_bgmPlaying) {
      try {
        FlameAudio.bgm.resume();
      } catch (_) {}
    } else {
      startBgm();
    }
  }

  void applyBgmSetting() {
    if (!enabled || bgmVolume <= 0) {
      stopBgm();
    } else if (!_bgmPlaying) {
      startBgm();
    }
  }
}
