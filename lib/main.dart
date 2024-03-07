import 'package:flutter/material.dart';
import 'login_panels/start.dart'; // Import klasy StartPage z pliku start.dart

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        fontFamily: 'Jaapokki',
      ),
      home: const StartPage(), // Użycie StartPage zamiast MyHomePage
    );
  }
}
