class UserModel {
  final String id; // UID Firebase
  final String email;
  final String displayName;
  final String? userPhotoUrl;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    required this.userPhotoUrl,
  });

  // Pour convertir un document JSON Firestore en UserModel
  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      id: data['uid'] ?? '',
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      userPhotoUrl: data['userPhotoUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': id,
      'email': email,
      'displayName': displayName,
      'userPhotoUrl': userPhotoUrl,
    };
  }
}
