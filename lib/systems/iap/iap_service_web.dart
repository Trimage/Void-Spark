import 'iap_service.dart';

/// 웹/미지원 플랫폼용 무동작 결제 구현(상점의 현금 상품이 숨겨짐).
class _NoopIapService implements IapService {
  @override
  Future<void> init() async {}

  @override
  bool get available => false;

  @override
  String? priceOf(String id) => null;

  @override
  Future<void> buy(IapProduct product) async {}

  @override
  Future<void> restore() async {}

  @override
  int get changeTick => 0;

  @override
  void dispose() {}
}

IapService createIapService() => _NoopIapService();
