// import 'package:flutter/material.dart';

// /// Widget burung yang dipakai di game & login (sebagai logo).
// class BirdBox extends StatelessWidget {
//   const BirdBox({super.key, this.size = 38, this.tilt = 0});
//   final double size;
//   final double tilt;

//   @override
//   Widget build(BuildContext context) {
//     return Transform.rotate(
//       angle: tilt,
//       child: Container(
//         width: size,
//         height: size,
//         decoration: BoxDecoration(
//           color: Colors.yellow.shade700,
//           borderRadius: BorderRadius.circular(8),
//           boxShadow: const [
//             BoxShadow(
//               blurRadius: 6,
//               offset: Offset(0, 3),
//               color: Colors.black26,
//             ),
//           ],
//           border: Border.all(color: Colors.orange, width: 2),
//         ),
//         child: CustomPaint(painter: BirdEyePainter()),
//       ),
//     );
//   }
// }

// /// Painter mata & paruh burung.
// class BirdEyePainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final eye = Paint()..color = Colors.white;
//     final pupil = Paint()..color = Colors.black87;
//     final beak = Paint()..color = Colors.orangeAccent;

//     final eyeCenter = Offset(size.width * 0.70, size.height * 0.35);
//     canvas.drawCircle(eyeCenter, size.shortestSide * 0.12, eye);
//     canvas.drawCircle(eyeCenter, size.shortestSide * 0.06, pupil);

//     final path = Path()
//       ..moveTo(size.width * 0.95, size.height * 0.50)
//       ..lineTo(size.width * 1.10, size.height * 0.60)
//       ..lineTo(size.width * 0.95, size.height * 0.70)
//       ..close();
//     canvas.drawPath(path, beak);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }
