import 'package:flutter/material.dart';
import 'globals.dart';

class PongPainter extends CustomPainter {
  final Offset ballPosition;
  final double bottomPaddleX;
  final double topPaddleX;
  final Size gameSize;

  PongPainter({
    required this.ballPosition,
    required this.bottomPaddleX,
    required this.topPaddleX,
    required this.gameSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final ballPaint = Paint()..color = BALL_PAINT;
    final paddlePaint = Paint()..color = PADDLE_PAINT;
    final paint = Paint()
      ..color = LINE_PAINT
      ..strokeWidth = LINE_WIDTH;

    // Draw dashed middle line
    double dashWidth = gameSize.width / 41;
    double dashSpace = dashWidth;
    double startX = 0;
    double middleY = (gameSize.height - LINE_WIDTH) / 2;
    while (startX < gameSize.width) {
      canvas.drawLine(
        Offset(startX, middleY),
        Offset(startX + dashWidth, middleY),
        paint,
      );
      startX += dashWidth + dashSpace;
    }

    // Draw ball
    canvas.drawCircle(ballPosition, BALL_RADIUS, ballPaint);

    // Draw bottom paddle
    final bottomPaddleRect = Rect.fromLTWH(
      bottomPaddleX,
      gameSize.height - 60,
      PADDLE_WIDTH,
      PADDLE_HEIGHT,
    );
    canvas.drawRect(bottomPaddleRect, paddlePaint);

    // Draw top paddle
    final topPaddleRect = Rect.fromLTWH(
      topPaddleX,
      60,
      PADDLE_WIDTH,
      PADDLE_HEIGHT,
    );
    canvas.drawRect(topPaddleRect, paddlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
