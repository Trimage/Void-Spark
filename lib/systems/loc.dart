import 'save.dart';

/// 경량 다국어 헬퍼. 위젯/Flame 컴포넌트 어디서든 BuildContext 없이 호출 가능.
/// 호출 시점의 언어 설정을 읽으므로 런타임 전환이 즉시 반영된다.
/// ja/zh 미지정 시 영어로 폴백한다(절대 깨지지 않음).
String t(String ko, String en, {String? ja, String? zh}) {
  switch (SaveSystem.instance.lang) {
    case 'en':
      return en;
    case 'ja':
      return ja ?? en;
    case 'zh':
      return zh ?? en;
    default:
      return ko;
  }
}

/// 언어 코드별 문자열 맵에서 현재 언어를 고른다(없으면 en→첫값 폴백).
String tr(Map<String, String> m) =>
    m[SaveSystem.instance.lang] ?? m['en'] ?? m.values.first;

/// 지원 언어 목록(설정 선택지).
const List<List<String>> kLanguages = [
  ['ko', '한국어'],
  ['en', 'English'],
  ['ja', '日本語'],
  ['zh', '中文'],
];
