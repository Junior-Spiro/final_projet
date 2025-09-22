import 'package:final_projet/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class AuthService {
  // Flux des changements d'état utilisateur
  Stream<fb_auth.User?> get fluxUtilisateur => _auth.authStateChanges();
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Récupère l'utilisateur Firebase actuel en UserModel
  UserModel? _userFromFirebase(fb_auth.User? user) {
    if (user == null) return null;

    return UserModel(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? '',
    );
  }

  // Inscription avec email et password
  Future<UserModel?> signUp(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Met à jour le nom d'affichage dans Firebase Auth
      await cred.user?.updateDisplayName(displayName);

      // Ensuite, on enregistre un document user dans Firestore
      final userModel = UserModel(
        id: cred.user!.uid,
        email: email,
        displayName: displayName,
      );

      // Ajouter le document utilisateur dans Firestore
      await _firestore.collection('users').doc(userModel.id).set({
        'id': userModel.id,
        'email': userModel.email,
        'displayName': userModel.displayName,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return userModel;
    } catch (e) {
      print('Erreur d\'inscription: $e');
      return null;
    }
  }

  // Connexion avec email et password
  final userService = UserService();

  Future<fb_auth.User?> connexionParEmailAvecSauvegarde(
    String email,
    String password,
  ) async {
    final credential = await fb_auth.FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
    final user = credential.user;
    if (user != null) {
      // Sauvegarde / mise à jour du document utilisateur Firestore
      await userService.sauvegarderUtilisateurFirebase(user);
    }
    return user;
  }

  // Déconnexion
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Récupérer utilisateur connecté
  UserModel? getCurrentUser() {
    final user = _auth.currentUser;
    return _userFromFirebase(user);
  }
}
