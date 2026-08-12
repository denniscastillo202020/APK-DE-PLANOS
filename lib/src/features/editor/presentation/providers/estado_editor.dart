import 'package:flutter/material.dart';

import '../../../../core/models/elemento_plano.dart';
import '../../../../core/models/tipo_elemento.dart';

@immutable
class EstadoEditor {
  final List<ElementoPlano> elementos;
  final TipoElemento? herramientaActiva;
  final Set<Capa> capasVisibles;

  final bool verSoloEsqueleto;

  const EstadoEditor({
    this.elementos = const [],
    this.herramientaActiva,
    this.capasVisibles = const {
      Capa.muros,
      Capa.estructura,
      Capa.techos,
      Capa.vanos,
    },
    this.verSoloEsqueleto = false,
  });

  EstadoEditor copyWith({
    List<ElementoPlano>? elementos,
    TipoElemento? herramientaActiva,
    bool limpiarHerramienta = false,
    Set<Capa>? capasVisibles,
    bool? verSoloEsqueleto,
  }) {
    return EstadoEditor(
      elementos: elementos ?? this.elementos,
      herramientaActiva: limpiarHerramienta ? null : (herramientaActiva ?? this.herramientaActiva),
      capasVisibles: capasVisibles ?? this.capasVisibles,
      verSoloEsqueleto: verSoloEsqueleto ?? this.verSoloEsqueleto,
    );
  }
}
