/// 보상형 광고 추상 인터페이스.
/// 플랫폼 구현은 conditional import([ad_factory.dart])로 주입되며,
/// 웹/미지원 환경에서는 [available]이 false인 무동작 구현이 사용된다.
abstract class AdService {
  /// 광고 SDK 초기화. 미지원 환경에서는 무동작.
  Future<void> init();

  /// 이 플랫폼에서 보상형 광고를 쓸 수 있는가(웹 등은 false).
  bool get available;

  /// 보상형 광고 미리 로드.
  void loadRewarded();

  /// 보상형 광고가 즉시 노출 가능한 상태인가.
  bool get rewardedReady;

  /// 보상형 광고를 노출하고, 보상 획득 시 true를 반환한다.
  Future<bool> showRewarded();

  void dispose();
}
