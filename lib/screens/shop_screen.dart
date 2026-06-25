import 'dart:async';

import 'package:flutter/material.dart';

import '../config/game_config.dart';
import '../config/palette.dart';
import '../config/skins.dart';
import '../config/upgrades.dart';
import '../systems/iap/iap.dart';
import '../systems/iap/iap_service.dart';
import '../systems/loc.dart';
import '../systems/save.dart';

/// 상점 — 코어 스킨/업그레이드/시작 보너스(파편) + 인앱결제(현금).
class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  SaveSystem get save => SaveSystem.instance;

  Timer? _iapTick;
  int _lastTick = -1;

  @override
  void initState() {
    super.initState();
    // 결제 완료(비동기 스트림)가 반영되면 화면을 갱신.
    if (GameConfig.iapEnabled && iap.available) {
      _iapTick = Timer.periodic(const Duration(milliseconds: 600), (_) {
        if (iap.changeTick != _lastTick) {
          _lastTick = iap.changeTick;
          if (mounted) setState(() {});
        }
      });
    }
  }

  @override
  void dispose() {
    _iapTick?.cancel();
    super.dispose();
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(msg),
        duration: const Duration(milliseconds: 900),
        backgroundColor: Palette.voidMid,
      ));
  }

  Future<void> _onSkinTap(int index, CoreSkin skin) async {
    if (skin.premium && !save.skinAvailable(index)) {
      _snack(t('현금 상점의 스킨 팩으로 해금돼요',
          'Unlock via a skin pack in the Store'));
      return;
    }
    if (save.skinAvailable(index)) {
      await save.equipSkin(index);
      _snack('${skin.name} ${t('장착', 'equipped')}');
    } else {
      final ok = await save.buySkin(index, skin.price);
      _snack(ok
          ? '${skin.name} ${t('해금!', 'unlocked!')}'
          : t('파편이 부족합니다', 'Not enough shards'));
      if (ok) await save.equipSkin(index);
    }
    if (mounted) setState(() {});
  }

  Future<void> _buyIap(IapProduct p) async {
    _snack(t('스토어를 여는 중...', 'Opening store...'));
    await iap.buy(p);
  }

  Future<void> _buyStartShield() async {
    final ok = await save.buyStartShield();
    _snack(ok
        ? t('시작 실드 해금!', 'Start Shield unlocked!')
        : t('파편이 부족하거나 이미 보유 중', 'Not enough shards, or already owned'));
    if (mounted) setState(() {});
  }

  Future<void> _buyStartBomb() async {
    final ok = await save.buyStartBomb();
    _snack(ok
        ? t('시작 폭탄 해금!', 'Start Bomb unlocked!')
        : t('파편이 부족하거나 이미 보유 중', 'Not enough shards, or already owned'));
    if (mounted) setState(() {});
  }

  Future<void> _buyStartCombo() async {
    final ok = await save.buyStartCombo();
    _snack(ok
        ? t('시작 콤보 해금!', 'Start Combo unlocked!')
        : t('파편이 부족하거나 이미 보유 중', 'Not enough shards, or already owned'));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.voidDeep,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('SHOP',
            style: TextStyle(letterSpacing: 4, fontWeight: FontWeight.w800)),
        iconTheme: const IconThemeData(color: Palette.textHi),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 18),
            child: Row(
              children: [
                const Icon(Icons.diamond_outlined,
                    color: Palette.orb, size: 18),
                const SizedBox(width: 6),
                Text('${save.shards}',
                    style: const TextStyle(
                      color: Palette.orb,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    )),
              ],
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _sectionTitle('CORE SKINS'),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 1.15,
            children: [
              for (var i = 0; i < Skins.all.length; i++)
                // IAP 비활성 시 프리미엄(결제 전용) 스킨은 숨긴다.
                if (GameConfig.iapEnabled || !Skins.all[i].premium)
                  _skinCard(i, Skins.all[i]),
            ],
          ),
          const SizedBox(height: 28),
          _sectionTitle('UPGRADES'),
          const SizedBox(height: 12),
          for (final u in Upgrades.all) ...[
            _upgradeCard(u),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 18),
          _sectionTitle('STARTING BONUS'),
          const SizedBox(height: 12),
          _startShieldCard(),
          const SizedBox(height: 10),
          _startBombCard(),
          const SizedBox(height: 10),
          _startComboCard(),
          if (GameConfig.iapEnabled && iap.available) ...[
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _sectionTitle('STORE'),
                GestureDetector(
                  onTap: () => iap.restore(),
                  child: Text(t('구매 복원', 'Restore'),
                      style: const TextStyle(
                          color: Palette.textDim,
                          fontSize: 12,
                          decoration: TextDecoration.underline)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (final p in IapCatalog.all) ...[
              _iapCard(p),
              const SizedBox(height: 10),
            ],
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _iapCard(IapProduct p) {
    final owned = (p.id == IapCatalog.doubleShards.id && save.doubleShards) ||
        (p.id == IapCatalog.premiumSkins.id && save.premiumSkinsOwned) ||
        (p.id == IapCatalog.skinPack2.id && save.skinPack2Owned) ||
        (p.id == IapCatalog.foundersPack.id && save.foundersOwned);
    // 스토어 가격 우선, 없으면 참고 가격 라벨.
    final price = iap.priceOf(p.id) ?? p.priceLabel;
    return GestureDetector(
      onTap: owned ? null : () => _buyIap(p),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Palette.voidMid.withValues(alpha: 0.55),
          border: Border.all(
            color: owned ? Palette.accent.withValues(alpha: 0.5) : Palette.orb.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          children: [
            Icon(
              p.kind == IapKind.consumableShards
                  ? Icons.diamond
                  : Icons.workspace_premium,
              color: Palette.orb,
              size: 26,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name,
                      style: const TextStyle(
                        color: Palette.textHi,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      )),
                  const SizedBox(height: 3),
                  Text(p.desc,
                      style: const TextStyle(
                          color: Palette.textDim, fontSize: 12)),
                ],
              ),
            ),
            Text(
              owned ? t('보유', 'Owned') : price,
              style: TextStyle(
                color: owned ? Palette.accent : Palette.textHi,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const Map<String, IconData> _icons = {
    'bolt': Icons.bolt,
    'speed': Icons.speed,
    'bomb': Icons.brightness_7,
    'magnet': Icons.adjust,
    'xp': Icons.trending_up,
    'luck': Icons.casino,
  };

  Future<void> _buyUpgrade(UpgradeDef u) async {
    final ok = await save.buyUpgrade(u);
    _snack(ok
        ? '${u.name} ${t('강화!', 'upgraded!')}'
        : t('파편이 부족하거나 최대 레벨이에요', 'Not enough shards, or maxed'));
    if (mounted) setState(() {});
  }

  Widget _upgradeCard(UpgradeDef u) {
    final lvl = save.upgradeLevel(u.id);
    final cost = save.upgradeCost(u);
    final maxed = cost == null;

    return GestureDetector(
      onTap: maxed ? null : () => _buyUpgrade(u),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Palette.voidMid.withValues(alpha: 0.55),
          border: Border.all(
            color: lvl > 0 ? Palette.core.withValues(alpha: 0.5) : Colors.white12,
          ),
        ),
        child: Row(
          children: [
            Icon(_icons[u.icon] ?? Icons.star, color: Palette.core, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(u.name,
                          style: const TextStyle(
                            color: Palette.textHi,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          )),
                      const SizedBox(width: 8),
                      // 레벨 점 표시.
                      ...List.generate(
                        u.maxLevel,
                        (i) => Padding(
                          padding: const EdgeInsets.only(right: 3),
                          child: Icon(
                            Icons.circle,
                            size: 8,
                            color: i < lvl ? Palette.core : Palette.textDim,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(u.desc,
                      style: const TextStyle(
                          color: Palette.textDim, fontSize: 12)),
                ],
              ),
            ),
            Text(
              maxed ? 'MAX' : '$cost ◆',
              style: TextStyle(
                color: maxed ? Palette.textDim : Palette.orb,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) => Text(
        t,
        style: const TextStyle(
          color: Palette.textDim,
          fontSize: 12,
          letterSpacing: 4,
          fontWeight: FontWeight.w700,
        ),
      );

  Widget _skinCard(int index, CoreSkin skin) {
    final owned = save.skinAvailable(index);
    final equipped = save.skinIndex == index;
    final label = equipped
        ? t('장착됨', 'Equipped')
        : owned
            ? t('장착하기', 'Equip')
            : skin.premium
                ? 'PREMIUM'
                : '${skin.price} ◆';

    return GestureDetector(
      onTap: () => _onSkinTap(index, skin),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Palette.voidMid.withValues(alpha: 0.55),
          border: Border.all(
            color: equipped ? skin.color : Colors.white12,
            width: equipped ? 2.5 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 스킨 프리뷰(발광 원).
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: skin.color,
                boxShadow: [
                  BoxShadow(color: skin.glow, blurRadius: 22, spreadRadius: 2),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(skin.name,
                style: const TextStyle(
                  color: Palette.textHi,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                )),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: equipped
                    ? skin.color
                    : owned
                        ? Palette.textDim
                        : (skin.premium ? Palette.accent : Palette.orb),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _startShieldCard() {
    final unlocked = save.startShieldUnlocked;
    return GestureDetector(
      onTap: unlocked ? null : _buyStartShield,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Palette.voidMid.withValues(alpha: 0.55),
          border: Border.all(
            color: unlocked ? Palette.core : Colors.white12,
            width: unlocked ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.shield_outlined, color: Palette.textHi, size: 30),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t('시작 실드', 'Start Shield'),
                      style: const TextStyle(
                        color: Palette.textHi,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      )),
                  const SizedBox(height: 4),
                  Text(
                      t('매 판 1회 피격 방어막을 들고 시작',
                          'Begin each run with a one-hit shield'),
                      style: const TextStyle(
                          color: Palette.textDim, fontSize: 12)),
                ],
              ),
            ),
            Text(
              unlocked ? t('보유', 'Owned') : '${GameConfig.startShieldPrice} ◆',
              style: TextStyle(
                color: unlocked ? Palette.core : Palette.orb,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _startBombCard() {
    final unlocked = save.startBombUnlocked;
    return GestureDetector(
      onTap: unlocked ? null : _buyStartBomb,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Palette.voidMid.withValues(alpha: 0.55),
          border: Border.all(
            color: unlocked ? Palette.danger : Colors.white12,
            width: unlocked ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.bolt, color: Palette.danger, size: 30),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t('시작 폭탄', 'Start Bomb'),
                      style: const TextStyle(
                        color: Palette.textHi,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      )),
                  const SizedBox(height: 4),
                  Text(
                      t('매 판 폭탄 1개를 들고 시작',
                          'Begin each run with 1 bomb'),
                      style: const TextStyle(
                          color: Palette.textDim, fontSize: 12)),
                ],
              ),
            ),
            Text(
              unlocked ? t('보유', 'Owned') : '${GameConfig.startBombPrice} ◆',
              style: TextStyle(
                color: unlocked ? Palette.danger : Palette.orb,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _startComboCard() {
    final unlocked = save.startComboUnlocked;
    return GestureDetector(
      onTap: unlocked ? null : _buyStartCombo,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Palette.voidMid.withValues(alpha: 0.55),
          border: Border.all(
            color: unlocked ? Palette.accent : Colors.white12,
            width: unlocked ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.local_fire_department,
                color: Palette.accent, size: 30),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t('시작 콤보', 'Start Combo'),
                      style: const TextStyle(
                        color: Palette.textHi,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      )),
                  const SizedBox(height: 4),
                  Text(
                      t('콤보 배율을 올린 채로 시작',
                          'Begin each run with a combo head start'),
                      style: const TextStyle(
                          color: Palette.textDim, fontSize: 12)),
                ],
              ),
            ),
            Text(
              unlocked ? t('보유', 'Owned') : '${GameConfig.startComboPrice} ◆',
              style: TextStyle(
                color: unlocked ? Palette.accent : Palette.orb,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
