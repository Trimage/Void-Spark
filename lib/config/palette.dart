import 'package:flutter/material.dart';

/// 네온 벡터 룩을 위한 색상 팔레트.
/// 모든 오브젝트는 이미지 에셋 없이 이 색들 + 글로우로 렌더링한다.
class Palette {
  Palette._();

  // 배경 (디지털 공허)
  static const Color voidDeep = Color(0xFF05060E);
  static const Color voidMid = Color(0xFF0B0E1F);

  // 코어(플레이어) — 시안/화이트 발광
  static const Color core = Color(0xFF7DF9FF);
  static const Color coreGlow = Color(0xFF21E6FF);

  // 적 / 손상된 도형 — 마젠타 ~ 핑크 계열
  static const Color corrupt = Color(0xFFFF4D9D);
  static const Color corruptGlow = Color(0xFFFF2E63);

  // 강조 / 콤보 — 라임/옐로
  static const Color accent = Color(0xFFC6FF4D);

  // 파워업 — 바이올렛
  static const Color orb = Color(0xFFB388FF);

  // 점수 오브 — 금색(적 탄막·플레이어와 확실히 구분되는 '수집물' 색)
  static const Color scoreOrb = Color(0xFFFFD23F);
  static const Color scoreOrbGlow = Color(0xFFFFA000);

  // 위험 / 피격 플래시
  static const Color danger = Color(0xFFFF1744);

  // 조준탄(코어를 노리는 피하기 어려운 탄) — 일반 탄막(분홍)과 구분되는 붉은 경고색.
  static const Color aimedBullet = Color(0xFFFF3B3B);
  static const Color aimedBulletGlow = Color(0xFFFF1744);

  // UI 텍스트
  static const Color textHi = Color(0xFFEAF6FF);
  static const Color textDim = Color(0xFF6E7BA8);
}
