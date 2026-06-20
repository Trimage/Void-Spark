import 'leaderboard_service.dart';

/// 웹/미지원 플랫폼용 무동작 글로벌 리더보드(로컬 기록만 사용).
class _NoopLeaderboard implements LeaderboardService {
  @override
  Future<void> init() async {}

  @override
  bool get available => false;

  @override
  Future<void> submit(int score, int difficulty) async {}

  @override
  Future<void> showGlobal(int difficulty) async {}
}

LeaderboardService createLeaderboardService() => _NoopLeaderboard();
