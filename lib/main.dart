import 'package:final_projet/models/lieu.dart';
import 'package:final_projet/pages/ecran_connexion.dart';
import 'package:final_projet/pages/page_acceuil.dart';
import 'package:final_projet/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ProviderScope(child: MonApplication()));
}

class MonApplication extends StatelessWidget {
  final Lieu? lieu;
  const MonApplication({super.key, this.lieu});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Compagny Hubs',
      theme: ThemeData(visualDensity: VisualDensity.adaptivePlatformDensity),
      home: FluxAuthentification(lieu: lieu),
    );
  }
}

class FluxAuthentification extends StatelessWidget {
  final Lieu? lieu;
  const FluxAuthentification({super.key, this.lieu});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService().fluxUtilisateur,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final hasUser = snapshot.hasData && snapshot.data != null;

        if (!hasUser) {
          // Utilisateur non connecté → page de connexion
          return LoginPage(lieu: lieu ?? _defaultLieu());
        } else {
          // Utilisateur connecté → page d'accueil
          return PageAccueil(lieu: lieu ?? _defaultLieu());
        }
      },
    );
  }

  // Méthode pour fournir un Lieu par défaut si lieu est null
  Lieu _defaultLieu() {
    return Lieu(
      uid: '',
      nom: 'Lieu par défaut',
      description: 'Description par défaut',
      ville: 'Ville par défaut',
      photoUrl: '',
      id: '',
    );
  }
}
