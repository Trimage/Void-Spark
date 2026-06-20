// 플랫폼별 LeaderboardService 구현 주입.
// 웹 빌드에서는 games_services를 임포트하지 않도록 conditional export.
export 'leaderboard_service_mobile.dart'
    if (dart.library.html) 'leaderboard_service_web.dart';
