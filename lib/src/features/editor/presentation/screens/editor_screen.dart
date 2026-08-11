import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/canvas/plano_painter.dart';
import '../../../../core/models/tipo_elemento.dart';
import '../providers/editor_notifier.dart';

class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({super.key});

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  Offset? _puntoInicial;
  Offset? _puntoActual;

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(editorProvider);
    final notifier = ref.read(editorProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PLANOS CASTILLO'),
        actions: [
          IconButton(
            tooltip: estado.verSoloEsqueleto ? 'Mostrar concreto' : 'Ver solo esqueleto',
            icon: Icon(estado.verSoloEsqueleto ? Icons.visibility : Icons.visibility_outlined),
            onPressed: notifier.alternarVerEsqueleto,
          ),
          IconButton(
            tooltip: 'Capas',
            icon: const Icon(Icons.layers_outlined),
            onPressed: () => _mostrarPanelCapas(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          if (estado.verSoloEsqueleto)
            Container(
              width: double.infinity,
              color: Colors.red.shade50,
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                'Modo esqueleto: solo se muestra el armado de hierro',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red.shade900, fontSize: 12),
              ),
            ),
          Expanded(
            child: GestureDetector(
              onPanStart: (details) {
                if (estado.herramientaActiva == null) return;
                setState(() {
                  _puntoInicial = details.localPosition;
                  _puntoActual = details.localPosition;
                });
              },
              onPanUpdate: (details) {
                if (_puntoInicial == null) return;
                setState(() => _puntoActual = details.localPosition);
              },
              onPanEnd: (details) {
                if (_puntoInicial == null || _puntoActual == null) return;
                final tipo = estado.herramientaActiva!;
                final puntos = tipo == TipoElemento.columna
                    ? [_puntoInicial!]
                    : [_puntoInicial!, _puntoActual!];
                notifier.agregarElemento(puntos, espesorCm: _espesorPorDefecto(tipo));
                setState(() {
                  _puntoInicial = null;
                  _puntoActual = null;
                });
              },
              child: CustomPaint(
                painter: PlanoPainter(
                  elementos: estado.elementos,
                  capasVisibles: estado.capasVisibles,
                  verSoloEsqueleto: estado.verSoloEsqueleto,
                ),
                size: Size.infinite,
              ),
            ),
          ),
          _BarraHerramientas(
            herramientaActiva: estado.herramientaActiva,
            onSeleccionar: notifier.seleccionarHerramienta,
          ),
        ],
      ),
    );
  }

  double _espesorPorDefecto(TipoElemento tipo) {
    switch (tipo) {
      case TipoElemento.muro:
        return 15;
      case TipoElemento.columna:
        return 20;
      case TipoElemento.viga:
        return 20;
      case TipoElemento.losa:
      case TipoElemento.techo:
        return 10;
      case TipoElemento.puerta:
      case TipoElemento.ventana:
        return 10;
    }
  }

  void _mostrarPanelCapas(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final estado = ref.watch(editorProvider);
          final notifier = ref.read(editorProvider.notifier);
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Capas', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                for (final capa in Capa.values)
                  SwitchListTile(
                    title: Text(capa.etiqueta),
                    value: estado.capasVisibles.contains(capa),
                    onChanged: (_) => notifier.alternarCapa(capa),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BarraHerramientas extends StatelessWidget {
  final TipoElemento? herramientaActiva;
  final void Function(TipoElemento?) onSeleccionar;

  const _BarraHerramientas({required this.herramientaActiva, required this.onSeleccionar});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: [
          for (final tipo in TipoElemento.values)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: _BotonHerramienta(
                tipo: tipo,
                activo: herramientaActiva == tipo,
                onTap: () => onSeleccionar(herramientaActiva == tipo ? null : tipo),
              ),
            ),
        ],
      ),
    );
  }
}

class _BotonHerramienta extends StatelessWidget {
  final TipoElemento tipo;
  final bool activo;
  final VoidCallback onTap;

  const _BotonHerramienta({required this.tipo, required this.activo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 68,
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: activo ? colorScheme.primaryContainer : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(tipo.icono, color: activo ? colorScheme.onPrimaryContainer : null),
            Text(tipo.etiqueta, style: const TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
