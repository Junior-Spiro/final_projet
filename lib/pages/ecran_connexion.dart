import 'package:final_projet/models/lieu.dart';
import 'package:final_projet/pages/ecran_inscription.dart';
import 'package:final_projet/pages/page_acceuil.dart';
import 'package:final_projet/services/user_service.dart'; // corriger le nom selon ton fichier
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

///Pour se connecter:
///jrspiro05@gmail.com ; mp:12345aze
///jrtrad23@gmail.com ; mp:12345aze
///lefa2fale2@gmail.com; mp: Junior2025

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.lieu});
  final Lieu lieu;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  String? _errorMessage;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    if (!mounted) return;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final email = _emailController.text.trim();
      final mdp = _passwordController.text.trim();

      // Connexion Firebase Auth directe
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: mdp,
      );

      final user = credential.user;
      if (user != null) {
        // Sauvegarde/mise à jour de l'utilisateur dans Firestore
        await UserService().sauvegarderUtilisateurFirebase(user);

        // Navigation vers la page d'accueil après connexion réussie
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PageAccueil(lieu: widget.lieu),
          ),
        );
      } else {
        if (!mounted) return;
        setState(() {
          _errorMessage =
              "Impossible de récupérer les informations utilisateur.";
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'user-not-found' || e.code == 'wrong-password') {
          _errorMessage = "Nom d'utilisateur ou mot de passe incorrect.";
        } else if (e.code == 'invalid-email') {
          _errorMessage = "Adresse email invalide.";
        } else {
          _errorMessage = e.message ?? "Erreur lors de la connexion.";
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = "Erreur inconnue, veuillez réessayer.";
      });
    } finally {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        title: const Text('Connexion'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(
                    'Compagny Hubs'.toUpperCase(),
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => v == null || !v.contains('@')
                        ? 'Entrez un email valide'
                        : null,
                  ),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Mot de passe',
                    ),
                    obscureText: true,
                    validator: (v) => v == null || v.isEmpty
                        ? 'Entrez un mot de passe'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  if (_errorMessage != null)
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                    ),
                    onPressed: _loading ? null : _login,
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.black54)
                        : const Text(
                            'Se connecter',
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterPage()),
                      );
                    },
                    child: Text(
                      'Pas de compte ? Inscrivez-vous',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
