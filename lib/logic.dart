import 'dart:math';
import 'dart:ui';
import 'globals.dart';

// update top paddle positin
double newPaddlePosition(double currentXPosition, Offset ballPosition) {
  double newPosition = currentXPosition;

  if (ballPosition.dy < TARGET_TRESHOLD * GAME_SIZE.height) {
    int space = (2 * BALL_SPEED / GAME_FPS).toInt();
    int rnd = Random().nextInt(space);

    if (ballPosition.dx < currentXPosition) {
      newPosition = currentXPosition - rnd;
    } else if (ballPosition.dx > (currentXPosition + PADDLE_WIDTH)) {
      newPosition = currentXPosition + rnd;
    }
  }

  return newPosition;
}

// check bottom paddle collision
bool checkBottomPaddleCollision(double currentXPosition, Offset ballPosition) {
  double paddleY = GAME_SIZE.height - 60;
  return ballPosition.dx >= currentXPosition - BALL_RADIUS &&
      ballPosition.dx <= currentXPosition + PADDLE_WIDTH + BALL_RADIUS &&
      ballPosition.dy >= paddleY - BALL_RADIUS &&
      ballPosition.dy <= paddleY + PADDLE_HEIGHT + BALL_RADIUS;
}

// check top paddle collision
bool checkTopPaddleCollision(double currentXPosition, Offset ballPosition) {
  double paddleY = 60;
  return ballPosition.dx >= currentXPosition - BALL_RADIUS &&
      ballPosition.dx <= currentXPosition + PADDLE_WIDTH + BALL_RADIUS &&
      ballPosition.dy >= paddleY - BALL_RADIUS &&
      ballPosition.dy <= paddleY + PADDLE_HEIGHT + BALL_RADIUS;
}

// check wall collisions
bool checkWallCollision(Offset ballPosition, Size gameSize) {
  return ballPosition.dx <= BALL_RADIUS ||
      ballPosition.dx >= gameSize.width - BALL_RADIUS;
}

Offset updateVelocity(Offset ballVelocity, double difference) {
  return Offset(ballVelocity.dx + difference * 3, ballVelocity.dy);
}

Offset limitVelocity(Offset ballVelocity) {
  return Offset(
    ballVelocity.dx.clamp(-BALL_SPEED, BALL_SPEED),
    ballVelocity.dy,
  );
}
