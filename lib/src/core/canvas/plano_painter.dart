import 'package:flutter/material.dart';

import '../models/elemento_plano.dart';
import '../models/tipo_elemento.dart';

/// Convierte metros del plano a píxeles de pantalla. Un factor simple
/// de escala visual — no hay precisión CAD milimétrica, es un editor
/// rápido de anteproyecto.
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
      _dibujarVarillasColumna(canvas, rect, e.armado!.cantidadVarillasLongitudinales);
    }
  }

  void _dibujarVarillasColumna(Canvas canvas, Rect rect, int cantidad) {
    final paint = Paint()
      ..color = Colors.red.shade700
      ..style = PaintingStyle.fill;
    // Distribuye las varillas en las esquinas / bordes del cuadro —
    // representación esquemática, no un armado calculado a detalle.
    final puntos = <Offset>[
      rect.topLeft + const Offset(4, 4),
      rect.topRight + const Offset(-4, 4),
      rect.bottomLeft + const Offset(4, -4),
      rect.bottomRight + const Offset(-4, -4),
    ];
    for (var i = 0; i < cantidad && i < puntos.length; i++) {
      canvas.drawCircle(puntos[i], 3, paint);
    }
    // Estribo esquemático (cuadro punteado interior).
    _dibujarLineaPunteada(canvas, rect.deflate(4), Colors.red.shade300);
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

    // Varillas longitudinales de la viga: dos líneas paralelas
    // (superior/inferior) siguiendo el eje de la viga.
    final paint = Paint()
      ..color = Colors.red.shade700
      ..strokeWidth = 1.5;
    final dir = (e.puntos[1] - e.puntos[0]);
    final normal = Offset(-dir.dy, dir.dx).distance == 0
        ? const Offset(0, 1)
        : Offset(-dir.dy, dir.dx) / dir.distance;
    final offsetVarilla = normal * (grosor / 2 - 3);
    canvas.drawLine(e.puntos[0] + offsetVarilla, e.puntos[1] + offsetVarilla, paint);
    canvas.drawLine(e.puntos[0] - offsetVarilla, e.puntos[1] - offsetVarilla, paint);
  }

  void _dibujarLosa(Canvas canvas, ElementoPlano e, bool ocultarConcreto) {
    if (e.puntos.length < 2) return;
    final rect = Rect.fromPoints(e.puntos[0], e.puntos[1]);

    if (!ocultarConcreto) {
      canvas.drawRect(rect, Paint()..color = Colors.grey.shade300.withValues(alpha: 0.6));
    }
    canvas.drawRect(
      rect,
      Paint()
        ..color = Colors.red.shade300
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
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

  void _dibujarLineaPunteada(Canvas canvas, Rect rect, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant PlanoPainter oldDelegate) {
    return oldDelegate.elementos != elementos ||
        oldDelegate.capasVisibles != capasVisibles ||
        oldDelegate.verSoloEsqueleto != verSoloEsqueleto;
  }
}
