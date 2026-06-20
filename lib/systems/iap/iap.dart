import 'iap_factory.dart';
import 'iap_service.dart';

/// 앱 전역에서 공유하는 결제 서비스 인스턴스(플랫폼별 구현 주입).
/// main()에서 init()을 호출해 구매 스트림을 구독한다.
final IapService iap = createIapService();
