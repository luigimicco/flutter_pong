import 'package:flutter/material.dart';
import 'dart:math';
import 'globals.dart';
import 'logic.dart';
import 'painter.dart';
import 'package:google_fonts/google_fonts.dart';

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
  int lives = MAX_LIVES;

  // Google font for retro effect
  late Future googleFontsPending;

  @override
  void initState() {
    super.initState();
    googleFontsPending = GoogleFonts.pendingFonts([GoogleFonts.pressStart2p]);

    _gameController = AnimationController(
      duration: Duration(milliseconds: (1000 / GAME_FPS).toInt()),
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
      lives = MAX_LIVES;
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

  void _startGame() {
    if (!gameStarted && !gameOver) {
      setState(() {
        gameStarted = true;
        ballVelocity = Offset(
          (Random().nextBool() ? 1 : -1) * BALL_SPEED * 0.5,
          -BALL_SPEED,
        );
      });
    }
  }

  void _updateGame() {
    if ((!gameStarted || gameOver) &&
        MediaQuery.of(context).size != GAME_SIZE) {
      GAME_SIZE = MediaQuery.of(context).size;
      paddleBottomX = GAME_SIZE.width / 2 - PADDLE_WIDTH / 2;
      paddleTopX = GAME_SIZE.width / 2 - PADDLE_WIDTH / 2;

      ballPosition = Offset(
        paddleBottomX + PADDLE_WIDTH / 2,
        GAME_SIZE.height - 60 - BALL_RADIUS - 2,
      );
    }

    if (!gameStarted || gameOver) return;

    setState(() {
      // Update ball position
      // using velocity => s = v * t, where t = 1 / 60
      ballPosition = Offset(
        ballPosition.dx + ballVelocity.dx / GAME_FPS,
        ballPosition.dy + ballVelocity.dy / GAME_FPS,
      );

      if (checkWallCollision(ballPosition, GAME_SIZE)) {
        // Ball collision with walls
        ballVelocity = Offset(-ballVelocity.dx, ballVelocity.dy);
        ballPosition = Offset(
          ballPosition.dx <= BALL_RADIUS
              ? BALL_RADIUS
              : GAME_SIZE.width - BALL_RADIUS,
          ballPosition.dy,
        );
      } else if (checkBottomPaddleCollision(paddleBottomX, ballPosition)) {
        // Ball collision with bottom paddle
        ballVelocity = Offset(ballVelocity.dx, -ballVelocity.dy.abs());

        // Add angle based on where ball hits paddle
        double difference =
            ballPosition.dx - (paddleBottomX + PADDLE_WIDTH / 2);
        ballVelocity = updateVelocity(ballVelocity, difference);

        // Limit velocity
        ballVelocity = limitVelocity(ballVelocity);
      } else if (checkTopPaddleCollision(paddleTopX, ballPosition)) {
        // Ball collision with top paddle
        ballVelocity = Offset(ballVelocity.dx, ballVelocity.dy.abs());

        // Add angle based on where ball hits paddle
        double difference = ballPosition.dx - (paddleTopX + PADDLE_WIDTH / 2);

        ballVelocity = updateVelocity(ballVelocity, difference);

        // Limit velocity
        ballVelocity = limitVelocity(ballVelocity);
      } else if (ballPosition.dy >= GAME_SIZE.height) {
        // Ball goes off bottom
        _loseLife();
      } else if (ballPosition.dy <= 0) {
        // Ball goes off top
        _updateScore();
      }

      // update top paddle
      paddleTopX = newPaddlePosition(paddleTopX, ballPosition);
    });
  }

  void _movePaddle(Offset tapPosition) {
    setState(() {
      paddleBottomX = (tapPosition.dx - PADDLE_WIDTH / 2).clamp(
        0,
        GAME_SIZE.width - PADDLE_WIDTH,
      );

      // If game hasn't started, move ball with paddle
      if (!gameStarted) {
        ballPosition = Offset(
          paddleBottomX + PADDLE_WIDTH / 2,
          GAME_SIZE.height - 60 - BALL_RADIUS - 2,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final retroFontStyleNormal = GoogleFonts.pressStart2p(
      textStyle: Theme.of(context).textTheme.titleMedium,
    );
    final retroFontStyleGameOver = GoogleFonts.pressStart2p(
      color: Colors.red,
      textStyle: Theme.of(context).textTheme.headlineLarge,
    );

    return Scaffold(
      backgroundColor: Color(0xFF222222),
      body: SafeArea(
        child: GestureDetector(
          onTapDown: (details) {
            if (!gameStarted && !gameOver) {
              _startGame();
            } else if (!gameOver) {
              _movePaddle(details.localPosition);
            }
          },
          onPanUpdate: (details) {
            if (!gameOver) {
              _movePaddle(details.localPosition);
            }
          },
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
              livesAndScoreWidget(retroFontStyleNormal),

              // Instructions/Game Over overlay
              if (!gameStarted && !gameOver)
                infoStarWidget(retroFontStyleNormal),

              // Game Over
              if (gameOver)
                gameOverWidget(retroFontStyleGameOver, retroFontStyleNormal),
            ],
          ),
        ),
      ),
    );
  }

  Positioned livesAndScoreWidget(TextStyle retroFontStyleNormal) {
    return Positioned(
      top: 20,
      left: 20,
      right: 20,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Lives: ${'●' * lives}', style: retroFontStyleNormal),
          const Spacer(),
          Text('Score: $score', style: retroFontStyleNormal),
        ],
      ),
    );
  }

  Center infoStarWidget(TextStyle retroFontStyleNormal) {
    return Center(
      child: Text(
        'Tap to start game!\n\nDrag to move paddle',
        textAlign: TextAlign.center,
        style: retroFontStyleNormal,
      ),
    );
  }

  Center gameOverWidget(
    TextStyle retroFontStyleGameOver,
    TextStyle retroFontStyleNormal,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Game Over!', style: retroFontStyleGameOver),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _restartGame,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
            child: Text('Restart Game', style: retroFontStyleNormal),
          ),
        ],
      ),
    );
  }
}
