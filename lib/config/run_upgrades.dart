import '../systems/loc.dart';
import '../systems/run_mods.dart';

/// 레벨업 시 3택 1로 제시되는 인런 강화 정의(다국어 맵).
class RunUpgradeDef {
  RunUpgradeDef(this.id, this._name, this._desc, this.icon, this.apply,
      {this.repeatable = true});

  final String id;
  final Map<String, String> _name;
  final Map<String, String> _desc;
  final String icon;
  final void Function(RunMods m) apply;
  final bool repeatable;

  String get name => tr(_name);
  String get desc => tr(_desc);

  bool exhausted(RunMods m) {
    if (repeatable) return false;
    if (id == 'pierce') return m.pierce;
    if (id == 'back') return m.backShot;
    return false;
  }
}

class RunUpgrades {
  RunUpgrades._();

  static final List<RunUpgradeDef> all = [
    RunUpgradeDef(
        'fire',
        {'ko': '연사 강화', 'en': 'Rapid Fire', 'ja': '連射強化', 'zh': '连射强化'},
        {'ko': '사격 속도 +15%', 'en': 'Fire rate +15%', 'ja': '射撃速度 +15%', 'zh': '射速 +15%'},
        'bolt',
        (m) => m.fireIntervalMul *= 0.85),
    RunUpgradeDef(
        'spread',
        {'ko': '확산탄', 'en': 'Spread Shot', 'ja': '拡散弾', 'zh': '散射'},
        {'ko': '양옆 발사 +1', 'en': '+1 side shot', 'ja': '左右に+1発', 'zh': '左右各+1发'},
        'spread',
        (m) => m.extraSpread += 1),
    RunUpgradeDef(
        'dmg',
        {'ko': '강화 탄두', 'en': 'Warhead', 'ja': '強化弾頭', 'zh': '强化弹头'},
        {'ko': '탄 데미지 +1', 'en': 'Bullet damage +1', 'ja': '弾ダメージ +1', 'zh': '子弹伤害 +1'},
        'dmg',
        (m) => m.damageBonus += 1),
    RunUpgradeDef(
        'move',
        {'ko': '민첩', 'en': 'Agility', 'ja': '敏捷', 'zh': '敏捷'},
        {'ko': '이동 반응 향상', 'en': 'Faster movement', 'ja': '移動が機敏に', 'zh': '移动更灵敏'},
        'move',
        (m) => m.followBonus += 4),
    RunUpgradeDef(
        'magnet',
        {'ko': '자력장', 'en': 'Magnet Field', 'ja': '磁力場', 'zh': '磁力场'},
        {'ko': '오브 흡입 범위 +', 'en': 'Larger orb pickup', 'ja': 'オーブ吸引範囲+', 'zh': '拾取范围+'},
        'magnet',
        (m) => m.assistBonus += 40),
    RunUpgradeDef(
        'combo',
        {'ko': '콤보 유지', 'en': 'Combo Hold', 'ja': 'コンボ維持', 'zh': '连击保持'},
        {'ko': '콤보 지속 +1.5초', 'en': 'Combo +1.5s', 'ja': 'コンボ+1.5秒', 'zh': '连击+1.5秒'},
        'combo',
        (m) => m.comboTimeoutBonus += 1.5),
    RunUpgradeDef(
        'orb',
        {'ko': '값진 빛', 'en': 'Rich Light', 'ja': '貴き光', 'zh': '珍贵之光'},
        {'ko': '오브 점수 +5', 'en': 'Orb score +5', 'ja': 'オーブ得点+5', 'zh': '光球得分+5'},
        'orb',
        (m) => m.orbBonus += 5),
    RunUpgradeDef(
        'pierce',
        {'ko': '관통탄', 'en': 'Pierce', 'ja': '貫通弾', 'zh': '穿透弹'},
        {'ko': '총알이 적을 뚫음', 'en': 'Bullets pierce enemies', 'ja': '弾が敵を貫通', 'zh': '子弹穿透敌人'},
        'pierce',
        (m) => m.pierce = true,
        repeatable: false),
    RunUpgradeDef(
        'back',
        {'ko': '후방 포격', 'en': 'Rear Cannon', 'ja': '後方砲', 'zh': '后方炮'},
        {'ko': '뒤쪽으로도 발사', 'en': 'Also fire backward', 'ja': '後方にも発射', 'zh': '向后也射击'},
        'back',
        (m) => m.backShot = true,
        repeatable: false),
    RunUpgradeDef(
        'regen',
        {'ko': '실드 재생', 'en': 'Shield Regen', 'ja': 'シールド再生', 'zh': '护盾再生'},
        {'ko': '일정 시간마다 실드 충전', 'en': 'Periodic shield', 'ja': '一定時間ごとにシールド', 'zh': '定时获得护盾'},
        'shield',
        (m) => m.shieldRegen = m.shieldRegen == 0 ? 16.0 : m.shieldRegen * 0.7),
  ];
}
