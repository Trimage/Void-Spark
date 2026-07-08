import '../systems/loc.dart';

/// 파편으로 구매하는 영구 강화 정의(다국어 맵). 비용 리스트 길이 = 최대 레벨.
class UpgradeDef {
  const UpgradeDef(this.id, this._name, this._desc, this.icon, this.costs);

  final String id;
  final Map<String, String> _name;
  final Map<String, String> _desc;
  final String icon;
  final List<int> costs;

  String get name => tr(_name);
  String get desc => tr(_desc);

  int get maxLevel => costs.length;
}

class Upgrades {
  Upgrades._();

  static const fireRate = UpgradeDef(
      'up_fire',
      {'ko': '연사 강화', 'en': 'Rapid Fire', 'ja': '連射強化', 'zh': '连射强化'},
      {'ko': '사격 속도 증가', 'en': 'Increase fire rate', 'ja': '射撃速度アップ', 'zh': '提升射速'},
      'bolt',
      [320, 700, 1300]);
  static const moveSpeed = UpgradeDef(
      'up_speed',
      {'ko': '기동 강화', 'en': 'Mobility', 'ja': '機動強化', 'zh': '机动强化'},
      {'ko': '코어 이동 속도 증가', 'en': 'Faster core movement', 'ja': 'コア移動が速く', 'zh': '核心移动更快'},
      'speed',
      [320, 700, 1300]);
  static const bombSlot = UpgradeDef(
      'up_bomb',
      {'ko': '폭탄 증설', 'en': 'Bomb Slot', 'ja': 'ボム増設', 'zh': '炸弹槽位'},
      {'ko': '폭탄 최대 비축 +1', 'en': '+1 max bomb', 'ja': 'ボム最大+1', 'zh': '炸弹上限+1'},
      'bomb',
      [860, 1820]);
  static const magnet = UpgradeDef(
      'up_magnet',
      {'ko': '자력 강화', 'en': 'Magnetism', 'ja': '磁力強化', 'zh': '磁力强化'},
      {'ko': '오브 흡입 범위 증가', 'en': 'Larger orb pickup', 'ja': 'オーブ吸引範囲アップ', 'zh': '拾取范围增大'},
      'magnet',
      [250, 560, 1020]);
  static const xpBoost = UpgradeDef(
      'up_xp',
      {'ko': '성장 가속', 'en': 'Growth', 'ja': '成長加速', 'zh': '成长加速'},
      {'ko': '레벨업 XP +15%', 'en': '+15% XP per level', 'ja': 'レベルXP +15%', 'zh': '升级经验 +15%'},
      'xp',
      [430, 960]);
  static const luck = UpgradeDef(
      'up_luck',
      {'ko': '행운', 'en': 'Fortune', 'ja': '幸運', 'zh': '幸运'},
      {'ko': '파워업 드롭률 증가', 'en': 'Higher drop rate', 'ja': 'パワーアップ出現率増', 'zh': '提升道具掉率'},
      'luck',
      [370, 840]);

  static const all = [fireRate, moveSpeed, bombSlot, magnet, xpBoost, luck];
}
