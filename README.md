# VOID SPARK ⚡

네온 벡터 스타일 2D 탄막 회피 슈팅 아케이드 게임. **Flutter + Flame** 엔진, 단일 코드베이스로 Android / iOS 빌드.

> 당신은 무너져가는 디지털 공허(Void) 속 마지막 빛의 입자 **코어(Core)**.
> 사방에서 몰려오는 손상된 도형들에 맞서 빛이 꺼질 때까지 살아남아라.

모든 오브젝트는 이미지 에셋 없이 **도형 + 발광(글로우/블룸)** 으로 렌더링한다.

---

## 요구 사항

- Flutter 3.29+ (stable), Dart 3.7+
- Android: Android Studio / SDK, **minSdk 23+** (AdMob 요구), Kotlin 플러그인 2.1.0
- iOS: Xcode (macOS)

## 실행

```bash
cd void_spark
flutter pub get

# (선택) 효과음 재생성 — 코드 합성 WAV를 assets/audio/ 에 출력
dart run tool/gen_sfx.dart

# 개발 중 빠른 확인 (웹 — 햅틱/진동 제외)
flutter run -d chrome

# 실기/에뮬레이터
flutter run            # 연결된 기기 자동 선택
flutter run -d <id>    # flutter devices 로 id 확인
```

## 빌드

```bash
flutter build apk            # Android
flutter build appbundle      # Android (Play 스토어)
flutter build ios            # iOS (서명 필요)
```

## 조작

- **드래그**: 코어가 손가락 위치로 부드럽게 이동 (절대 좌표 추적이 기본).
- **상대 드래그 모드**: 손가락이 코어를 가리지 않도록 시작점 기준 상대 이동
  (`GameConfig.relativeDragDefault` / 추후 설정 화면에서 토글).
- 사격은 자동. 좌하단 버튼으로 폭탄 사용.

## 프로젝트 구조

```
lib/
├─ main.dart                 진입점 (세로모드 고정 · 저장 로드 · 메뉴 진입)
├─ void_spark_game.dart      FlameGame — 게임 루프/입력/이벤트 루트
├─ config/
│  ├─ game_config.dart       모든 튜닝 수치(속도/체력/스폰/난이도/메타) 집중
│  ├─ palette.dart           네온 색상 팔레트
│  └─ skins.dart             코어 스킨 정의
├─ components/
│  ├─ neon.dart              발광 도형 렌더링 헬퍼(원/다각형)
│  ├─ neon_background.dart   공허 배경(그라데이션/그리드/펄스)
│  ├─ core.dart              플레이어 코어(드래그·자동사격·스킨)
│  ├─ bullet.dart · enemy_bullet.dart
│  ├─ score_orb.dart · powerup.dart · particle.dart · hud.dart
│  └─ enemies/               drifter·chaser·turret·spinner·splitter·swarm·boss
├─ systems/
│  ├─ spawner.dart · wave_manager.dart · intensity.dart
│  ├─ combo.dart · powerups.dart
│  ├─ juice.dart             화면흔들림·히트스톱·엣지플래시·슬로우모
│  ├─ audio.dart · haptics.dart
│  └─ save.dart              shared_preferences(기록/파편/스킨/일일도전)
├─ screens/
│  ├─ menu_screen.dart · shop_screen.dart · game_screen.dart
│  ├─ game_over_overlay.dart · controls_overlay.dart
│  └─ widgets/neon_button.dart
tool/
└─ gen_sfx.dart              합성 효과음(WAV) 생성기
```

## 개발 로드맵

- [x] **0. 기반 세팅** — 구조/의존성/세로모드, 네온 배경 + 드래그 코어
- [x] **1. 핵심 루프** — 자동 사격 + Drifter 스폰 + 충돌 + 게임오버
- [x] **2. 적 패턴 & 난이도** — 적 6종 + 적 탄막 + 웨이브/Intensity
- [x] **3. 점수/콤보/파워업** — 점수 오브, 콤보, 파워업 6종
- [x] **4. Juice & 보스** — 파티클/히트스톱/화면흔들림/사운드/햅틱, 보스
- [x] **5. 화면 & 메타 진행** — 메뉴/상점, 파편/스킨/일일도전, 로컬 저장
- [x] **+ 설정** — 사운드/햅틱/볼륨 슬라이더/상대드래그/자동조준 + 튜토리얼 다시보기
- [x] **+ 보상형 광고** — 게임오버 opt-in(부활 / 파편 2배)
- [x] **+ 일시정지** — 우상단 ⏸ → RESUME / MENU
- [x] **+ BGM** — 합성 신스웨이브 루프(볼륨 조절, 일시정지 연동)
- [x] **+ 튜토리얼** — 첫 플레이 안내(설정에서 다시보기)
- [x] **+ 무한 난이도** — 생존 시간이 길수록 스폰·적 속도가 끝없이 상승(오버드라이브)
- [x] **+ 콘텐츠** — 보스 2종(Monolith/Vortex 교대) · 파워업 8종(Pierce 관통 · Aim 자동조준)
- [x] **+ 그레이즈 점수** — 적 탄을 스칠수록 보너스(위험 보상) · 런 결과 요약
- [x] **+ 난이도 3모드** — EASY/NORMAL/HARD (스폰·속도·파편보상 차등)
- [x] **+ 영구 업그레이드** — 연사·기동·폭탄증설·자력 (파편 구매, 상점)
- [x] **+ 섹터/엔딩** — 보스 3회 처치 = "빛의 귀환" 후 무한 모드, 섹터별 색조
- [x] **+ 코덱스 & 업적** — 세계관 해금 + 업적 보상
- [x] **+ 접근성** — 번쩍임 줄이기 · 화면 흔들림 강도 슬라이더
- [x] **+ 인앱결제(IAP)** — 파편 팩 · 파편 2배 · 프리미엄 스킨 (웹 격리)
- [x] **+ 인런 로그라이트** — 레벨업 시 강화 3택 1(10종, 누적), LV/XP HUD
- [x] **+ 다국어** — 한국어/English (설정에서 전환, 기기 언어 기본)
- [x] **+ 오브젝트 풀링** — 적탄·파티클 재사용으로 GC 끊김 제거
- [x] **+ 리더보드** — 로컬 TOP 20 기록 + 글로벌 순위(Play Games/Game Center)
- [x] **+ 분석 훅** — Analytics 추상화(디버그 로깅, Firebase 교체 지점 준비)
- [x] **+ 스토어 문안** — [STORE_LISTING.md](STORE_LISTING.md) (한·영)

## 리더보드 (랭킹)

- **로컬 TOP 20** — 기기 내 최고 기록 + 플레이어 이름, 즉시 동작(오프라인)
- **글로벌 순위** — `games_services`로 Android **Play Games** / iOS **Game Center** 네이티브 리더보드. 웹은 conditional import로 격리.

> ⚠️ **출시 전 필수**: Play Console / App Store Connect에 리더보드를 만들고 [game_config.dart](void_spark/lib/config/game_config.dart)의 `androidLeaderboardId`·`iosLeaderboardId`를 실제 값으로 교체. Android는 Play Games Services 설정(앱 ID/OAuth), iOS는 Game Center capability 필요.

## 인앱결제 (in_app_purchase)

웹/미지원 플랫폼은 conditional import(`systems/iap/`)로 SDK 격리 — 웹 빌드는 `in_app_purchase`를 포함하지 않음. 상점 STORE 섹션 + 구매 복원 제공.

| 상품 ID | 유형 | 내용 |
|---|---|---|
| `voidspark.shards.small` / `medium` / `large` | 소비성 | +500 / +1,500 / +4,000 파편 |
| `voidspark.double_shards` | 비소비성 | 파편 획득 영구 2배 |
| `voidspark.premium_skins` | 비소비성 | 전용 코어 스킨(PRISM·VOIDX) 해금 |

> ⚠️ **출시 전 필수**: 위 상품 ID를 **App Store Connect / Play Console에 동일하게 등록**, iOS는 Xcode에서 In-App Purchase capability 추가. 결제 영수증 서버 검증은 미적용(클라이언트 지급) — 필요 시 백엔드 추가 권장.

## 설정

메뉴 우상단 ⚙︎ → 사운드 · 진동(햅틱) · 상대 드래그 모드 · 자동 조준 토글. 모두 즉시 로컬 저장.

## 보상형 광고 (google_mobile_ads)

사용자 부담이 없도록 **전부 opt-in**(직접 눌러야 재생)으로만 배치 — 전면/강제 광고 없음:

- **게임오버 → "부활하기"**: 한 판 1회, 위협 제거 + 실드 + 무적으로 이어하기
- **게임오버 → "파편 2배"**: 이번 판 획득 파편 ×2

웹/미지원 플랫폼에서는 conditional import(`systems/ads/`)로 SDK를 격리해 광고 버튼이 자동으로 숨겨진다 — 웹 빌드는 `google_mobile_ads`를 전혀 포함하지 않는다.

> ⚠️ **출시 전 교체 필수** — 현재는 Google 공식 *테스트* 광고 ID를 사용한다:
> - 단위 ID: `lib/systems/ads/ad_service_mobile.dart`
> - 앱 ID: `android/app/src/main/AndroidManifest.xml`, `ios/Runner/Info.plist`
