/// Armado de varillas de un elemento estructural (columna, viga o losa).
/// Es información semi-manual: el usuario elige el armado de una
/// plantilla o lo edita, no se calcula por diseño estructural real.
class Armado {
  /// Varillas longitudinales, ej. "4 varillas #4" (asiendo/esquinas).
  final int cantidadVarillasLongitudinales;
  final String calibreVarillas; // ej. '#3', '#4', '#5'

  /// Estribos/aros de confinamiento.
  final String calibreEstribos; // ej. '#2', '#3'
  final double espaciamientoEstribosCm;

  const Armado({
    required this.cantidadVarillasLongitudinales,
    required this.calibreVarillas,
    required this.calibreEstribos,
    required this.espaciamientoEstribosCm,
  });

  String get resumen =>
      '$cantidadVarillasLongitudinales $calibreVarillas long. · '
      'estribos $calibreEstribos @ ${espaciamientoEstribosCm.toStringAsFixed(0)} cm';

  /// Plantillas rápidas para no obligar al usuario a llenar todo a mano.
  static const Armado columnaLigera = Armado(
    cantidadVarillasLongitudinales: 4,
    calibreVarillas: '#3',
    calibreEstribos: '#2',
    espaciamientoEstribosCm: 20,
  );

  static const Armado columnaEstandar = Armado(
    cantidadVarillasLongitudinales: 4,
    calibreVarillas: '#4',
    calibreEstribos: '#2',
    espaciamientoEstribosCm: 15,
  );

  static const Armado vigaEstandar = Armado(
    cantidadVarillasLongitudinales: 4,
    calibreVarillas: '#4',
    calibreEstribos: '#2',
    espaciamientoEstribosCm: 15,
  );
}
