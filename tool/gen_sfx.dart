// VOID SPARK — 합성 SFX 생성기.
// 외부 에셋 없이 코드로 16-bit PCM WAV 효과음을 만들어 assets/audio/ 에 쓴다.
// 실행: dart run tool/gen_sfx.dart
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

const int sampleRate = 44100;

void main() {
  final dir = Directory('assets/audio');
  dir.createSync(recursive: true);

  _write('shoot.wav', _shoot());
  _write('kill.wav', _kill());
  _write('collect.wav', _collect());
  _write('hit.wav', _hit());
  _write('powerup.wav', _powerup());
  _write('gameover.wav', _gameover());
  _write('boss.wav', _boss());
  _write('bomb.wav', _bomb());
  _write('bgm.wav', _bgm());

  stdout.writeln('Generated 8 SFX + BGM into assets/audio/');
}

// ---- 합성 헬퍼 ----

double _sine(double freq, double t) => math.sin(2 * math.pi * freq * t);

double _square(double freq, double t) => _sine(freq, t) >= 0 ? 1.0 : -1.0;

final math.Random _rng = math.Random(42);
double _noise() => _rng.nextDouble() * 2 - 1;

/// 지수 감쇠 엔벨로프.
double _decay(double t, double dur, {double k = 5.0}) =>
    math.exp(-k * t / dur);

List<double> _buffer(double dur) => List<double>.filled(
      (dur * sampleRate).round(),
      0.0,
    );

// ---- 개별 SFX ----

List<double> _shoot() {
  const dur = 0.08;
  final b = _buffer(dur);
  for (var i = 0; i < b.length; i++) {
    final t = i / sampleRate;
    final f = 900 - 4000 * t; // 빠른 하강.
    b[i] = _square(f.abs(), t) * 0.3 * _decay(t, dur, k: 7);
  }
  return b;
}

List<double> _kill() {
  const dur = 0.2;
  final b = _buffer(dur);
  for (var i = 0; i < b.length; i++) {
    final t = i / sampleRate;
    final f = 500 - 1200 * t;
    final tone = _sine(f.abs(), t) * 0.5;
    final n = _noise() * 0.4 * _decay(t, dur, k: 9);
    b[i] = (tone + n) * _decay(t, dur, k: 5);
  }
  return b;
}

List<double> _collect() {
  const dur = 0.12;
  final b = _buffer(dur);
  for (var i = 0; i < b.length; i++) {
    final t = i / sampleRate;
    final f = 620 + 1400 * t; // 상승.
    b[i] = _sine(f, t) * 0.4 * _decay(t, dur, k: 4);
  }
  return b;
}

List<double> _hit() {
  const dur = 0.32;
  final b = _buffer(dur);
  for (var i = 0; i < b.length; i++) {
    final t = i / sampleRate;
    final thud = _sine(90 - 60 * t, t) * 0.6;
    final n = _noise() * 0.5 * _decay(t, dur, k: 14);
    b[i] = (thud + n) * _decay(t, dur, k: 4);
  }
  return b;
}

List<double> _powerup() {
  const dur = 0.28;
  final b = _buffer(dur);
  // 상승 아르페지오.
  const notes = [523.25, 659.25, 783.99, 1046.5];
  final seg = dur / notes.length;
  for (var i = 0; i < b.length; i++) {
    final t = i / sampleRate;
    final idx = (t / seg).floor().clamp(0, notes.length - 1);
    final lt = t - idx * seg;
    b[i] = _sine(notes[idx], t) * 0.4 * _decay(lt, seg, k: 3);
  }
  return b;
}

List<double> _gameover() {
  const dur = 0.7;
  final b = _buffer(dur);
  for (var i = 0; i < b.length; i++) {
    final t = i / sampleRate;
    final f = 440 - 380 * (t / dur); // 느린 하강.
    final tone = _sine(f, t) * 0.4;
    final sub = _sine(f / 2, t) * 0.25;
    b[i] = (tone + sub) * _decay(t, dur, k: 2.2);
  }
  return b;
}

List<double> _boss() {
  const dur = 0.6;
  final b = _buffer(dur);
  for (var i = 0; i < b.length; i++) {
    final t = i / sampleRate;
    final rumble = _sine(60 + 30 * math.sin(t * 18), t) * 0.5;
    final sweep = _sine(120 + 300 * t, t) * 0.3;
    final n = _noise() * 0.15;
    b[i] = (rumble + sweep + n) * _decay(t, dur, k: 1.8);
  }
  return b;
}

List<double> _bomb() {
  const dur = 0.45;
  final b = _buffer(dur);
  for (var i = 0; i < b.length; i++) {
    final t = i / sampleRate;
    final boom = _sine(140 - 110 * (t / dur), t) * 0.6;
    final n = _noise() * 0.6 * _decay(t, dur, k: 6);
    b[i] = (boom + n) * _decay(t, dur, k: 3);
  }
  return b;
}

/// 루프형 배경음(BGM) — 어두운 신스웨이브풍 8초 루프.
/// 4코드 진행 위에 아르페지오 + 서브베이스 + 패드 + 소프트 햇.
List<double> _bgm() {
  const dur = 8.0;
  final b = _buffer(dur);
  final n = b.length;

  // 코드 진행(Am - F - C - G) 저음 주파수(Hz).
  const chords = <List<double>>[
    [110.00, 130.81, 164.81], // Am
    [87.31, 110.00, 130.81], // F
    [130.81, 164.81, 196.00], // C
    [98.00, 123.47, 146.83], // G
  ];
  const chordDur = dur / 4; // 코드당 2초
  const stepDur = chordDur / 8; // 8분할 아르페지오

  for (var i = 0; i < n; i++) {
    final t = i / sampleRate;
    final ci = (t / chordDur).floor() % chords.length;
    final chord = chords[ci];
    final lt = t - (t / chordDur).floor() * chordDur;

    // 아르페지오(한 옥타브 위, 플럭 엔벨로프).
    final step = (lt / stepDur).floor();
    final note = chord[step % chord.length] * 2;
    final arpLocal = lt - step * stepDur;
    final arp = _sine(note, t) * 0.22 * _decay(arpLocal, stepDur, k: 5);

    // 서브 베이스(루트, 느린 트레몰로).
    final bass = _sine(chord[0], t) * 0.26 * (0.6 + 0.4 * _sine(0.5, t));

    // 패드(코드 지속음, 약하게).
    var pad = 0.0;
    for (final f in chord) {
      pad += _sine(f, t);
    }
    pad *= 0.05;

    // 소프트 햇(8분음마다).
    final hatPhase = lt % stepDur;
    final hat = _noise() * 0.05 * _decay(hatPhase, stepDur / 2, k: 30);

    b[i] = (arp + bass + pad + hat) * 0.7;
  }
  return b;
}

// ---- WAV 출력(16-bit PCM mono) ----

void _write(String name, List<double> samples) {
  final data = ByteData(samples.length * 2);
  for (var i = 0; i < samples.length; i++) {
    final v = (samples[i].clamp(-1.0, 1.0) * 32767).round();
    data.setInt16(i * 2, v, Endian.little);
  }
  final pcm = data.buffer.asUint8List();

  final header = BytesBuilder();
  void str(String s) => header.add(s.codeUnits);
  void u32(int v) {
    final b = ByteData(4)..setUint32(0, v, Endian.little);
    header.add(b.buffer.asUint8List());
  }

  void u16(int v) {
    final b = ByteData(2)..setUint16(0, v, Endian.little);
    header.add(b.buffer.asUint8List());
  }

  final dataLen = pcm.length;
  str('RIFF');
  u32(36 + dataLen);
  str('WAVE');
  str('fmt ');
  u32(16); // PCM chunk size
  u16(1); // PCM format
  u16(1); // mono
  u32(sampleRate);
  u32(sampleRate * 2); // byte rate
  u16(2); // block align
  u16(16); // bits per sample
  str('data');
  u32(dataLen);

  final out = BytesBuilder()
    ..add(header.toBytes())
    ..add(pcm);
  File('assets/audio/$name').writeAsBytesSync(out.toBytes());
}
