import 'leaderboard_factory.dart';
import 'leaderboard_service.dart';

/// 앱 전역 글로벌 리더보드 인스턴스(플랫폼별 구현 주입).
final LeaderboardService leaderboard = createLeaderboardService();
