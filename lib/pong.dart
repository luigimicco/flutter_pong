import 'package:flutter/material.dart';

import 'globals.dart';

class PongGame extends StatefulWidget {
  const PongGame({super.key});

  @override
  State<PongGame> createState() => _PongGameState();
}

class _PongGameState extends State<PongGame> with TickerProviderStateMixin {
  late AnimationController _gameController;

  Offset ballVelocity = const Offset(0, 0);
  Offset ballPosition = const Offset(0, 0);

  @override
  void initState() {
    super.initState();

    _gameController = AnimationController(
      duration: Duration(milliseconds: (1 / 60).toInt()),
      vsync: this,
    )..addListener(_updateGame);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _initializeGame();
      });
      _startGameLoop();
    });
  }

  @override
  void dispose() {
    _gameController.dispose();
    super.dispose();
  }

  void _startGameLoop() {
    _gameController.repeat();
  }

  void _initializeGame() {
    GAME_SIZE = const Size(0, 0);
    ballVelocity = const Offset(0, 0);
  }

  void _updateGame() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GestureDetector(
          onTapDown: (details) {},
          onPanUpdate: (details) {},
          child: Stack(
            children: [
              // Game canvas
            ],
          ),
        ),
      ),
    );
  }
}
