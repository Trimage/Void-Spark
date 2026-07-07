import 'package:flutter/material.dart';

/// 코어 스킨 정의(색상 + 글로우). 0번은 기본(무료 보유).
class CoreSkin {
  const CoreSkin(this.name, this.color, this.glow, this.price, {this.packId});

  final String name;
  final Color color;
  final Color glow;

  /// 해금 가격(파편). 0이면 기본 보유. packId가 있으면 파편 구매 불가(IAP 전용).
  final int price;

  /// 소속 IAP 스킨 팩 ID(null이면 파편으로 구매). 'premium_skins' 또는 'skin_pack2'.
  final String? packId;

  /// 프리미엄(IAP 전용) 스킨 여부.
  bool get premium => packId != null;

  /// 코어 뒤 잔상(트레일) 샘플 길이. 프리미엄 스킨은 더 길고 화려하게.
  int get trailLength => premium ? 16 : 9;
}

class Skins {
  Skins._();

  static const List<CoreSkin> all = [
    // 파편으로 해금되는 스킨.
    CoreSkin('SPARK', Color(0xFF7DF9FF), Color(0xFF21E6FF), 0),
    CoreSkin('EMBER', Color(0xFFFFB45C), Color(0xFFFF6B2E), 300),
    CoreSkin('TOXIC', Color(0xFFC6FF4D), Color(0xFF8BFF00), 500),
    CoreSkin('NOVA', Color(0xFFFF6FD8), Color(0xFFFF2EC4), 720),
    CoreSkin('PULSE', Color(0xFF6EE7FF), Color(0xFF00B4FF), 920),
    CoreSkin('FROST', Color(0xFFD6FBFF), Color(0xFF8AD8FF), 1150),
    CoreSkin('AURUM', Color(0xFFFFE36E), Color(0xFFFFC400), 1500),
    // 프리미엄 팩 1 (IAP: premium_skins).
    CoreSkin('PRISM', Color(0xFFB6FFF7), Color(0xFF00FFD0), 0,
        packId: 'premium_skins'),
    CoreSkin('VOIDX', Color(0xFFC79BFF), Color(0xFF7A2BFF), 0,
        packId: 'premium_skins'),
    // 프리미엄 팩 2 (IAP: skin_pack2).
    CoreSkin('SOLAR', Color(0xFFFFD36E), Color(0xFFFF8A00), 0,
        packId: 'skin_pack2'),
    CoreSkin('ABYSS', Color(0xFF5FA8FF), Color(0xFF1B3CFF), 0,
        packId: 'skin_pack2'),
  ];

  static CoreSkin at(int index) => all[index.clamp(0, all.length - 1)];
}
