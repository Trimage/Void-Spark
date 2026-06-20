# VOID SPARK — 출시 체크리스트 (내가 할 일)

게임 코드/기능은 완료 상태. 아래는 **개발자 계정·콘솔·기기·결정**이 필요해 직접 해야 하는 항목들.

---

## 1) 계정 / 콘솔 준비
- [ ] **Google Play Console** 개발자 등록(1회 $25)
- [ ] **Apple Developer Program** 등록(연 $99) — iOS 출시 시
- [ ] 앱 등록(패키지/번들 ID 확정)
  - Android: `com.voidspark.void_spark`
  - iOS: `com.voidspark.voidSpark`

## 2) 실제 ID로 교체 (현재 테스트/플레이스홀더)
- [ ] **AdMob** 앱 ID + 보상형 광고 단위 ID (지금은 Google 테스트 ID)
  - `android/app/src/main/AndroidManifest.xml` (APPLICATION_ID)
  - `ios/Runner/Info.plist` (GADApplicationIdentifier)
  - `lib/systems/ads/ad_service_mobile.dart` (보상형 단위 ID)
- [ ] **인앱결제 상품** 생성 + 가격 책정 (Play Console / App Store Connect)
  - ID: `voidspark.shards.small/medium/large`, `voidspark.double_shards`,
    `voidspark.premium_skins`, `voidspark.skin_pack2`, `voidspark.founders`
  - 참고가는 `lib/systems/iap/iap_service.dart`의 `priceLabel` — 실제 책정가로
  - iOS: Xcode에서 **In-App Purchase** capability 추가
- [ ] **리더보드** 난이도별 3개씩 생성 → ID 교체 (`lib/config/game_config.dart`)
  - `androidLeaderboardIds`, `iosLeaderboardIds` (Easy/Normal/Hard)
  - Android: Play Games Services 연결(앱 ID/OAuth 동의화면)
  - iOS: Xcode **Game Center** capability 추가

## 3) 서명 / 빌드
- [ ] **Android keystore** 생성 + `key.properties` + `build.gradle.kts` 서명 설정
- [ ] `flutter build appbundle` (Play 업로드용 .aab)
- [ ] **iOS** Xcode 서명(Team/프로비저닝) → `flutter build ipa`

## 4) 스토어 등록물
- [ ] 앱 아이콘 — 완료(`assets/icon/`, 전 플랫폼 생성됨)
- [ ] **스크린샷** (실기기 캡처, 한·영) + **피처 그래픽/트레일러**
  - 키 아트 1차 생성본 있음(필요 시 더 생성 가능)
- [ ] 스토어 설명/키워드 — `STORE_LISTING.md` 내용 붙여넣기(한·영 완비)
- [ ] **개인정보처리방침 호스팅** — `PRIVACY_POLICY.md`를 웹(GitHub Pages/Notion 등)에
        올리고 URL을 콘솔에 입력. 문서 내 `[개발자명]`·`[연락처 이메일]` 채우기
- [ ] 콘텐츠 등급 설문(폭력성 낮음/광고 포함/구매 포함)

## 5) 테스트
- [ ] **실기기 플레이테스트** — 햅틱/사운드/터치 체감, 밸런스(난이도·XP·파편 경제)
- [ ] 저사양 기기 1대 성능 확인
- [ ] IAP/광고/리더보드 **실제 동작 확인**(스토어 등록 후 내부 테스트 트랙)

## 6) (선택) 백엔드/품질
- [ ] **Firebase** 연결 — 실제 분석/크래시 리포팅
        (`lib/systems/analytics.dart` 한 곳을 Firebase로 교체)
- [ ] **IAP 영수증 서버 검증**(보안) — 현재는 클라이언트 지급
- [ ] 클라우드 세이브(Play Games Saved Games / iCloud)
- [ ] 추가 언어(일본어/중국어 등) — i18n 인프라는 준비됨, 번역만 추가

---

### 내가 더 도울 수 있는 것 (코드/문서)
- 밸런스 수치 조정(난이도·XP·가격), 추가 언어 번역, 마케팅 에셋 추가 생성,
  Android 서명 설정 가이드, Firebase 연동 코드 골격 등 — 요청 시 진행.
