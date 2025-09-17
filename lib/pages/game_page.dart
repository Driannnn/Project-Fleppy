import 'dart:async';
import 'dart:math';
import 'dart:ui'; // ⬅️ untuk ImageFilter.blur
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/pipe.dart';
import '../paint/world_painter.dart';
import '../models/game_config.dart';
import 'main_menu_page.dart';

class GamePage extends StatefulWidget {
  final GameConfig? config;

  const GamePage({super.key, this.config});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  // Timing
  Timer? _timer;
  static const Duration tick = Duration(milliseconds: 16); // ~60 FPS

  // World size
  double worldW = 0;
  double worldH = 0;
  final double groundH = 110;

  // Bird
  final double birdSize = 38;
  double birdX = 80;
  double birdY = 0;
  double birdVel = 0;
  final double gravity = 0.6;
  final double flapImpulse = -9.5;

  // Pipes
  final Random rnd = Random();
  final double pipeW = 72;
  late double pipeGapH;
  late double pipeSpeed;
  final double pipeSpacing = 260;
  late List<Pipe> pipes;

  // State
  bool started = false;
  bool gameOver = false;
  bool paused = false;
  int score = 0;
  int best = 0;

  @override
  void initState() {
    super.initState();
    // default
    pipeGapH = 170;
    pipeSpeed = 3.0;

    // override dari config jika ada
    if (widget.config != null) {
      pipeGapH = widget.config!.pipeGapH;
      pipeSpeed = widget.config!.pipeSpeed;
    }
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
      paused = false;
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
      paused = false;
      birdVel = 0;
      birdY = (worldH - groundH) / 2 - birdSize / 2;
      _setupPipes();
    });
  }

  void _pauseGame() {
    if (!started || gameOver || paused) return;
    setState(() => paused = true);
    _timer?.cancel();
  }

  void _resumeGame() {
    if (!started || gameOver || !paused) return;
    setState(() => paused = false);
    _timer?.cancel();
    _timer = Timer.periodic(tick, (_) => _update());
  }

  void _openPauseOverlay() {
    _pauseGame();
    // overlay akan ditampilkan oleh Stack (lihat bagian "Overlay PAUSED")
  }

  void _goMainMenu() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const MainMenuPage()));
  }

  void _setupPipes() {
    final usableH = worldH - groundH;
    pipes = List.generate(3, (i) {
      final x = worldW + 60 + i * pipeSpacing;
      final gapCenter = _randomGapCenter(usableH);
      return Pipe(x: x, gapCenterY: gapCenter);
    });
  }

  double _randomGapCenter(double usableH) {
    const margin = 80.0;
    final minC = margin + pipeGapH / 2;
    final maxC = usableH - margin - pipeGapH / 2;
    return rnd.nextDouble() * (maxC - minC) + minC;
  }

  void _flap() {
    if (!started) {
      _startGame();
    }
    if (gameOver || paused) return;
    setState(() => birdVel = flapImpulse);
  }

  void _update() {
    if (!mounted || gameOver || paused) return;

    setState(() {
      // physics
      birdVel += gravity;
      birdY += birdVel;

      // move pipes
      for (final p in pipes) {
        p.x -= pipeSpeed;
      }

      // recycle & score
      for (final p in pipes) {
        if (p.x + pipeW < 0) {
          p.x = pipes.map((e) => e.x).reduce(max) + pipeSpacing;
          p.gapCenterY = _randomGapCenter(worldH - groundH);
          p.passed = false;
        }
        final birdCenterX = birdX + birdSize / 2;
        if (!p.passed && p.x + pipeW < birdCenterX) {
          p.passed = true;
          score++;
          if (score > best) best = score;
        }
      }

      // collisions
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
    final topRect = Rect.fromLTWH(p.x, 0, pipeW, p.gapCenterY - pipeGapH / 2);
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
    paused = false;
    _timer?.cancel();
  }

  // ====== Panel PAUSE mengambang: Liquid Glass ======
  Widget _pauseGlassPanel() {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            width: 320,
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white30, width: 1.4),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 18,
                  color: Colors.black26,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // header kecil
                Container(
                  width: 42,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const Text(
                  'Paused',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    shadows: [Shadow(blurRadius: 10, color: Colors.black38)],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.28),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _resumeGame,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Resume'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.white.withOpacity(0.7)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _goMainMenu,
                    icon: const Icon(Icons.home_rounded),
                    label: const Text('Main Menu'),
                  ),
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, c) {
          if (worldW != c.maxWidth || worldH != c.maxHeight) {
            worldW = c.maxWidth;
            worldH = c.maxHeight;
            if (!started && !gameOver) {
              birdY = (worldH - groundH) / 2 - birdSize / 2;
              _setupPipes();
            }
          }

          return Stack(
            children: [
              // Background
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF74b9ff), Color(0xFFa0e9ff)],
                  ),
                ),
              ),

              // World
              CustomPaint(
                painter: WorldPainter(
                  pipes: pipes,
                  pipeW: pipeW,
                  pipeGapH: pipeGapH,
                  groundH: groundH,
                ),
                child: const SizedBox.expand(),
              ),

              // Burung (SVG)
              Positioned(
                left: birdX,
                top: birdY,
                child: Transform.rotate(
                  angle: birdVel.clamp(-12, 12) / 40,
                  child: SizedBox(
                    width: birdSize,
                    height: birdSize,
                    child: SvgPicture.asset(
                      'assets/bird.svg',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              // HUD Score
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
                        shadows: [
                          Shadow(
                            blurRadius: 8,
                            color: Colors.black45,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    if (best > 0) const SizedBox(height: 2),
                    if (best > 0)
                      Text(
                        'Best: $best',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),

              // Detector tap layar (HARUS di bawah tombol pause)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _flap,
                  child: const SizedBox.expand(),
                ),
              ),

              // Tombol Pause (tema glass kecil)
              if (started && !gameOver)
                Positioned(
                  top: 20,
                  left: 12,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.25),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color.fromARGB(59, 255, 255, 255)),
                        ),
                        child: IconButton(
                          icon: Icon(
                            paused
                                ? Icons.play_arrow_rounded
                                : Icons.pause_rounded,
                            color: Colors.white,
                          ),
                          onPressed: _openPauseOverlay,
                        ),
                      ),
                    ),
                  ),
                ),

              // Overlay Start / Game Over
              if (!started)
                Positioned.fill(
                  child: gameOver
                      ? Stack(
                          children: [
                            const ModalBarrier(
                              color: Colors.black38,
                              dismissible: false,
                            ),
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Game Over',
                                    style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          blurRadius: 10,
                                          color: Colors.black54,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  FilledButton(
                                    onPressed: _resetGame,
                                    child: const Text('Restart'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: _flap,
                          child: Container(
                            alignment: Alignment.center,
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Tap to Start',
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 10,
                                        color: Colors.black54,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'Tap layar untuk terbang',
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),

              // ===== Overlay PAUSED: Liquid Glass Floating Panel =====
              if (paused && started && !gameOver)
                Positioned.fill(
                  child: Stack(
                    children: [
                      // darken background + block tap
                      const ModalBarrier(
                        color: Colors.black38,
                        dismissible: false,
                      ),
                      // glass panel
                      _pauseGlassPanel(),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
