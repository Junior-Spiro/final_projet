// lib/services/firebase_service.dart

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:final_projet/models/lieu.dart';

class FirebaseService {
  // URL du bucket Storage du projet A
  static const String _otherBucketUrl = 'gs://allforone-54c5a.appspot.com';

  // Instance de FirebaseStorage pointant vers le bucket du projet A
  static final FirebaseStorage _otherStorage = FirebaseStorage.instanceFor(
    bucket: _otherBucketUrl,
  );

  // Upload image dans le bucket du projet A et retourne l'URL publique
  static Future<String> uploadImage(File image) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final storageRef = _otherStorage.ref().child('lieux_photos/$timestamp.jpg');

    try {
      final uploadTask = storageRef.putFile(image);
      final snapshot = await uploadTask;

      // Retourne l'URL téléchargeable de l'image
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Erreur lors de l\'upload de l\'image: $e');
    }
  }

  //Pour l'image de profil
  static Future<String> uploadImageProfil(File image, String uid) async {
    final storageRef = _otherStorage.ref().child('user_profil_photo/$uid.jpg');

    try {
      final uploadTask = storageRef.putFile(image);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Erreur lors de l\'upload de l\'image: $e');
    }
  }

  // Ajout d'un lieu : upload image dans le bucket du projet A, puis enregistrement dans Firestore du projet B
  static Future<void> ajouterLieu({
    required String uid,
    required String nom,
    required String description,
    required String ville,
    required File image,
  }) async {
    try {
      final photoUrl = await uploadImage(image);

      final collection = FirebaseFirestore.instance.collection('lieux');
      // Crée un nouveau doc avec ID auto généré
      final docRef = collection.doc();

      final lieu = Lieu(
        id: docRef.id,
        uid: uid,
        nom: nom,
        description: description,
        ville: ville,
        photoUrl: photoUrl,
      );

      await docRef.set(lieu.toMap());
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout du lieu: $e');
    }
  }

  // Modification d'un lieu : possibilité de changer image & données
  static Future<void> modifierLieu({
    required String lieuId,
    required String nom,
    required String description,
    required String ville,
    String? anciennePhotoUrl,
    File? nouvelleImage,
  }) async {
    try {
      String photoUrl = anciennePhotoUrl ?? '';

      if (nouvelleImage != null) {
        // Suppression de l'ancienne image dans le bucket A si elle existe
        if (anciennePhotoUrl != null && anciennePhotoUrl.isNotEmpty) {
          try {
            final ancienRef = _otherStorage.refFromURL(anciennePhotoUrl);
            await ancienRef.delete();
          } catch (e) {
            print('Erreur suppression ancienne image: $e');
            // Ne pas bloquer la suite si suppression échoue
          }
        }
        // Upload nouvelle image dans le bucket A
        photoUrl = await uploadImage(nouvelleImage);
      }

      await FirebaseFirestore.instance.collection('lieux').doc(lieuId).update({
        'nom': nom,
        'description': description,
        'ville': ville,
        'photoUrl': photoUrl,
      });
    } catch (e) {
      throw Exception('Erreur lors de la modification du lieu: $e');
    }
  }
}
