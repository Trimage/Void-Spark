/// 글로벌 리더보드 추상 인터페이스(플랫폼 구현은 conditional import로 주입).
/// 로컬 TOP 기록은 SaveSystem이 항상 제공하고, 이 서비스는 '글로벌 순위'를 담당한다.
abstract class LeaderboardService {
  /// 로그인/초기화(자동 로그인 시도). 미지원/실패 시 [available]=false.
  Future<void> init();

  /// 이 플랫폼에서 글로벌 순위를 쓸 수 있는가(웹 등은 false).
  bool get available;

  /// 점수 제출(난이도별 리더보드로).
  Future<void> submit(int score, int difficulty);

  /// 네이티브 리더보드 UI 표시(난이도별).
  Future<void> showGlobal(int difficulty);
}
