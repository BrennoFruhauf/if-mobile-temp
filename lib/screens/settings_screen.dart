import 'package:flutter/material.dart';
import 'package:laura/constants/routes.dart';
import 'package:laura/services/auth_service.dart';

class SettingsScreen extends StatelessWidget {
  final _authService = AuthService();

  SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildBasicInfoSection(context),
          const SizedBox(height: 16),
          _buildChangePasswordSection(context),
          const SizedBox(height: 16),
          _buildAccountActionsSection(context),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title: const Text('Informações Básicas'),
        leading: const Icon(Icons.person),
        children: [
          ListTile(
            title: const Text('Alterar Nome'),
            leading: const Icon(Icons.edit),
            onTap: () => _showEditDialog(
              context,
              title: 'Alterar Nome',
              hint: 'Digite o novo nome',
              onSave: (newName, _) {
                _authService.updateUsername(newName).then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Nome alterado com sucesso!'),
                    ),
                  );
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Erro ao alterar o nome!'),
                    ),
                  );
                });
              },
            ),
          ),
          ListTile(
            title: const Text('Alterar Email'),
            leading: const Icon(Icons.email),
            onTap: () => _showEditDialog(
              context,
              title: 'Alterar Email',
              hint: 'Digite o novo email',
              needPassword: true,
              onSave: (newEmail, currentPassword) {
                _authService.updateEmail(newEmail, currentPassword!).then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Foi enviado um e-mail de confirmação!'),
                    ),
                  );
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Erro ao alterar e-mail!'),
                    ),
                  );
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangePasswordSection(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title: const Text('Segurança'),
        leading: const Icon(Icons.lock),
        children: [
          ListTile(
            title: const Text('Alterar Senha'),
            leading: const Icon(Icons.password),
            onTap: () => _showEditDialog(
              context,
              title: 'Alterar Senha',
              hint: 'Digite a nova senha',
              isPassword: true,
              needPassword: true,
              onSave: (newPassword, currentPassword) {
                _authService
                    .updatePassword(newPassword, currentPassword!)
                    .then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Senha alterada com sucesso!'),
                    ),
                  );
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Erro ao alterar a senha!'),
                    ),
                  );
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountActionsSection(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title: const Text('Ações da Conta'),
        leading: const Icon(Icons.account_circle),
        children: [
          ListTile(
            title: const Text('Deslogar'),
            leading: const Icon(Icons.logout),
            onTap: () {
              _logout(context);
            },
          ),
          ListTile(
            title: const Text('Deletar Conta'),
            leading: const Icon(Icons.delete),
            onTap: () {
              _confirmDeleteAccount(context);
            },
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
    BuildContext context, {
    required String title,
    required String hint,
    bool isPassword = false,
    bool needPassword = false,
    required Function(String, String?) onSave,
  }) {
    final controller = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(hintText: hint),
              obscureText: isPassword,
            ),
            if (needPassword)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: TextField(
                  controller: passwordController,
                  decoration:
                      const InputDecoration(hintText: 'Digite sua senha atual'),
                  obscureText: true,
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (needPassword) {
                onSave(controller.text, passwordController.text);
              } else {
                onSave(controller.text, null);
              }
              Navigator.pop(context);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    _authService.signOut();
    Navigator.pushReplacementNamed(context, Routes.login);
  }

  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deletar Conta'),
        content: const Text(
          'Tem certeza de que deseja deletar sua conta? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteAccount(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Deletar'),
          ),
        ],
      ),
    );
  }

  void _deleteAccount(BuildContext context) async {
    await _authService.deleteAccount().then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuário deletado com sucesso!'),
        ),
      );

      Navigator.pushReplacementNamed(context, Routes.login);
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao deletar usuário!'),
        ),
      );
    });
  }
}
