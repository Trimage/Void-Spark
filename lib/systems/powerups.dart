import 'package:flame/components.dart';

import '../components/powerup.dart';
import '../config/game_config.dart';

/// 파워업 상태 관리 — 지속형 효과 타이머, 1회성 실드, 폭탄 비축을 추적한다.
/// 코어 사격(Spread/Rapid), 시간 배율(Slow), 오브 흡입(Magnet),
/// 피격 방어(Shield), 폭탄(Bomb)이 이 상태를 참조한다.
class PowerupSystem extends Component {
  double _spread = 0;
  double _rapid = 0;
  double _slow = 0;
  double _magnet = 0;
  double _pierce = 0;
  double _aim = 0;

  bool shield = false;
  int bombs = 0;

  /// 폭탄 최대 비축(영구 업그레이드로 증가; 게임이 설정).
  int maxBombs = GameConfig.bombMax;

  bool get spreadActive => _spread > 0;
  bool get rapidActive => _rapid > 0;
  bool get slowActive => _slow > 0;
  bool get magnetActive => _magnet > 0;
  bool get pierceActive => _pierce > 0;
  bool get aimActive => _aim > 0;

  /// 지속형 효과의 잔여 시간(초) — HUD 아이콘 표시용.
  double get spreadRemaining => _spread;
  double get rapidRemaining => _rapid;
  double get slowRemaining => _slow;
  double get magnetRemaining => _magnet;
  double get pierceRemaining => _pierce;
  double get aimRemaining => _aim;

  /// 파워업 획득 적용.
  void apply(PowerupType type) {
    switch (type) {
      case PowerupType.spread:
        _spread = GameConfig.spreadDuration;
      case PowerupType.rapid:
        _rapid = GameConfig.rapidDuration;
      case PowerupType.slow:
        _slow = GameConfig.slowDuration;
      case PowerupType.magnet:
        _magnet = GameConfig.magnetDuration;
      case PowerupType.pierce:
        _pierce = GameConfig.pierceDuration;
      case PowerupType.aim:
        _aim = GameConfig.aimDuration;
      case PowerupType.shield:
        shield = true;
      case PowerupType.bomb:
        if (bombs < maxBombs) bombs++;
    }
  }

  void reset() {
    _spread = _rapid = _slow = _magnet = _pierce = _aim = 0;
    shield = false;
    bombs = 0;
  }

  @override
  void update(double dt) {
    if (_spread > 0) _spread -= dt;
    if (_rapid > 0) _rapid -= dt;
    if (_slow > 0) _slow -= dt;
    if (_magnet > 0) _magnet -= dt;
    if (_pierce > 0) _pierce -= dt;
    if (_aim > 0) _aim -= dt;
  }
}
