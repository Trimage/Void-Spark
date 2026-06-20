import 'package:flame/components.dart';

import '../config/game_config.dart';

/// 콤보 시스템 — 오브를 연속 획득할수록 점수 배율이 오른다.
/// 일정 시간([GameConfig.comboTimeout]) 동안 미획득 시 리셋된다.
class ComboSystem extends Component {
  int count = 0;
  double _timer = 0;

  /// 인런 강화로 늘어나는 콤보 유지 시간(초).
  double timeoutBonus = 0;

  double get _timeout => GameConfig.comboTimeout + timeoutBonus;

  /// 현재 점수 배율(1.0 ~ comboMax).
  double get multiplier =>
      (1 + count * GameConfig.comboStep).clamp(1.0, GameConfig.comboMax);

  /// 콤보 게이지 잔여 비율(0~1) — HUD 표시용.
  double get fill => count == 0 ? 0 : (_timer / _timeout).clamp(0.0, 1.0);

  /// 오브 획득 시 호출.
  void register() {
    count++;
    _timer = _timeout;
  }

  /// 시작 콤보 보너스 등으로 콤보를 특정 값에서 시작시킨다.
  void seed(int value) {
    count = value;
    _timer = _timeout;
  }

  void reset() {
    count = 0;
    _timer = 0;
  }

  @override
  void update(double dt) {
    if (count > 0) {
      _timer -= dt;
      if (_timer <= 0) reset();
    }
  }
}
