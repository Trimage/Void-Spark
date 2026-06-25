import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'config/game_config.dart';
import 'config/palette.dart';
import 'screens/menu_screen.dart';
import 'systems/iap/iap.dart';
import 'systems/leaderboard/leaderboard.dart';
import 'systems/save.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 세로 모드 고정.
  await Flame.device.setPortrait();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 로컬 저장 로드(기록/재화/해금/일일도전).
  await SaveSystem.instance.load();

  // 인앱결제 초기화(구매 스트림 구독 + 권한 복원). 웹/미지원은 무동작.
  // 첫 출시는 IAP 비활성(GameConfig.iapEnabled=false) — 초기화 건너뜀.
  if (GameConfig.iapEnabled) {
    await iap.init();
  }

  // 글로벌 리더보드 로그인 시도(웹/미지원은 무동작).
  await leaderboard.init();

  runApp(const VoidSparkApp());
}

class VoidSparkApp extends StatelessWidget {
  const VoidSparkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VOID SPARK',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Palette.voidDeep,
        useMaterial3: true,
      ),
      home: const MenuScreen(),
    );
  }
}
