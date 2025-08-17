import 'package:flutter/material.dart';
import 'features/auth/presentation/auth_gate.dart';

class CountlyApp extends StatelessWidget {
  const CountlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF00B894),
      ),
      home: const AuthGate(),
    );
  }
}
