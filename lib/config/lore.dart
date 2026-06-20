import '../systems/loc.dart';

/// 코덱스 항목(다국어 맵). 누적 보스 처치로 순서대로 해금된다.
class LoreEntry {
  const LoreEntry(this._title, this._body);
  final Map<String, String> _title;
  final Map<String, String> _body;

  String get title => tr(_title);
  String get body => tr(_body);
}

class Lore {
  Lore._();

  static const List<LoreEntry> entries = [
    LoreEntry(
      {'ko': '코어', 'en': 'The Core', 'ja': 'コア', 'zh': '核心'},
      {
        'ko': '당신은 꺼져가는 격자 속 마지막 빛의 입자다. 공허가 모든 것을 삼키기 전, 스스로를 태워 길을 밝힌다.',
        'en': 'You are the last spark in a dying grid. Before the Void swallows all, you burn yourself to light the way.',
        'ja': '消えゆく格子の中、最後の光の粒子。虚空が全てを呑む前に、自らを燃やして道を照らす。',
        'zh': '你是消逝栅格中最后的光粒。在虚空吞噬一切之前，你燃烧自己照亮前路。',
      },
    ),
    LoreEntry(
      {'ko': '손상된 도형', 'en': 'Corrupted Shapes', 'ja': '崩れた図形', 'zh': '损坏图形'},
      {
        'ko': '한때 질서를 이루던 기하학들이 부패해 적이 되었다. 그들은 빛을 향해 모여든다.',
        'en': 'Geometries that once held order have rotted into enemies. They swarm the light.',
        'ja': 'かつて秩序だった幾何学が腐り、敵となった。彼らは光へ群がる。',
        'zh': '曾构成秩序的几何已腐化为敌，它们涌向光芒。',
      },
    ),
    LoreEntry(
      {'ko': '모놀리스', 'en': 'Monolith', 'ja': 'モノリス', 'zh': '巨碑'},
      {
        'ko': '섹터의 중심을 지키는 거대한 팔면체. 부서질 때마다 격자에 잠시 빛이 돌아온다.',
        'en': 'A vast octahedron guarding the sector core. Each time it shatters, light briefly returns.',
        'ja': 'セクター中心を守る巨大な八面体。砕けるたび、格子に光が戻る。',
        'zh': '守护区域核心的巨大八面体。每次破碎，光便短暂回归。',
      },
    ),
    LoreEntry(
      {'ko': '보텍스', 'en': 'Vortex', 'ja': 'ヴォーテックス', 'zh': '涡旋'},
      {
        'ko': '회전하는 균열. 그 안을 들여다본 코어는 같은 순간을 무한히 반복했다고 전해진다.',
        'en': 'A spinning rift. They say a core that gazed inside relived the same instant forever.',
        'ja': '回転する裂け目。覗いたコアは同じ瞬間を永遠に繰り返したという。',
        'zh': '旋转的裂隙。据说窥视其中的核心永远重复着同一瞬间。',
      },
    ),
    LoreEntry(
      {'ko': '파편', 'en': 'Shards', 'ja': '破片', 'zh': '碎片'},
      {
        'ko': '처치된 적이 남기는 빛의 조각. 코어는 이것을 모아 다시 단단해진다.',
        'en': 'Slivers of light left by fallen foes. The core gathers them to grow whole again.',
        'ja': '倒した敵が残す光の欠片。コアはこれを集めて強くなる。',
        'zh': '陨落之敌留下的光之碎片。核心收集它们重新变强。',
      },
    ),
    LoreEntry(
      {'ko': '귀환', 'en': 'Return', 'ja': '帰還', 'zh': '归来'},
      {
        'ko': '충분한 빛을 되찾으면 공허는 잠시 물러난다. 그러나 어둠은 결코 끝나지 않는다.',
        'en': 'Restore enough light and the Void recedes. But the dark never ends.',
        'ja': '十分な光を取り戻せば虚空は退く。だが闇は決して終わらない。',
        'zh': '夺回足够的光，虚空便会退去。但黑暗永无止境。',
      },
    ),
  ];
}
