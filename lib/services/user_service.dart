import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Met à jour ou crée les données utilisateur dans Firestore
  Future<void> sauvegarderUtilisateurFirebase(User firebaseUser) async {
    final userDoc = _firestore.collection('users').doc(firebaseUser.uid);

    final data = {
      'uid': firebaseUser.uid,
      'email': firebaseUser.email ?? '',
      'userName': firebaseUser.displayName ?? '',
      'photoURL': firebaseUser.photoURL ?? '',
      'lastLogin': FieldValue.serverTimestamp(),
    };

    // Merge: true pour ne pas écraser tout le document si existant
    await userDoc.set(data, SetOptions(merge: true));
  }

  // Récupérer les données utilisateur Firestore à partir de l'UID
  Future<Map<String, dynamic>?> recupererDonneesUtilisateur(String uid) async {
    final docSnapshot = await _firestore.collection('users').doc(uid).get();
    if (docSnapshot.exists) {
      return docSnapshot.data();
    } else {
      return null;
    }
  }
}
