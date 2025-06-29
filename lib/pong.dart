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

  void _restartGame() {
    setState(() {
      gameStarted = false;
      gameOver = false;
      score = 0;
      lives = 3;
    });
    _initializeGame();
  }

  void _loseLife() {
    lives--;
    if (lives <= 0) {
      gameOver = true;
    } else {
      _resetBall();
    }
  }

  void _updateScore() {
    score++;
    _resetBall();
  }

  void _resetBall() {
    // Position ball on top center of bottom paddle
    ballPosition = Offset(
      paddleBottomX + PADDLE_WIDTH / 2,
      GAME_SIZE.height - 60 - BALL_RADIUS - 2,
    );
    ballVelocity = const Offset(0, 0);
    gameStarted = false;
  }

  void _updateGame() {
    if (!gameStarted || gameOver) return;

    setState(() {
      // Update ball position
      // using velocity => s = v * t, where t = 1 / 60
      ballPosition = Offset(
        ballPosition.dx + ballVelocity.dx / 60,
        ballPosition.dy + ballVelocity.dy / 60,
      );

      // Ball collision with walls
      if (ballPosition.dx <= BALL_RADIUS ||
          ballPosition.dx >= GAME_SIZE.width - BALL_RADIUS) {
        ballVelocity = Offset(-ballVelocity.dx, ballVelocity.dy);
        ballPosition = Offset(
          ballPosition.dx <= BALL_RADIUS
              ? BALL_RADIUS
              : GAME_SIZE.width - BALL_RADIUS,
          ballPosition.dy,
        );
      }

      // Ball collision with bottom paddle
      double paddleY = GAME_SIZE.height - 60;
      if (ballPosition.dx >= paddleBottomX - BALL_RADIUS &&
          ballPosition.dx <= paddleBottomX + PADDLE_WIDTH + BALL_RADIUS &&
          ballPosition.dy >= paddleY - BALL_RADIUS &&
          ballPosition.dy <= paddleY + PADDLE_HEIGHT + BALL_RADIUS) {
        ballVelocity = Offset(ballVelocity.dx, -ballVelocity.dy.abs());

        // Add angle based on where ball hits paddle
        double difference =
            ballPosition.dx - (paddleBottomX + PADDLE_WIDTH / 2);
        ballVelocity = Offset(
          ballVelocity.dx + difference * 3,
          ballVelocity.dy,
        );
        // Limit velocity
        ballVelocity = Offset(
          ballVelocity.dx.clamp(-BALL_SPEED, BALL_SPEED),
          ballVelocity.dy,
        );
      }

      // Ball collision with top paddle
      paddleY = 60;
      if (ballPosition.dx >= paddleBottomX - BALL_RADIUS &&
          ballPosition.dx <= paddleBottomX + PADDLE_WIDTH + BALL_RADIUS &&
          ballPosition.dy >= paddleY - BALL_RADIUS &&
          ballPosition.dy <= paddleY + PADDLE_HEIGHT + BALL_RADIUS) {
        ballVelocity = Offset(ballVelocity.dx, ballVelocity.dy.abs());

        // Add angle based on where ball hits paddle
        double difference = ballPosition.dx - (paddleTopX + PADDLE_WIDTH / 2);
        ballVelocity = Offset(
          ballVelocity.dx + difference * 3,
          ballVelocity.dy,
        );
        // Limit velocity
        ballVelocity = Offset(
          ballVelocity.dx.clamp(-BALL_SPEED, BALL_SPEED),
          ballVelocity.dy,
        );
      }

      // Ball goes off bottom
      if (ballPosition.dy >= GAME_SIZE.height) {
        _loseLife();
      }

      // Ball goes off top
      if (ballPosition.dy <= 0) {
        _updateScore();
      }
    });
  }

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
