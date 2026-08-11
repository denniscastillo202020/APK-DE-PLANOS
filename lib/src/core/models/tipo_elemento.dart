import 'package:flutter/material.dart';

/// Cada tipo de elemento pertenece a una capa. Apagar una capa oculta
/// todos los elementos de ese tipo a la vez.
enum TipoElemento {
  muro,
  columna,
  viga,
  losa,
  techo,
  puerta,
  ventana;

  Capa get capa {
    switch (this) {
      case TipoElemento.muro:
        return Capa.muros;
      case TipoElemento.columna:
      case TipoElemento.viga:
      case TipoElemento.losa:
        return Capa.estructura;
      case TipoElemento.techo:
        return Capa.techos;
      case TipoElemento.puerta:
      case TipoElemento.ventana:
        return Capa.vanos;
    }
  }

  /// Si es true, el elemento tiene concreto + armado (columna, viga, losa)
  /// y por lo tanto responde al interruptor global "ver esqueleto".
  bool get esElementoEstructural =>
      this == TipoElemento.columna || this == TipoElemento.viga || this == TipoElemento.losa;

  String get etiqueta {
    switch (this) {
      case TipoElemento.muro:
        return 'Muro';
      case TipoElemento.columna:
        return 'Columna';
      case TipoElemento.viga:
        return 'Viga';
      case TipoElemento.losa:
        return 'Losa';
      case TipoElemento.techo:
        return 'Techo';
      case TipoElemento.puerta:
        return 'Puerta';
      case TipoElemento.ventana:
        return 'Ventana';
    }
  }

  IconData get icono {
    switch (this) {
      case TipoElemento.muro:
        return Icons.horizontal_rule;
      case TipoElemento.columna:
        return Icons.crop_square;
      case TipoElemento.viga:
        return Icons.view_column_outlined;
      case TipoElemento.losa:
        return Icons.grid_on;
      case TipoElemento.techo:
        return Icons.roofing;
      case TipoElemento.puerta:
        return Icons.sensor_door_outlined;
      case TipoElemento.ventana:
        return Icons.window_outlined;
    }
  }
}

/// Capas visibles/ocultables de forma independiente en el plano.
/// [estructura] es la que responde al interruptor "ver esqueleto".
enum Capa {
  muros,
  estructura,
  techos,
  vanos;

  String get etiqueta {
    switch (this) {
      case Capa.muros:
        return 'Muros';
      case Capa.estructura:
        return 'Estructura (columnas, vigas, losas)';
      case Capa.techos:
        return 'Techos';
      case Capa.vanos:
        return 'Puertas y ventanas';
    }
  }
}
