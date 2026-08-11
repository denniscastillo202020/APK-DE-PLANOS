import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/features/editor/presentation/screens/editor_screen.dart';

void main() {
  runApp(const ProviderScope(child: PlanosCastilloApp()));
}

class PlanosCastilloApp extends StatelessWidget {
  const PlanosCastilloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PLANOS CASTILLO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFB33A2E)),
      ),
      home: const EditorScreen(),
    );
  }
}
