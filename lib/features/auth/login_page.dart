import 'package:flutter/material.dart';
import 'package:supmap_clean/services/auth_service.dart';
import 'package:supmap_clean/features/home/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connexion'),
        centerTitle: true,
      ),
      body: Center(
        child: authService.isLoggedIn
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Connecté'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await authService.logout();
                setState(() {});
              },
              child: const Text('Se déconnecter'),
            ),
          ],
        )
            : ElevatedButton(
          onPressed: () async {
            await authService.login();
            final userInfo = authService.getUserInfo();

            String prenom = userInfo['given_name'] ?? 'Utilisateur';
            String nom = userInfo['family_name'] ?? '';
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => HomePage(
                  prenom: prenom,
                  nom: nom,
                ),
              ),
            );
          },
          child: const Text('Se connecter'),
        ),
      ),
    );
  }
}