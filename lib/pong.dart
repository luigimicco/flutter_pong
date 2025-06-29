import 'package:flutter/material.dart';

import 'globals.dart';
import 'painter.dart';

class PongGame extends StatefulWidget {
  const PongGame({super.key});

  @override
  State<PongGame> createState() => _PongGameState();
}

class _PongGameState extends State<PongGame> with TickerProviderStateMixin {
  late AnimationController _gameController;

  Offset ballVelocity = const Offset(0, 0);
  Offset ballPosition = const Offset(0, 0);

  double paddleBottomX = 0;
  double paddleTopX = 0;

  // Game state
  bool gameStarted = false;
  bool gameOver = false;
  int score = 0;
  int lives = 3;

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
              CustomPaint(
                size: Size.infinite,
                painter: PongPainter(
                  ballPosition: ballPosition,
                  bottomPaddleX: paddleBottomX,
                  topPaddleX: paddleTopX,
                  gameSize: GAME_SIZE,
                ),
              ),

              // UI overlay
              Positioned(
                top: 20,
                left: 20,
                right: 20,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Lives: ${'●' * lives}'),
                    const Spacer(),
                    Text('Score: $score'),
                  ],
                ),
              ),

              // Instructions/Game Over overlay
              if (!gameStarted && !gameOver)
                Center(
                  child: Text(
                    'Tap to start game!\n\nDrag to move paddle',
                    textAlign: TextAlign.center,
                  ),
                ),

              // Game Over
              if (gameOver)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Game Over!'),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _restartGame,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                        ),
                        child: Text('Restart Game'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
