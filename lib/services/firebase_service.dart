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

      // Prépare les données avec timestamp serveur pour createdAt
      final data = {
        'uid': uid,
        'nom': nom,
        'description': description,
        'ville': ville,
        'photoUrl': photoUrl,
        'createdAt': FieldValue.serverTimestamp(), // <--- AJOUT
      };
      await docRef.set(data);
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

      // Met à jour sans toucher createdAt
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

  ///Méthode pour l'historique
  /// Récupère un Stream des lieux ajoutés par l'utilisateur [uid].
  ///
  /// Les lieux sont triés par date d'ajout (supposée stockée dans 'createdAt') du plus récent au plus ancien.
  /// [limit] permet de limiter le nombre de résultats, optionnel.
  /// [filtreVille] permet de filtrer sur la ville, optionnel.
  static Stream<List<Lieu>> getHistoriqueLieux({
    required String uid,
    int? limit,
    String? filtreVille,
  }) {
    // Base de la requête : filter uid + order by createdAt
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('lieux')
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true);

    // Ajoute le filtre ville si non-null
    if (filtreVille != null && filtreVille.isNotEmpty) {
      query = query.where('ville', isEqualTo: filtreVille);
    }

    // Ajoute la limite si fournie
    if (limit != null) {
      query = query.limit(limit);
    }

    // Transforme en List<Lieu>
    return query.snapshots().map((snap) {
      return snap.docs.map((doc) {
        final data = doc.data();
        // Assure que createdAt est bien un Timestamp
        final timestamp = data['createdAt'];
        final createdAt = timestamp is Timestamp
            ? timestamp.toDate()
            : DateTime.now();
        return Lieu(
          id: doc.id,
          uid: data['uid'] as String? ?? '',
          nom: data['nom'] as String? ?? '',
          description: data['description'] as String? ?? '',
          ville: data['ville'] as String? ?? '',
          photoUrl: data['photoUrl'] as String? ?? '',
          createdAt: createdAt, // Assigne la date convertie
        );
      }).toList();
    });
  }
}
