import 'package:flutter/material.dart';
import '../models/pipe.dart';

class WorldPainter extends CustomPainter {
  WorldPainter({
    required this.pipes,
    required this.pipeW,
    required this.pipeGapH,
    required this.groundH,
  });

  final List<Pipe> pipes;
  final double pipeW;
  final double pipeGapH;
  final double groundH;

  @override
  void paint(Canvas canvas, Size size) {
    final usableH = size.height - groundH;

    // Pipa
    final paintPipe = Paint()..color = const Color(0xFF2ecc71);
    final paintLip  = Paint()..color = const Color(0xFF27ae60);

    for (final p in pipes) {
      final topRect = Rect.fromLTWH(p.x, 0, pipeW, p.gapCenterY - pipeGapH / 2);
      final bottomRect = Rect.fromLTWH(
        p.x,
        p.gapCenterY + pipeGapH / 2,
        pipeW,
        usableH - (p.gapCenterY + pipeGapH / 2),
      );
      canvas.drawRect(topRect, paintPipe);
      canvas.drawRect(bottomRect, paintPipe);
      canvas.drawRect(Rect.fromLTWH(topRect.left - 2, topRect.bottom - 12, pipeW + 4, 12), paintLip);
      canvas.drawRect(Rect.fromLTWH(bottomRect.left - 2, bottomRect.top,     pipeW + 4, 12), paintLip);
    }

    // Tanah & rumput
    final groundRect  = Rect.fromLTWH(0, usableH, size.width, groundH);
    final groundPaint = Paint()..color = const Color(0xFF8d6e63);
    final grassPaint  = Paint()..color = const Color(0xFF4caf50);
    canvas.drawRect(groundRect, groundPaint);
    canvas.drawRect(Rect.fromLTWH(0, usableH, size.width, 14), grassPaint);
  }

  @override
  bool shouldRepaint(covariant WorldPainter oldDelegate) => true;
}
