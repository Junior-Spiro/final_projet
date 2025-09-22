class UserModel {
  final String id; // UID Firebase
  final String email;
  final String displayName;

  UserModel({required this.id, required this.email, required this.displayName});

  // Pour convertir un document JSON Firestore en UserModel
  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      id: data['uid'] ?? '',
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'uid': id, 'email': email, 'displayName': displayName};
  }
}
