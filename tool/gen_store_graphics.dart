// VOID SPARK — 스토어 그래픽 생성기.
// 외부 에셋 없이 게임과 동일한 네온 스타일로 다음을 생성한다:
//   1) store/icon_512.png        — Play 스토어 아이콘(512x512)
//   2) store/feature_1024x500.png — Play 피처 그래픽(1024x500)
// 실행: dart run tool/gen_store_graphics.dart
import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

// 팔레트(게임 Palette와 동일 계열).
const _voidDeep = [5, 6, 14];
const _voidMid = [11, 14, 31];
const _cyan = [33, 230, 255];
const _white = [255, 255, 255];
const _mag = [255, 46, 99];
const _gold = [255, 196, 64];

double _gauss(double d, double sigma) =>
    math.exp(-(d * d) / (2 * sigma * sigma));

void main() {
  Directory('store').createSync(recursive: true);

  // 1) 512 아이콘: 기존 1024 아이콘을 고품질 축소.
  final iconSrc = img.decodePng(File('assets/icon/icon.png').readAsBytesSync());
  if (iconSrc != null) {
    final icon512 = img.copyResize(iconSrc,
        width: 512, height: 512, interpolation: img.Interpolation.average);
    File('store/icon_512.png').writeAsBytesSync(img.encodePng(icon512));
    stdout.writeln('✓ store/icon_512.png (512x512)');
  } else {
    stdout.writeln('! assets/icon/icon.png 을 찾지 못해 아이콘 축소를 건너뜀');
  }

  // 2) 피처 그래픽.
  final feature = _drawFeature();
  File('store/feature_1024x500.png')
      .writeAsBytesSync(img.encodePng(feature));
  stdout.writeln('✓ store/feature_1024x500.png (1024x500)');
}

img.Image _drawFeature() {
  const w = 1024;
  const h = 500;
  final im = img.Image(width: w, height: h, numChannels: 4);

  // 스파크(코어)를 왼쪽 1/3 지점에 배치.
  const cx = 250.0;
  const cy = 250.0;
  const coreR = 46.0;
  const glowSigma = 220.0;
  const ringR = 120.0;
  const ringSigma = 8.0;
  const beamSigma = 5.0;
  const beamLen = 320.0;
  const dotOrbit = 210.0;
  const dotGlow = 26.0;
  const dotR = 12.0;

  // 마젠타 자석 점.
  final dots = <List<double>>[];
  for (final deg in [40.0, 165.0, 285.0]) {
    final a = deg * math.pi / 180;
    dots.add([cx + math.cos(a) * dotOrbit, cy + math.sin(a) * dotOrbit]);
  }

  // 배경에 흩뿌릴 별/탄 입자(시드 고정으로 매 실행 동일).
  final rnd = math.Random(7);
  final motes = <List<double>>[]; // x,y,r,colorSel
  for (var i = 0; i < 60; i++) {
    motes.add([
      rnd.nextDouble() * w,
      rnd.nextDouble() * h,
      0.6 + rnd.nextDouble() * 1.8,
      rnd.nextDouble(),
    ]);
  }

  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      final dx = x - cx;
      final dy = y - cy;
      final r = math.sqrt(dx * dx + dy * dy);

      final glow = 0.5 * _gauss(r, glowSigma);
      final core = _gauss(r, coreR * 0.9);
      final ring = 0.8 * _gauss(r - ringR, ringSigma);
      final beamH =
          _gauss(dy, beamSigma) * math.max(0, 1 - dx.abs() / beamLen);
      final beamV =
          _gauss(dx, beamSigma) * math.max(0, 1 - dy.abs() / beamLen);
      final beam = 0.85 * math.max(beamH, beamV);

      var dotGlowAmt = 0.0;
      var dotCoreAmt = 0.0;
      for (final d in dots) {
        final dd =
            math.sqrt(math.pow(x - d[0], 2) + math.pow(y - d[1], 2));
        dotGlowAmt += 0.7 * _gauss(dd.toDouble(), dotGlow);
        if (dd < dotR) dotCoreAmt = 1.0;
      }

      // 배경 입자(작은 점광).
      var moteCyan = 0.0;
      var moteGold = 0.0;
      var moteMag = 0.0;
      for (final m in motes) {
        final dd = math.sqrt(math.pow(x - m[0], 2) + math.pow(y - m[1], 2));
        if (dd < m[2] * 4) {
          final a = 0.6 * _gauss(dd.toDouble(), m[2] * 2.2);
          if (m[3] < 0.6) {
            moteCyan += a;
          } else if (m[3] < 0.85) {
            moteGold += a;
          } else {
            moteMag += a;
          }
        }
      }

      final cyanAmt = (glow * 0.7 + ring + beam + moteCyan).clamp(0.0, 2.0);
      final whiteAmt = core.clamp(0.0, 1.0);
      final magAmt = (dotGlowAmt + dotCoreAmt + moteMag).clamp(0.0, 1.5);
      final goldAmt = moteGold.clamp(0.0, 1.0);

      final lr = _cyan[0] * cyanAmt +
          _white[0] * whiteAmt +
          _mag[0] * magAmt +
          _gold[0] * goldAmt;
      final lg = _cyan[1] * cyanAmt +
          _white[1] * whiteAmt +
          _mag[1] * magAmt +
          _gold[1] * goldAmt;
      final lb = _cyan[2] * cyanAmt +
          _white[2] * whiteAmt +
          _mag[2] * magAmt +
          _gold[2] * goldAmt;

      // 대각 그라데이션 배경.
      final t = (x / w * 0.4 + y / h * 0.6);
      final bgR = _voidMid[0] + (_voidDeep[0] - _voidMid[0]) * t;
      final bgG = _voidMid[1] + (_voidDeep[1] - _voidMid[1]) * t;
      final bgB = _voidMid[2] + (_voidDeep[2] - _voidMid[2]) * t;

      im.setPixelRgba(
        x,
        y,
        (bgR + lr).clamp(0, 255).toInt(),
        (bgG + lg).clamp(0, 255).toInt(),
        (bgB + lb).clamp(0, 255).toInt(),
        255,
      );
    }
  }

  // ---- 타이틀 텍스트(네온 글로우) ----
  // 작은 버퍼에 그린 뒤 확대 → 부드러운 글로우 효과.
  _neonText(im, 'VOID', xCenter: 660, yCenter: 175, scale: 4.0, core: _white);
  _neonText(im, 'SPARK',
      xCenter: 660, yCenter: 295, scale: 4.0, core: _cyan);

  // 태그라인.
  _neonText(im, 'UNTIL THE LAST LIGHT FADES',
      xCenter: 660, yCenter: 392, scale: 1.2, core: _cyan, glow: false);

  return im;
}

/// arial 비트맵 폰트를 확대 합성해 큰 네온 텍스트를 그린다.
void _neonText(
  img.Image dst,
  String text, {
  required double xCenter,
  required double yCenter,
  required double scale,
  required List<int> core,
  bool glow = true,
}) {
  final font = img.arial48;
  // 텍스트 폭 추정(arial48 평균 자폭).
  final tmpW = (text.length * 30 + 20);
  final tmp = img.Image(width: tmpW, height: 60, numChannels: 4);
  img.drawString(tmp, text,
      font: font, x: 0, y: 4, color: img.ColorRgba8(255, 255, 255, 255));

  final scaled = img.copyResize(tmp,
      width: (tmpW * scale).round(),
      height: (60 * scale).round(),
      interpolation: img.Interpolation.cubic);

  final px = (xCenter - scaled.width / 2).round();
  final py = (yCenter - scaled.height / 2).round();

  if (glow) {
    // 글로우: 시안 틴트 + 블러를 가산 합성.
    final blurLayer = img.Image.from(scaled);
    for (final p in blurLayer) {
      final a = p.a / 255.0;
      p.setRgba(
          (_cyan[0] * a).toInt(), (_cyan[1] * a).toInt(),
          (_cyan[2] * a).toInt(), p.a.toInt());
    }
    img.gaussianBlur(blurLayer, radius: 6);
    _addComposite(dst, blurLayer, px, py, 1.2);
    _addComposite(dst, blurLayer, px, py, 1.0);
  }

  // 코어(또렷한 본문) 색 입혀 합성.
  final body = img.Image.from(scaled);
  for (final p in body) {
    final a = p.a / 255.0;
    p.setRgba((core[0] * a).toInt(), (core[1] * a).toInt(),
        (core[2] * a).toInt(), p.a.toInt());
  }
  _addComposite(dst, body, px, py, 1.0);
}

/// src를 dst에 (가산) 합성. amount로 세기 조절.
void _addComposite(img.Image dst, img.Image src, int ox, int oy, double amt) {
  for (var y = 0; y < src.height; y++) {
    final dy = oy + y;
    if (dy < 0 || dy >= dst.height) continue;
    for (var x = 0; x < src.width; x++) {
      final dx = ox + x;
      if (dx < 0 || dx >= dst.width) continue;
      final s = src.getPixel(x, y);
      final a = (s.a / 255.0) * amt;
      if (a <= 0) continue;
      final d = dst.getPixel(dx, dy);
      dst.setPixelRgba(
        dx,
        dy,
        (d.r + s.r * a).clamp(0, 255).toInt(),
        (d.g + s.g * a).clamp(0, 255).toInt(),
        (d.b + s.b * a).clamp(0, 255).toInt(),
        255,
      );
    }
  }
}
