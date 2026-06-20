import 'ad_service.dart';

/// 웹/미지원 플랫폼용 무동작 광고 구현. 광고 버튼은 숨겨진다.
class _NoopAdService implements AdService {
  @override
  Future<void> init() async {}

  @override
  bool get available => false;

  @override
  void loadRewarded() {}

  @override
  bool get rewardedReady => false;

  @override
  Future<bool> showRewarded() async => false;

  @override
  void dispose() {}
}

AdService createAdService() => _NoopAdService();
