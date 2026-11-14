import 'package:flutter/material.dart';
import 'package:rinde/comun/tema/colores.dart';

class Cenefa extends StatelessWidget {
  const Cenefa({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 6,
      width: double.infinity,
      child: CustomPaint(painter: _CenefaPainter()),
    );
  }
}

class _CenefaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final aji = Paint()..color = Colores.aji;
    final clara = Paint()..color = const Color(0xFFF4DDD0);
    const ancho = 14.0;
    var x = 0.0;
    var i = 0;
    while (x < size.width) {
      canvas.drawRect(
        Rect.fromLTWH(x, 0, ancho, size.height),
        i.isEven ? aji : clara,
      );
      x += ancho;
      i++;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}