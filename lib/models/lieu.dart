class Lieu {
  final String
  id; // doit venir de Firestore ou d'ailleurs, pas de uuid local ici
  final String uid;
  final String nom;
  final String description;
  final String ville;
  final String photoUrl;

  Lieu({
    required this.id, // Recevoir id du document Firestore
    required this.uid,
    required this.nom,
    required this.description,
    required this.ville,
    required this.photoUrl,
  });

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'nom': nom,
    'description': description,
    'ville': ville,
    'photoUrl': photoUrl,
  };

  static Lieu fromMap(String id, Map<String, dynamic> map) {
    return Lieu(
      id: id,
      uid: map['uid'] ?? '',
      nom: map['nom'] ?? '',
      description: map['description'] ?? '',
      ville: map['ville'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
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