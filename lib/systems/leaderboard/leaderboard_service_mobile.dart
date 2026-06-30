import 'package:games_services/games_services.dart';
import 'package:flutter/foundation.dart';

import '../../config/game_config.dart';
import 'leaderboard_service.dart';

/// Android(Play Games) / iOS(Game Center) 글로벌 리더보드 구현.
/// !!! Play Console / App Store Connect에 리더보드를 만들고
/// GameConfig의 ID를 실제 값으로 교체해야 동작한다.
class MobileLeaderboardService implements LeaderboardService {
  bool _signedIn = false;

  @override
  bool get available => _signedIn;

  @override
  Future<void> init() async {
    try {
      await GamesServices.signIn();
      _signedIn = await GamesServices.isSignedIn;
    } catch (e) {
      debugPrint('GamesServices sign-in failed: $e');
      _signedIn = false;
    }
  }

  @override
  Future<void> submit(int score, int difficulty) async {
    if (!_signedIn) return;
    try {
      await GamesServices.submitScore(
        score: Score(
          androidLeaderboardID: GameConfig.androidLeaderboardId(difficulty),
          iOSLeaderboardID: GameConfig.iosLeaderboardId(difficulty),
          value: score,
        ),
      );
    } catch (e) {
      debugPrint('submitScore failed: $e');
    }
  }

  @override
  Future<int?> playerGlobalRank(int difficulty) async {
    if (!_signedIn) return null;
    try {
      final data = await Leaderboards.getPlayerScoreObject(
        androidLeaderboardID: GameConfig.androidLeaderboardId(difficulty),
        iOSLeaderboardID: GameConfig.iosLeaderboardId(difficulty),
        scope: PlayerScope.global,
        timeScope: TimeScope.allTime,
      );
      final rank = data?.rank;
      // 순위는 1 이상이어야 유효(미등록/오류 시 0 이하가 올 수 있음).
      return (rank != null && rank > 0) ? rank : null;
    } catch (e) {
      debugPrint('playerGlobalRank failed: $e');
      return null;
    }
  }

  @override
  Future<void> showGlobal(int difficulty) async {
    try {
      await GamesServices.showLeaderboards(
        androidLeaderboardID: GameConfig.androidLeaderboardId(difficulty),
        iOSLeaderboardID: GameConfig.iosLeaderboardId(difficulty),
      );
    } catch (e) {
      debugPrint('showLeaderboards failed: $e');
    }
  }
}

LeaderboardService createLeaderboardService() => MobileLeaderboardService();
