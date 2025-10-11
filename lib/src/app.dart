import 'package:flutter/material.dart';
import 'ui/screens/home_screen.dart';

class PersonalVaultApp extends StatelessWidget {
  const PersonalVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Vault',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.indigo,
      ),
      home: const HomeScreen(),
    );
  }
}
