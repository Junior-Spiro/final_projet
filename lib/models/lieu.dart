import 'package:cloud_firestore/cloud_firestore.dart';

class Lieu {
  final String
  id; // doit venir de Firestore ou d'ailleurs, pas de uuid local ici
  final String uid;
  final String nom;
  final String description;
  final String ville;
  final String photoUrl;
  final DateTime? createdAt; // Ajouté pour l’historique

  Lieu({
    required this.id, // Recevoir id du document Firestore
    required this.uid,
    required this.nom,
    required this.description,
    required this.ville,
    required this.photoUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'nom': nom,
    'description': description,
    'ville': ville,
    'photoUrl': photoUrl,
    'createdAt':
        createdAt, // Optionnel. ATTENTION : Ne pas envoyer un DateTime lors de
    //l'ajout, mais bien FieldValue.serverTimestamp() dans le service.
  };

  ///Lors de la lecture (fromMap), convertis le champ Timestamp (createdAt) en
  ///DateTime pour l’utiliser facilement dans Flutter.

  static Lieu fromMap(String id, Map<String, dynamic> map) {
    final timestamp = map['cretedAt'];
    DateTime date;
    if (timestamp is Timestamp) {
      date = timestamp.toDate();
    } else if (timestamp is DateTime) {
      date = timestamp;
    } else {
      date = DateTime.now(); // valeur par défaut si champ absent
    }
    return Lieu(
      id: id,
      uid: map['uid'] ?? '',
      nom: map['nom'] ?? '',
      description: map['description'] ?? '',
      ville: map['ville'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      createdAt: date,
    );
  }
}



/*
import 'package:uuid/uuid.dart';

class Lieu {
  final String id;
  final String uid;
  final String nom;
  final String description;
  final String ville;
  final String photoUrl; // URL issue de Firebase Storage

  static const uuid = Uuid();

  Lieu({
    required this.uid,
    required this.nom,
    required this.description,
    required this.ville,
    required this.photoUrl,
  }) : id = uuid.v4();

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'nom': nom,
    'description': description,
    'ville': ville,
    'photoUrl': photoUrl,
  };

  static Lieu fromMap(String id, Map<String, dynamic> map) {
    return Lieu(
      uid: map['uid'] ?? '',
      nom: map['nom'] ?? '',
      description: map['description'] ?? '',
      ville: map['ville'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
    )..id;
  }
}
*/