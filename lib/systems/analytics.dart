import 'package:flutter/foundation.dart';

/// 가벼운 분석 추상화. 현재는 디버그 로깅만 하며, 출시 시 이 한 곳을
/// Firebase Analytics / Amplitude 등으로 교체하면 전체 이벤트가 연결된다.
/// (네이티브 의존이 없어 빌드/웹에 영향 없음)
class Analytics {
  Analytics._();
  static final Analytics instance = Analytics._();

  void log(String event, [Map<String, Object?>? params]) {
    // TODO(release): FirebaseAnalytics.instance.logEvent(name: event, parameters: params)
    if (kDebugMode) debugPrint('analytics ▸ $event ${params ?? ''}');
  }

  // 자주 쓰는 이벤트 헬퍼.
  void runStart(int difficulty) =>
      log('run_start', {'difficulty': difficulty});
  void runEnd(int score, int sector, int wave) =>
      log('run_end', {'score': score, 'sector': sector, 'wave': wave});
  void bossKill(int sector) => log('boss_kill', {'sector': sector});
  void victory(int score) => log('victory', {'score': score});
  void levelUp(int level, String upgrade) =>
      log('level_up', {'level': level, 'upgrade': upgrade});
  void purchase(String productId) => log('purchase', {'product': productId});
  void adWatched(String kind) => log('ad_watched', {'kind': kind});
}
