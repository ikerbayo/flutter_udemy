import 'package:flutter/material.dart';
import 'api_service.dart';
import 'screens/login_screen.dart';
import 'screens/clubs_screen.dart';

void main() {
  runApp(const RedtableApp());
}

class RedtableApp extends StatelessWidget {
  const RedtableApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lologol',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF667eea),
          primary: const Color(0xFF667eea),
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      home: FutureBuilder<String?>(
        future: apiService.getToken(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasData && snapshot.data != null) {
            return const ClubsScreen();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
