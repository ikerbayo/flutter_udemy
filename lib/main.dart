import 'package:flutter/material.dart';
import 'screens/main_screen.dart'; // <-- Importar MainScreen

void main() {
  runApp(const RedtableApp());
}

class RedtableApp extends StatelessWidget {
  const RedtableApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Redtablet Match Stats',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const MainScreen(), // <-- Ahora iniciamos en la MainScreen
    );
  }
}