import 'package:flutter/material.dart';

import '../../../../core/canvas/vista3d_painter.dart';
import '../../../../core/models/elemento_plano.dart';
import '../../../../core/models/tipo_elemento.dart';

class Vista3DScreen extends StatefulWidget {
  final List<ElementoPlano> elementos;

  const Vista3DScreen({super.key, required this.elementos});

  @override
  State<Vista3DScreen> createState() => _Vista3DScreenState();
}

class _Vista3DScreenState extends State<Vista3DScreen> {
  double _angulo = 0.8;

  @override
  Widget build(BuildContext context) {
    final muros = widget.elementos.where((e) => e.tipo == TipoElemento.muro).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Maqueta 3D (arrastra para girar)')),
      body: GestureDetector(
        onPanUpdate: (details) {
          setState(() => _angulo += details.delta.dx * 0.01);
        },
        child: CustomPaint(
          painter: Vista3DPainter(muros: muros, anguloRotacionY: _angulo),
          size: Size.infinite,
        ),
      ),
    );
  }
}
