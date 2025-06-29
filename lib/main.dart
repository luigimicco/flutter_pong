import 'package:flutter/material.dart';

import 'pong.dart';

void main() {
  runApp(const PongApp());
}

class PongApp extends StatelessWidget {
  const PongApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pong Game',
      theme: ThemeData.dark(),
      home: const PongGame(),
      debugShowCheckedModeBanner: false,
    );
  }
}
