class UserModel {
  final String uid;
  final String email;
  final DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.email,
    this.createdAt,
  });

  // Convert UserModel to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'createdAt': createdAt ?? DateTime.now(),
    };
  }

  // Create UserModel from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      createdAt: map['createdAt']?.toDate(),
    );
  }
}