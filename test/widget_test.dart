import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FlappyApp());
}

class FlappyApp extends StatelessWidget {
  const FlappyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flappy Simple',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const GamePage(),
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  // Timing
  Timer? _timer;
  static const Duration tick = Duration(milliseconds: 16); // ~60 FPS

  // World size (assigned after layout)
  double worldW = 0;
  double worldH = 0; // total height including ground
  final double groundH = 110;

  // Bird
  final double birdSize = 38;
  double birdX = 80; // fixed x
  double birdY = 0; // dynamic y (top-left)
  double birdVel = 0; // pixels per tick
  final double gravity = 0.6; // pixels/tick^2
  final double flapImpulse = -9.5; // negative = up

  // Pipes
  final Random rnd = Random();
  final double pipeW = 72;
  final double pipeGapH = 170; // hole height
  final double pipeSpeed = 3.0; // px per tick
  final double pipeSpacing = 260; // distance between pipe columns
  late List<Pipe> pipes;

  // Game state
  bool started = false;
  bool gameOver = false;
  int score = 0;
  int best = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startGame() {
    if (started) return;
    setState(() {
      started = true;
      gameOver = false;
      score = 0;
      birdVel = 0;
    });

    _timer?.cancel();
    _timer = Timer.periodic(tick, (_) => _update());
  }

  void _resetGame() {
    setState(() {
      started = false;
      gameOver = false;
      birdVel = 0;
      // reset positions
      birdY = (worldH - groundH) / 2 - birdSize / 2;
      _setupPipes();
    });
  }

  void _setupPipes() {
    final usableH = worldH - groundH;
    pipes = List.generate(3, (i) {
      final x = worldW + 120 + i * pipeSpacing;
      final gapCenter = _randomGapCenter(usableH);
      return Pipe(x: x, gapCenterY: gapCenter);
    });
  }

  double _randomGapCenter(double usableH) {
    // Keep the gap away from edges
    final margin = 80.0;
    final minC = margin + pipeGapH / 2;
    final maxC = usableH - margin - pipeGapH / 2;
    return rnd.nextDouble() * (maxC - minC) + minC;
  }

  void _flap() {
    if (!started) {
      _startGame();
    }
    if (gameOver) return;
    setState(() => birdVel = flapImpulse);
  }

  void _update() {
    if (!mounted || gameOver) return;

    setState(() {
      // physics
      birdVel += gravity;
      birdY += birdVel;

      // move pipes
      for (final p in pipes) {
        p.x -= pipeSpeed;
      }

      // recycle pipes and scoring
      for (final p in pipes) {
        if (p.x + pipeW < 0) {
          p.x = pipes.map((e) => e.x).reduce(max) + pipeSpacing; // place after the farthest
          p.gapCenterY = _randomGapCenter(worldH - groundH);
          p.passed = false;
        }
        // count score when bird center passes pipe center
        final birdCenterX = birdX + birdSize / 2;
        if (!p.passed && p.x + pipeW < birdCenterX) {
          p.passed = true;
          score++;
          if (score > best) best = score;
        }
      }

      // Collisions
      final usableH = worldH - groundH;
      if (birdY < 0 || birdY + birdSize > usableH) {
        _gameOver();
        return;
      }
      for (final p in pipes) {
        if (_collidesWithPipe(p)) {
          _gameOver();
          return;
        }
      }
    });
  }

  bool _collidesWithPipe(Pipe p) {
    final birdRect = Rect.fromLTWH(birdX, birdY, birdSize, birdSize);

    final topRect = Rect.fromLTWH(
      p.x,
      0,
      pipeW,
      p.gapCenterY - pipeGapH / 2,
    );
    final bottomRect = Rect.fromLTWH(
      p.x,
      p.gapCenterY + pipeGapH / 2,
      pipeW,
      (worldH - groundH) - (p.gapCenterY + pipeGapH / 2),
    );

    return birdRect.overlaps(topRect) || birdRect.overlaps(bottomRect);
  }

  void _gameOver() {
    gameOver = true;
    started = false;
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, c) {
          // Assign world size once we know it
          if (worldW != c.maxWidth || worldH != c.maxHeight) {
            worldW = c.maxWidth;
            worldH = c.maxHeight;
            // init positions when entering page / resize
            if (!started && !gameOver) {
              birdY = (worldH - groundH) / 2 - birdSize / 2;
              _setupPipes();
            }
          }

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _flap,
            child: Stack(
              children: [
                // Background sky
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF74b9ff), Color(0xFFa0e9ff)],
                    ),
                  ),
                ),

                // Game world painter (pipes, ground, UI guides)
                CustomPaint(
                  painter: WorldPainter(
                    pipes: pipes,
                    pipeW: pipeW,
                    pipeGapH: pipeGapH,
                    groundH: groundH,
                  ),
                  child: const SizedBox.expand(),
                ),

                // Bird as a simple rounded box with slight rotation
                Positioned(
                  left: birdX,
                  top: birdY,
                  child: Transform.rotate(
                    angle: birdVel.clamp(-12, 12) / 40, // tilt based on velocity
                    child: Container(
                      width: birdSize,
                      height: birdSize,
                      decoration: BoxDecoration(
                        color: Colors.yellow.shade700,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [
                          BoxShadow(blurRadius: 6, offset: Offset(0, 3), color: Colors.black26),
                        ],
                        border: Border.all(color: Colors.orange, width: 2),
                      ),
                      child: CustomPaint(
                        painter: _BirdEyePainter(),
                      ),
                    ),
                  ),
                ),

                // HUD: score top-center
                Positioned(
                  top: 30,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Text(
                        '$score',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          shadows: [Shadow(blurRadius: 8, color: Colors.black45, offset: Offset(0, 2))],
                        ),
                      ),
                      if (best > 0)
                        Text(
                          'Best: $best',
                          style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                ),

                // Start/Game Over overlay
                if (!started)
                  Positioned.fill(
                    child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: gameOver ? () {} : null, child: Container(
                        color: gameOver ? Colors.black38 : Colors.transparent,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              gameOver ? 'Game Over' : 'Tap to Start',
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                shadows: [Shadow(blurRadius: 10, color: Colors.black54)],
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (gameOver)
                              FilledButton(
                                onPressed: _resetGame,
                                child: const Text('Restart'),
                              )
                            else
                              const Text(
                                'Tap layar untuk terbang',
                                style: TextStyle(color: Colors.white70),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class Pipe {
  Pipe({required this.x, required this.gapCenterY});
  double x; // left
  double gapCenterY; // center of gap
  bool passed = false; // for scoring
}

class WorldPainter extends CustomPainter {
  WorldPainter({required this.pipes, required this.pipeW, required this.pipeGapH, required this.groundH});

  final List<Pipe> pipes;
  final double pipeW;
  final double pipeGapH;
  final double groundH;

  @override
  void paint(Canvas canvas, Size size) {
    final usableH = size.height - groundH;

    // Draw pipes
    final paintPipe = Paint()..color = const Color(0xFF2ecc71);
    final paintLip = Paint()..color = const Color(0xFF27ae60);

    for (final p in pipes) {
      // top
      final topRect = Rect.fromLTWH(p.x, 0, pipeW, p.gapCenterY - pipeGapH / 2);
      // bottom
      final bottomRect = Rect.fromLTWH(
        p.x,
        p.gapCenterY + pipeGapH / 2,
        pipeW,
        usableH - (p.gapCenterY + pipeGapH / 2),
      );
      canvas.drawRect(topRect, paintPipe);
      canvas.drawRect(bottomRect, paintPipe);

      // lips for visual
      canvas.drawRect(Rect.fromLTWH(topRect.left - 2, topRect.bottom - 12, pipeW + 4, 12), paintLip);
      canvas.drawRect(Rect.fromLTWH(bottomRect.left - 2, bottomRect.top, pipeW + 4, 12), paintLip);
    }

    // Ground
    final groundRect = Rect.fromLTWH(0, usableH, size.width, groundH);
    final groundPaint = Paint()..color = const Color(0xFF8d6e63);
    canvas.drawRect(groundRect, groundPaint);

    // Grass
    final grassPaint = Paint()..color = const Color(0xFF4caf50);
    canvas.drawRect(Rect.fromLTWH(0, usableH, size.width, 14), grassPaint);
  }

  @override
  bool shouldRepaint(covariant WorldPainter oldDelegate) {
    return true;
  }
}

class _BirdEyePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final eye = Paint()..color = Colors.white;
    final pupil = Paint()..color = Colors.black87;

    final eyeCenter = Offset(size.width * 0.70, size.height * 0.35);
    canvas.drawCircle(eyeCenter, size.shortestSide * 0.12, eye);
    canvas.drawCircle(eyeCenter.translate(0, 0), size.shortestSide * 0.06, pupil);

    // Beak
    final beak = Paint()..color = Colors.orangeAccent;
    final path = Path()
      ..moveTo(size.width * 0.95, size.height * 0.50)
      ..lineTo(size.width * 1.10, size.height * 0.60)
      ..lineTo(size.width * 0.95, size.height * 0.70)
      ..close();
    canvas.drawPath(path, beak);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
