import 'package:flutter/material.dart';

import '../config/palette.dart';
import '../systems/loc.dart';
import '../systems/save.dart';

/// 설정 — 사운드/햅틱/조작(상대 드래그·자동 조준) 토글. 즉시 로컬 저장.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  SaveSystem get save => SaveSystem.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.voidDeep,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Palette.textHi),
        title: const Text('SETTINGS',
            style: TextStyle(letterSpacing: 4, fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _languageRow(),
          const Divider(color: Colors.white12, height: 36),
          _tile(
            t('사운드', 'Sound', ja: 'サウンド', zh: '音效'),
            t('효과음 재생', 'Play sound effects'),
            save.soundOn,
            (v) async {
              await save.setSound(v);
              setState(() {});
            },
          ),
          _slider(
            t('효과음 볼륨', 'SFX volume', ja: '効果音音量', zh: '音效音量'),
            save.sfxVolume,
            (v) async {
              await save.setSfxVolume(v);
              setState(() {});
            },
          ),
          _slider(
            t('배경음 볼륨', 'BGM volume', ja: 'BGM音量', zh: '背景音量'),
            save.bgmVolume,
            (v) async {
              await save.setBgmVolume(v);
              setState(() {});
            },
          ),
          _tile(
            t('진동(햅틱)', 'Vibration', ja: '振動', zh: '震动'),
            t('피격·보스·폭탄 시 진동 (모바일)', 'Haptics on hit/boss/bomb (mobile)'),
            save.hapticsOn,
            (v) async {
              await save.setHaptics(v);
              setState(() {});
            },
          ),
          const Divider(color: Colors.white12, height: 36),
          _tile(
            t('상대 드래그 모드', 'Relative drag', ja: '相対ドラッグ', zh: '相对拖动'),
            t('손가락이 코어를 가리지 않게 시작점 기준 상대 이동',
                'Move relative to touch start (finger off the core)'),
            save.relativeDrag,
            (v) async {
              await save.setRelativeDrag(v);
              setState(() {});
            },
          ),
          _tile(
            t('조작 버튼 오른쪽', 'Buttons on right', ja: 'ボタンを右に', zh: '按钮在右侧'),
            t('폭탄 버튼을 오른쪽 하단에 배치 (끄면 왼쪽)',
                'Bomb button at bottom-right (off = left)'),
            save.controlsOnRight,
            (v) async {
              await save.setControlsOnRight(v);
              setState(() {});
            },
          ),
          _tile(
            t('슬로우모션 연출', 'Slow-motion', ja: 'スロー演出', zh: '慢动作'),
            t('아슬아슬하게 피할 때 짧은 슬로우모션 (끄면 항상 일반 속도)',
                'Brief slow-mo on close calls (off = always normal)'),
            save.slowMoOn,
            (v) async {
              await save.setSlowMo(v);
              setState(() {});
            },
          ),
          const Divider(color: Colors.white12, height: 36),
          _tile(
            t('번쩍임 줄이기', 'Reduce flashing', ja: '点滅を抑える', zh: '减少闪烁'),
            t('피격 붉은 플래시·과도한 깜빡임 완화 (광과민성 배려)',
                'Reduce red flash & strobe (photosensitivity)'),
            save.reduceFlashing,
            (v) async {
              await save.setReduceFlashing(v);
              setState(() {});
            },
          ),
          _slider(
            t('화면 흔들림', 'Screen shake', ja: '画面の揺れ', zh: '屏幕震动'),
            save.shakeIntensity,
            (v) async {
              await save.setShakeIntensity(v);
              setState(() {});
            },
          ),
          const Divider(color: Colors.white12, height: 36),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.school_outlined, color: Palette.core),
            title: Text(t('튜토리얼 다시보기', 'Replay tutorial',
                ja: 'チュートリアル再表示', zh: '重看教程'),
                style: const TextStyle(
                    color: Palette.textHi,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
            subtitle: Text(t('다음 게임 시작 시 안내를 다시 표시', 'Show guide on next run'),
                style: const TextStyle(color: Palette.textDim, fontSize: 12)),
            trailing: const Icon(Icons.chevron_right, color: Palette.textDim),
            onTap: () async {
              await save.resetTutorial();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(t('다음 판에 튜토리얼이 표시됩니다',
                    'Tutorial will show on next run')),
                duration: const Duration(milliseconds: 900),
                backgroundColor: Palette.voidMid,
              ));
            },
          ),
          const SizedBox(height: 20),
          Text(
            t('볼륨은 다음 판부터, 나머지는 즉시/다음 판에 적용됩니다.',
                'Volume applies next run; others apply immediately or next run.'),
            style: const TextStyle(color: Palette.textDim, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _languageRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Palette.voidMid.withValues(alpha: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t('언어', 'Language', ja: '言語', zh: '语言'),
                style: const TextStyle(
                  color: Palette.textHi,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                )),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final l in kLanguages)
                  GestureDetector(
                    onTap: () async {
                      await save.setLang(l[0]);
                      setState(() {});
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: save.lang == l[0]
                            ? Palette.core.withValues(alpha: 0.18)
                            : Colors.transparent,
                        border: Border.all(
                          color: save.lang == l[0]
                              ? Palette.core
                              : Palette.textDim,
                        ),
                      ),
                      child: Text(l[1],
                          style: TextStyle(
                            color: save.lang == l[0]
                                ? Palette.core
                                : Palette.textDim,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          )),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _slider(String title, double value, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Palette.voidMid.withValues(alpha: 0.5),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 110,
              child: Text(title,
                  style: const TextStyle(
                    color: Palette.textHi,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  )),
            ),
            Expanded(
              child: Slider(
                value: value.clamp(0.0, 1.0),
                activeColor: Palette.core,
                inactiveColor: Palette.voidDeep,
                onChanged: onChanged,
              ),
            ),
            SizedBox(
              width: 38,
              child: Text('${(value * 100).round()}',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      color: Palette.textDim, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Palette.voidMid.withValues(alpha: 0.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                        color: Palette.textHi,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      )),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          color: Palette.textDim, fontSize: 12)),
                ],
              ),
            ),
            Switch(
              value: value,
              activeColor: Palette.core,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
