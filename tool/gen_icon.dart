// VOID SPARK — 앱 아이콘 생성기.
// 외부 에셋 없이 네온 '스파크(빛 입자)' 아이콘을 코드로 그려 PNG로 출력한다.
// 실행: dart run tool/gen_icon.dart   (이후 dart run flutter_launcher_icons)
import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

const int size = 1024;

void main() {
  Directory('assets/icon').createSync(recursive: true);

  // 앱 아이콘(불투명 배경) + 적응형 전경(투명, 중앙 62% 안에 배치).
  File('assets/icon/icon.png')
      .writeAsBytesSync(img.encodePng(_draw(scale: 1.0, withBackground: true)));
  File('assets/icon/icon_foreground.png').writeAsBytesSync(
      img.encodePng(_draw(scale: 0.62, withBackground: false)));

  stdout.writeln('Generated icon.png + icon_foreground.png into assets/icon/');
}

// 색.
const _voidDeep = [5, 6, 14];
const _voidMid = [11, 14, 31];
const _cyan = [33, 230, 255];
const _white = [255, 255, 255];
const _mag = [255, 46, 99];

double _gauss(double d, double sigma) =>
    math.exp(-(d * d) / (2 * sigma * sigma));

img.Image _draw({required double scale, required bool withBackground}) {
  final im = img.Image(width: size, height: size, numChannels: 4);
  const cx = size / 2;
  const cy = size / 2;

  // 스케일에 비례하는 파라미터.
  final coreR = 60.0 * scale;
  final glowSigma = 230.0 * scale;
  final ringR = 158.0 * scale;
  final ringSigma = 10.0 * scale;
  final beamSigma = 7.0 * scale;
  final beamLen = 360.0 * scale;
  final dotOrbit = 300.0 * scale;
  final dotGlow = 30.0 * scale;
  final dotR = 16.0 * scale;

  // 자석 점(코어 주위 마젠타) 위치.
  final dots = <List<double>>[];
  for (final deg in [35.0, 155.0, 275.0]) {
    final a = deg * math.pi / 180;
    dots.add([cx + math.cos(a) * dotOrbit, cy + math.sin(a) * dotOrbit]);
  }

  for (var y = 0; y < size; y++) {
    for (var x = 0; x < size; x++) {
      final dx = x - cx;
      final dy = y - cy;
      final r = math.sqrt(dx * dx + dy * dy);

      // ---- 발광 성분(가산) ----
      final glow = 0.55 * _gauss(r, glowSigma); // 넓은 코어 글로우
      final core = math.pow(_gauss(r, coreR * 0.9), 1.0).toDouble(); // 코어 본체
      final ring = 0.85 * _gauss(r - ringR, ringSigma); // 링

      // 4방향 스파크 빔.
      final beamH = _gauss(dy, beamSigma) * math.max(0, 1 - dx.abs() / beamLen);
      final beamV = _gauss(dx, beamSigma) * math.max(0, 1 - dy.abs() / beamLen);
      final beam = 0.9 * math.max(beamH, beamV);

      // 마젠타 점(글로우 + 코어).
      var dotGlowAmt = 0.0;
      var dotCoreAmt = 0.0;
      for (final d in dots) {
        final dd = math.sqrt(math.pow(x - d[0], 2) + math.pow(y - d[1], 2));
        dotGlowAmt += 0.8 * _gauss(dd.toDouble(), dotGlow);
        if (dd < dotR) dotCoreAmt = 1.0;
      }

      final cyanAmt = (glow * 0.7 + ring + beam).clamp(0.0, 2.0);
      final whiteAmt = core.clamp(0.0, 1.0);
      final magAmt = (dotGlowAmt + dotCoreAmt).clamp(0.0, 1.5);

      var lr = _cyan[0] * cyanAmt + _white[0] * whiteAmt + _mag[0] * magAmt;
      var lg = _cyan[1] * cyanAmt + _white[1] * whiteAmt + _mag[1] * magAmt;
      var lb = _cyan[2] * cyanAmt + _white[2] * whiteAmt + _mag[2] * magAmt;

      int rr, gg, bb, aa;
      if (withBackground) {
        // 세로 그라데이션 배경 위에 가산.
        final t = y / size;
        final bgR = _voidMid[0] + (_voidDeep[0] - _voidMid[0]) * t;
        final bgG = _voidMid[1] + (_voidDeep[1] - _voidMid[1]) * t;
        final bgB = _voidMid[2] + (_voidDeep[2] - _voidMid[2]) * t;
        rr = (bgR + lr).clamp(0, 255).toInt();
        gg = (bgG + lg).clamp(0, 255).toInt();
        bb = (bgB + lb).clamp(0, 255).toInt();
        aa = 255;
      } else {
        // 전경: 빛의 세기를 알파로.
        final intensity =
            (cyanAmt * 0.85 + whiteAmt + magAmt).clamp(0.0, 1.0);
        rr = lr.clamp(0, 255).toInt();
        gg = lg.clamp(0, 255).toInt();
        bb = lb.clamp(0, 255).toInt();
        aa = (intensity * 255).clamp(0, 255).toInt();
      }
      im.setPixelRgba(x, y, rr, gg, bb, aa);
    }
  }
  return im;
}
