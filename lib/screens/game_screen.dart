import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../systems/save.dart';
import '../void_spark_game.dart';
import 'controls_overlay.dart';
import 'game_over_overlay.dart';
import 'levelup_overlay.dart';
import 'pause_overlay.dart';
import 'tutorial_overlay.dart';
import 'victory_overlay.dart';

/// 실제 플레이 화면 — GameWidget을 호스팅한다.
/// 게임오버에서 '메인'을 누르면 이 화면을 pop 해 메뉴로 돌아간다.
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final VoidSparkGame _game;
  late final List<String> _initialOverlays;

  @override
  void initState() {
    super.initState();
    _game = VoidSparkGame();
    // 첫 플레이라면 튜토리얼을 처음부터 띄운다.
    _initialOverlays = [
      VoidSparkGame.controlsOverlay,
      if (!SaveSystem.instance.tutorialSeen) VoidSparkGame.tutorialOverlay,
    ];
  }

  @override
  Widget build(BuildContext context) {
    // canPop:false → iOS 가장자리 스와이프·시스템 뒤로가기를 막는다(게임 조작과
    // 충돌 방지). 메뉴로 나가는 건 일시정지/게임오버 오버레이의 명시적 pop으로만.
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF05060E),
        body: GameWidget<VoidSparkGame>(
          game: _game,
          initialActiveOverlays: _initialOverlays,
          overlayBuilderMap: {
            VoidSparkGame.controlsOverlay: (context, game) =>
                ControlsOverlay(game: game),
            VoidSparkGame.tutorialOverlay: (context, game) =>
                TutorialOverlay(game: game),
            VoidSparkGame.pauseOverlay: (context, game) => PauseOverlay(
                  game: game,
                  onMenu: () => Navigator.of(context).pop(),
                ),
            VoidSparkGame.victoryOverlay: (context, game) => VictoryOverlay(
                  game: game,
                  onMenu: () => Navigator.of(context).pop(),
                ),
            VoidSparkGame.levelUpOverlay: (context, game) =>
                LevelUpOverlay(game: game),
            VoidSparkGame.gameOverOverlay: (context, game) => GameOverOverlay(
                  game: game,
                  onMenu: () => Navigator.of(context).pop(),
                ),
          },
        ),
      ),
    );
  }
}
