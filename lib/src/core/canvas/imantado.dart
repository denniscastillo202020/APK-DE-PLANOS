import 'package:flutter/material.dart';

import 'plano_painter.dart';
import '../models/elemento_plano.dart';

const double _distanciaImanNodo = 18;
const double _pasoCuadricula = pixelesPorMetro / 4;

Offset aplicarImantado(Offset punto, List<ElementoPlano> elementos) {
  Offset? masCercano;
  double distanciaMinima = _distanciaImanNodo;

  for (final elemento in elementos) {
    for (final nodo in elemento.puntos) {
      final distancia = (nodo - punto).distance;
      if (distancia < distanciaMinima) {
        distanciaMinima = distancia;
        masCercano = nodo;
      }
    }
  }

  if (masCercano != null) return masCercano;

  final x = (punto.dx / _pasoCuadricula).round() * _pasoCuadricula;
  final y = (punto.dy / _pasoCuadricula).round() * _pasoCuadricula;
  return Offset(x, y);
}
