/// 한 판 동안 누적되는 인런 강화(로그라이트). 레벨업 선택으로 스택된다.
/// 영구 업그레이드(SaveSystem)와 달리 판이 끝나면 초기화된다.
class RunMods {
  double fireIntervalMul = 1.0; // 사격 간격 배율(작을수록 빠름)
  int extraSpread = 0; // 양옆 추가 탄(쌍)
  bool pierce = false; // 관통
  double followBonus = 0; // 이동 반응
  int damageBonus = 0; // 탄 데미지 +
  double assistBonus = 0; // 오브 흡입 범위 +
  double comboTimeoutBonus = 0; // 콤보 유지 시간 +
  bool backShot = false; // 후방 사격
  int orbBonus = 0; // 오브 점수 +
  double shieldRegen = 0; // 실드 자동 재생 주기(초), 0=없음

  void reset() {
    fireIntervalMul = 1.0;
    extraSpread = 0;
    pierce = false;
    followBonus = 0;
    damageBonus = 0;
    assistBonus = 0;
    comboTimeoutBonus = 0;
    backShot = false;
    orbBonus = 0;
    shieldRegen = 0;
  }
}
