import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../models/elemento_plano.dart';
import 'plano_painter.dart' show pixelesPorMetro;

class _Vertice3D {
  final double x, y, z;
  const _Vertice3D(this.x, this.y, this.z);
}

class _Cara {
  final List<_Vertice3D> vertices;
  final Color color;
  const _Cara(this.vertices, this.color);
}

class Vista3DPainter extends CustomPainter {
  final List<ElementoPlano> muros;
  final double anguloRotacionY;
  final double anguloInclinacion;
  static const double alturaMuroM = 2.5;

  Vista3DPainter({
    required this.muros,
    required this.anguloRotacionY,
    this.anguloInclinacion = 0.55,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (muros.isEmpty) {
      _dibujarMensajeVacio(canvas, size);
      return;
    }

    final cajas = muros.map(_extruirMuro).toList();

    final todosPuntos = cajas.expand((c) => c).toList();
    final centroX = todosPuntos.map((v) => v.x).reduce((a, b) => a + b) / todosPuntos.length;
    final centroZ = todosPuntos.map((v) => v.z).reduce((a, b) => a + b) / todosPuntos.length;

    final caras = <_Cara>[];
    for (final caja in cajas) {
      caras.addAll(_carasDeCaja(caja));
    }

    final carasProyectadas = caras.map((cara) {
      final verticesRotados = cara.vertices
          .map((v) => _rotarYProyectar(v, centroX, centroZ))
          .toList();
      final profundidadPromedio =
          verticesRotados.map((p) => p.$2).reduce((a, b) => a + b) / verticesRotados.length;
      return (puntos: verticesRotados.map((p) => p.$1).toList(), profundidad: profundidadPromedio, color: cara.color);
    }).toList()
      ..sort((a, b) => b.profundidad.compareTo(a.profundidad));

    final todosPtos2D = carasProyectadas.expand((c) => c.puntos).toList();
    final minX = todosPtos2D.map((p) => p.dx).reduce(math.min);
    final maxX = todosPtos2D.map((p) => p.dx).reduce(math.max);
    final minY = todosPtos2D.map((p) => p.dy).reduce(math.min);
    final maxY = todosPtos2D.map((p) => p.dy).reduce(math.max);
    final anchoModelo = (maxX - minX).clamp(1, double.infinity);
    final altoModelo = (maxY - minY).clamp(1, double.infinity);
    final escala = math.min(size.width / anchoModelo, size.height / altoModelo) * 0.8;
    final offset = Offset(
      size.width / 2 - (minX + maxX) / 2 * escala,
      size.height / 2 - (minY + maxY) / 2 * escala,
    );

    for (final cara in carasProyectadas) {
      final path = Path()..addPolygon(
        cara.puntos.map((p) => p * escala + offset).toList(),
        true,
      );
      canvas.drawPath(path, Paint()..color = cara.color);
      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.black26
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
  }

  void _dibujarMensajeVacio(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Dibuja al menos un muro en el plano 2D\npara ver la maqueta 3D',
        style: TextStyle(color: Colors.grey, fontSize: 14),
        textAlign: TextAlign.center,
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: size.width * 0.7);
    textPainter.paint(
      canvas,
      Offset((size.width - textPainter.width) / 2, (size.height - textPainter.height) / 2),
    );
  }

  List<_Vertice3D> _extruirMuro(ElementoPlano muro) {
    final p0 = muro.puntos[0];
    final p1 = muro.puntos[1];
    final dir = p1 - p0;
    final distancia = dir.distance == 0 ? 1 : dir.distance;
    final normal = Offset(-dir.dy, dir.dx) / distancia;
    final espesorPx = (muro.espesorCm / 100) * pixelesPorMetro;
    final mitad = normal * (espesorPx / 2);

    final esquinasPlanta = [
      p0 + mitad,
      p1 + mitad,
      p1 - mitad,
      p0 - mitad,
    ];

    final vertices = <_Vertice3D>[];
    for (final esquina in esquinasPlanta) {
      vertices.add(_Vertice3D(esquina.dx / pixelesPorMetro, 0, esquina.dy / pixelesPorMetro));
    }
    for (final esquina in esquinasPlanta) {
      vertices.add(_Vertice3D(esquina.dx / pixelesPorMetro, alturaMuroM, esquina.dy / pixelesPorMetro));
    }
    return vertices;
  }

  List<_Cara> _carasDeCaja(List<_Vertice3D> v) {
    Color sombrear(Color base, double factor) => Color.lerp(base, Colors.black, factor)!;
    const colorMuro = Color(0xFFE8E2D8);
    return [
      _Cara([v[0], v[1], v[2], v[3]], sombrear(colorMuro, 0.35)),
      _Cara([v[4], v[5], v[6], v[7]], sombrear(colorMuro, 0.05)),
      _Cara([v[0], v[1], v[5], v[4]], sombrear(colorMuro, 0.15)),
      _Cara([v[1], v[2], v[6], v[5]], sombrear(colorMuro, 0.30)),
      _Cara([v[2], v[3], v[7], v[6]], sombrear(colorMuro, 0.15)),
      _Cara([v[3], v[0], v[4], v[7]], sombrear(colorMuro, 0.30)),
    ];
  }

  (Offset, double) _rotarYProyectar(_Vertice3D v, double centroX, double centroZ) {
    final x = v.x - centroX;
    final z = v.z - centroZ;

    final cosA = math.cos(anguloRotacionY);
    final sinA = math.sin(anguloRotacionY);
    final xRot = x * cosA - z * sinA;
    final zRot = x * sinA + z * cosA;

    final cosI = math.cos(anguloInclinacion);
    final sinI = math.sin(anguloInclinacion);
    final yInclinado = v.y * cosI - zRot * sinI;
    final profundidad = v.y * sinI + zRot * cosI;

    return (Offset(xRot, -yInclinado), profundidad);
  }

  @override
  bool shouldRepaint(covariant Vista3DPainter oldDelegate) {
    return oldDelegate.muros != muros || oldDelegate.anguloRotacionY != anguloRotacionY;
  }
}
