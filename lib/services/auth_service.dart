import 'package:auth0_flutter/auth0_flutter.dart';

class AuthService {
  final auth0 = Auth0(
    'dev-0mfimrwwur6j6gw2.us.auth0.com',
    'prREvPAdbU2pMMQD15o5iNCE7zMmltVp',
  );

  Credentials? _credentials;

  Credentials? get credentials => _credentials;

  Future<void> login() async {
    try {
      final result = await auth0.webAuthentication(
        scheme: 'com.supmap.mobile', // Ton schéma personnalisé
      ).login();

      _credentials = result;
      print('Connexion réussie');
    } catch (e) {
      print('Erreur de connexion : $e');
    }
  }

  Future<void> logout() async {
    try {
      await auth0.webAuthentication(
        scheme: 'com.supmap.mobile',
      ).logout();

      _credentials = null;
      print('Déconnexion réussie');
    } catch (e) {
      print('Erreur de déconnexion : $e');
    }
  }

  bool get isLoggedIn => _credentials != null;
}