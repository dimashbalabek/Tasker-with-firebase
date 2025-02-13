import 'package:flutter/material.dart';
import 'dart:math';

class CircularProgressBar extends StatelessWidget {
  final double progress;
  
  const CircularProgressBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      width: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          
          CustomPaint(
            size: const Size(100, 100),
            painter: CirclePainter(progress: 1, color: Colors.grey[300]!), 
          ),
          
          CustomPaint(
            size: const Size(100, 100),
            painter: CirclePainter(progress: progress, color: Colors.green),
          ),
          
          Text(
            "${(progress * 100).toInt()}%",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ],
      ),
    );
  }
}

class CirclePainter extends CustomPainter {
  final double progress; 
  final Color color;

  CirclePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round; 

    double radius = size.width / 2;
    Offset center = Offset(radius, radius);
    double startAngle = -pi / 2; 
    double sweepAngle = 2 * pi * progress; 

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(CirclePainter oldDelegate) => oldDelegate.progress != progress;
}
