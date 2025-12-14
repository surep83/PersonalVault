import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Vault'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Welcome to Personal Vault',
          style: TextStyle(fontSize: 18),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Open item creation flow
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
