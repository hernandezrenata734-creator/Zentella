import 'package:flutter/material.dart';

void main() {
  runApp(const ZentellaApp());
}

class ZentellaApp extends StatelessWidget {
  const ZentellaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zentella',
      home: Scaffold(
        appBar: AppBar(title: const Text('Zentella Motos')),
        body: const Center(child: Text('¡Bienvenido a Zentella!')),
      ),
    );
  }
}
