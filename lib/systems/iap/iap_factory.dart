// 플랫폼별 IapService 구현 주입.
// 웹 빌드에서는 in_app_purchase를 임포트하지 않도록 conditional export.
export 'iap_service_mobile.dart'
    if (dart.library.html) 'iap_service_web.dart';
