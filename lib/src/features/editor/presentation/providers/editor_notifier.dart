import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/models/armado.dart';
import '../../../../core/models/elemento_plano.dart';
import '../../../../core/models/tipo_elemento.dart';
import 'estado_editor.dart';

const _uuid = Uuid();

class EditorNotifier extends StateNotifier<EstadoEditor> {
  EditorNotifier() : super(const EstadoEditor());

  void seleccionarHerramienta(TipoElemento? tipo) {
    state = state.copyWith(herramientaActiva: tipo, limpiarHerramienta: tipo == null);
  }

  /// Agrega un elemento nuevo con la herramienta activa, en los puntos
  /// que el usuario tocó/arrastró en el lienzo.
  void agregarElemento(List<Offset> puntos, {double espesorCm = 15}) {
    final tipo = state.herramientaActiva;
    if (tipo == null) return;

    final elemento = ElementoPlano(
      id: _uuid.v4(),
      tipo: tipo,
      puntos: puntos,
      espesorCm: espesorCm,
      armado: tipo.esElementoEstructural
          ? (tipo == TipoElemento.columna ? Armado.columnaEstandar : Armado.vigaEstandar)
          : null,
    );

    state = state.copyWith(elementos: [...state.elementos, elemento]);
  }

  void eliminarElemento(String id) {
    state = state.copyWith(
      elementos: state.elementos.where((e) => e.id != id).toList(),
    );
  }

  void actualizarArmado(String id, Armado nuevoArmado) {
    state = state.copyWith(
      elementos: [
        for (final e in state.elementos)
          if (e.id == id) e.copyWith(armado: nuevoArmado) else e,
      ],
    );
  }

  void alternarCapa(Capa capa) {
    final nuevas = {...state.capasVisibles};
    if (nuevas.contains(capa)) {
      nuevas.remove(capa);
    } else {
      nuevas.add(capa);
    }
    state = state.copyWith(capasVisibles: nuevas);
  }

  /// El interruptor global "ver esqueleto": apaga el relleno de concreto
  /// en TODOS los elementos estructurales a la vez (columnas + vigas +
  /// losas), sin importar cómo estén conectados entre sí.
  void alternarVerEsqueleto() {
    state = state.copyWith(verSoloEsqueleto: !state.verSoloEsqueleto);
  }
}

final editorProvider = StateNotifierProvider<EditorNotifier, EstadoEditor>((ref) {
  return EditorNotifier();
});
