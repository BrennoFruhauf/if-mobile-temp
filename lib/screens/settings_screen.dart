import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Informações da Conta', style: TextStyle(fontSize: 18)),
            const TextField(
              decoration: InputDecoration(labelText: 'Nome'),
            ),
            const TextField(
              decoration: InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
              },
              child: const Text('Salvar Alterações'),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const Text('Excluir Conta', style: TextStyle(color: Colors.red, fontSize: 18)),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white
              ),
              onPressed: () {
              },
              child: const Text('Deletar Conta'),
            ),
          ],
        ),
      ),
    );
  }
}
