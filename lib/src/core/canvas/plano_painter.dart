import 'package:flutter/material.dart';

import '../models/elemento_plano.dart';
import '../models/tipo_elemento.dart';

const double pixelesPorMetro = 60;

class PlanoPainter extends CustomPainter {
  final List<ElementoPlano> elementos;
  final Set<Capa> capasVisibles;
  final bool verSoloEsqueleto;

  PlanoPainter({
    required this.elementos,
    required this.capasVisibles,
    required this.verSoloEsqueleto,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _dibujarCuadricula(canvas, size);

    for (final elemento in elementos) {
      if (!capasVisibles.contains(elemento.tipo.capa)) continue;

      final ocultarConcreto = verSoloEsqueleto && elemento.tipo.esElementoEstructural;

      switch (elemento.tipo) {
        case TipoElemento.muro:
          _dibujarMuro(canvas, elemento);
          break;
        case TipoElemento.columna:
          _dibujarColumna(canvas, elemento, ocultarConcreto);
          break;
        case TipoElemento.viga:
          _dibujarViga(canvas, elemento, ocultarConcreto);
          break;
        case TipoElemento.losa:
          _dibujarLosa(canvas, elemento, ocultarConcreto);
          break;
        case TipoElemento.techo:
          _dibujarTecho(canvas, elemento);
          break;
        case TipoElemento.puerta:
        case TipoElemento.ventana:
          _dibujarVano(canvas, elemento);
          break;
      }
    }
  }

  void _dibujarCuadricula(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.15)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += pixelesPorMetro) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += pixelesPorMetro) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _dibujarMuro(Canvas canvas, ElementoPlano e) {
    if (e.puntos.length < 2) return;
    final paint = Paint()
      ..color = Colors.black87
      ..strokeWidth = (e.espesorCm / 100) * pixelesPorMetro
      ..strokeCap = StrokeCap.square;
    canvas.drawLine(e.puntos[0], e.puntos[1], paint);

    final nodo = Paint()..color = Colors.blueGrey.shade700;
    canvas.drawCircle(e.puntos[0], 3, nodo);
    canvas.drawCircle(e.puntos[1], 3, nodo);
  }

  void _dibujarColumna(Canvas canvas, ElementoPlano e, bool ocultarConcreto) {
    if (e.puntos.isEmpty) return;
    final centro = e.puntos.first;
    final lado = (e.espesorCm / 100) * pixelesPorMetro;
    final rect = Rect.fromCenter(center: centro, width: lado, height: lado);

    if (!ocultarConcreto) {
      canvas.drawRect(rect, Paint()..color = Colors.grey.shade400);
      canvas.drawRect(
        rect,
        Paint()
          ..color = Colors.black54
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }

    if (e.armado != null) {
      _dibujarArmadoColumna(canvas, rect, e.armado!.cantidadVarillasLongitudinales);
    }
  }

  void _dibujarArmadoColumna(Canvas canvas, Rect rect, int cantidad) {
    final estribo = rect.deflate(rect.shortestSide * 0.12);

    canvas.drawRect(
      estribo,
      Paint()
        ..color = Colors.red.shade600
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    final puntosEsquina = <Offset>[
      estribo.topLeft,
      estribo.topRight,
      estribo.bottomLeft,
      estribo.bottomRight,
    ];
    final paintVarilla = Paint()..color = Colors.red.shade900;
    final radio = (rect.shortestSide * 0.09).clamp(2.5, 6.0);
    for (var i = 0; i < cantidad && i < puntosEsquina.length; i++) {
      canvas.drawCircle(puntosEsquina[i], radio, paintVarilla);
      canvas.drawCircle(
        puntosEsquina[i],
        radio,
        Paint()
          ..color = Colors.black87
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );
    }
  }

  void _dibujarViga(Canvas canvas, ElementoPlano e, bool ocultarConcreto) {
    if (e.puntos.length < 2) return;
    final grosor = (e.espesorCm / 100) * pixelesPorMetro;

    if (!ocultarConcreto) {
      canvas.drawLine(
        e.puntos[0],
        e.puntos[1],
        Paint()
          ..color = Colors.grey.shade500
          ..strokeWidth = grosor,
      );
    }

    final dir = e.puntos[1] - e.puntos[0];
    if (dir.distance == 0) return;
    final normal = Offset(-dir.dy, dir.dx) / dir.distance;
    final offsetVarilla = normal * (grosor / 2 - 4).clamp(2.0, grosor);

    final paintVarilla = Paint()
      ..color = Colors.red.shade900
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(e.puntos[0] + offsetVarilla, e.puntos[1] + offsetVarilla, paintVarilla);
    canvas.drawLine(e.puntos[0] - offsetVarilla, e.puntos[1] - offsetVarilla, paintVarilla);

    final cantidadEstribos = (dir.distance / (pixelesPorMetro * 0.25)).clamp(2, 30).toInt();
    final paintEstribo = Paint()
      ..color = Colors.red.shade600
      ..strokeWidth = 1.5;
    for (var i = 0; i <= cantidadEstribos; i++) {
      final t = i / cantidadEstribos;
      final centro = Offset.lerp(e.puntos[0], e.puntos[1], t)!;
      canvas.drawLine(centro + offsetVarilla, centro - offsetVarilla, paintEstribo);
    }
  }

  void _dibujarLosa(Canvas canvas, ElementoPlano e, bool ocultarConcreto) {
    if (e.puntos.length < 2) return;
    final rect = Rect.fromPoints(e.puntos[0], e.puntos[1]);

    if (!ocultarConcreto) {
      canvas.drawRect(rect, Paint()..color = Colors.grey.shade300.withValues(alpha: 0.6));
    }

    final paintMalla = Paint()
      ..color = Colors.red.shade400
      ..strokeWidth = 1;
    const paso = 20.0;
    for (double x = rect.left; x <= rect.right; x += paso) {
      canvas.drawLine(Offset(x, rect.top), Offset(x, rect.bottom), paintMalla);
    }
    for (double y = rect.top; y <= rect.bottom; y += paso) {
      canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), paintMalla);
    }
    canvas.drawRect(
      rect,
      Paint()
        ..color = Colors.red.shade700
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  void _dibujarTecho(Canvas canvas, ElementoPlano e) {
    if (e.puntos.length < 2) return;
    final rect = Rect.fromPoints(e.puntos[0], e.puntos[1]);
    canvas.drawRect(
      rect,
      Paint()
        ..color = Colors.brown.shade300.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _dibujarVano(Canvas canvas, ElementoPlano e) {
    if (e.puntos.length < 2) return;
    final rect = Rect.fromPoints(e.puntos[0], e.puntos[1]);
    final color = e.tipo == TipoElemento.puerta ? Colors.brown : Colors.lightBlue;
    canvas.drawRect(rect, Paint()..color = Colors.white);
    canvas.drawRect(
      rect,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant PlanoPainter oldDelegate) {
    return oldDelegate.elementos != elementos ||
        oldDelegate.capasVisibles != capasVisibles ||
        oldDelegate.verSoloEsqueleto != verSoloEsqueleto;
  }
}
