import 'package:flutter/material.dart';

import 'armado.dart';
import 'tipo_elemento.dart';

/// Un elemento colocado en el plano. La geometría se guarda como una
/// lista simple de puntos, interpretada según [tipo]:
///  - muro / viga: 2 puntos (línea) + [espesorCm]
///  - columna: 1 punto (centro) + [espesorCm] como lado del cuadrado
///  - losa / techo: 2 puntos (esquinas opuestas del rectángulo)
///  - puerta / ventana: 2 puntos (esquinas del vano) sobre un muro
class ElementoPlano {
  final String id;
  final TipoElemento tipo;
  final List<Offset> puntos;
  final double espesorCm;

  /// Solo aplica si [TipoElemento.esElementoEstructural] es true.
  final Armado? armado;

  const ElementoPlano({
    required this.id,
    required this.tipo,
    required this.puntos,
    required this.espesorCm,
    this.armado,
  });

  ElementoPlano copyWith({
    List<Offset>? puntos,
    double? espesorCm,
    Armado? armado,
  }) {
    return ElementoPlano(
      id: id,
      tipo: tipo,
      puntos: puntos ?? this.puntos,
      espesorCm: espesorCm ?? this.espesorCm,
      armado: armado ?? this.armado,
    );
  }
}
