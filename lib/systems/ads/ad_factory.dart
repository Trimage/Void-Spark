// 플랫폼별 AdService 구현 주입.
// 웹 빌드에서는 google_mobile_ads를 전혀 임포트하지 않도록
// conditional export로 모바일/웹 구현을 분기한다.
export 'ad_service_mobile.dart'
    if (dart.library.html) 'ad_service_web.dart';
