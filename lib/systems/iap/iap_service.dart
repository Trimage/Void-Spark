import '../loc.dart';

/// 인앱결제 상품 유형.
enum IapKind { consumableShards, entitlement }

/// 인앱결제 상품 정의(다국어 맵).
/// !!! [id]는 App Store Connect / Play Console에 동일하게 등록해야 한다.
class IapProduct {
  const IapProduct(this.id, this._name, this._desc, this.kind,
      {this.shards = 0, this.priceLabel = ''});

  final String id;
  final Map<String, String> _name;
  final Map<String, String> _desc;
  final IapKind kind;

  /// 소비성(파편 팩)일 때 지급량.
  final int shards;

  /// 스토어 가격이 아직 안 불러와졌을 때 표시할 참고 가격.
  final String priceLabel;

  String get name => tr(_name);
  String get desc => tr(_desc);
}

/// 추천 상품 카탈로그 — 부담 없는 가격대. (참고가는 출시 시 콘솔 책정가로 교체)
class IapCatalog {
  IapCatalog._();

  static const shardsSmall = IapProduct(
      'voidspark.shards.small',
      {'ko': '파편 한 줌', 'en': 'Handful of Shards', 'ja': 'ひと握りの破片', 'zh': '一把碎片'},
      {'ko': '+600 파편', 'en': '+600 shards', 'ja': '+600 破片', 'zh': '+600 碎片'},
      IapKind.consumableShards,
      shards: 600,
      priceLabel: '₩1,100');
  static const shardsMedium = IapProduct(
      'voidspark.shards.medium',
      {'ko': '파편 주머니', 'en': 'Pouch of Shards', 'ja': '破片の袋', 'zh': '碎片袋'},
      {'ko': '+2,000 파편', 'en': '+2,000 shards', 'ja': '+2,000 破片', 'zh': '+2,000 碎片'},
      IapKind.consumableShards,
      shards: 2000,
      priceLabel: '₩2,200');
  static const shardsLarge = IapProduct(
      'voidspark.shards.large',
      {'ko': '파편 금고', 'en': 'Vault of Shards', 'ja': '破片の金庫', 'zh': '碎片宝库'},
      {'ko': '+5,500 파편', 'en': '+5,500 shards', 'ja': '+5,500 破片', 'zh': '+5,500 碎片'},
      IapKind.consumableShards,
      shards: 5500,
      priceLabel: '₩4,400');
  static const doubleShards = IapProduct(
      'voidspark.double_shards',
      {'ko': '파편 영구 2배', 'en': 'Double Shards', 'ja': '破片 永久2倍', 'zh': '碎片永久翻倍'},
      {'ko': '모든 판의 파편 획득 2배', 'en': 'Always earn 2x shards', 'ja': '常に破片2倍', 'zh': '永久双倍碎片'},
      IapKind.entitlement,
      priceLabel: '₩3,300');
  static const premiumSkins = IapProduct(
      'voidspark.premium_skins',
      {'ko': '프리미엄 스킨 팩', 'en': 'Premium Skins', 'ja': 'プレミアムスキン', 'zh': '高级皮肤包'},
      {'ko': '전용 스킨 PRISM·VOIDX', 'en': 'Skins PRISM & VOIDX', 'ja': '専用スキン PRISM・VOIDX', 'zh': '专属皮肤 PRISM·VOIDX'},
      IapKind.entitlement,
      priceLabel: '₩2,500');
  static const skinPack2 = IapProduct(
      'voidspark.skin_pack2',
      {'ko': '네온 스킨 팩', 'en': 'Neon Skins', 'ja': 'ネオンスキン', 'zh': '霓虹皮肤包'},
      {'ko': '전용 스킨 SOLAR·ABYSS', 'en': 'Skins SOLAR & ABYSS', 'ja': '専用スキン SOLAR・ABYSS', 'zh': '专属皮肤 SOLAR·ABYSS'},
      IapKind.entitlement,
      priceLabel: '₩2,500');
  static const foundersPack = IapProduct(
      'voidspark.founders_pack',
      {'ko': '파운더스 팩', 'en': "Founder's Pack", 'ja': 'ファウンダーズ', 'zh': '创始者礼包'},
      {
        'ko': '프리미엄 스킨 + 파편 2배 + 파편 2,000',
        'en': 'Premium skins + 2x shards + 2,000 shards',
        'ja': 'スキン+破片2倍+破片2,000',
        'zh': '皮肤+双倍碎片+2,000碎片',
      },
      IapKind.entitlement,
      priceLabel: '₩8,900');

  static const all = [
    shardsSmall,
    shardsMedium,
    shardsLarge,
    doubleShards,
    premiumSkins,
    skinPack2,
    foundersPack,
  ];

  static IapProduct? byId(String id) {
    for (final p in all) {
      if (p.id == id) return p;
    }
    return null;
  }
}

/// 인앱결제 추상 인터페이스. 플랫폼 구현은 conditional import로 주입된다.
abstract class IapService {
  Future<void> init();
  bool get available;
  String? priceOf(String id);
  Future<void> buy(IapProduct product);
  Future<void> restore();
  int get changeTick;
  void dispose();
}
