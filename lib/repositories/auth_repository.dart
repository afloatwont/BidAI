import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream to monitor auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email & password
  Future<UserCredential> signUp(String email, String password) async {
    try {
      // Register user with Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Create user document in Firestore
      await _createUserDocument(userCredential.user!);
      
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with email & password
  Future<UserCredential> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Create user document in Firestore
  Future<void> _createUserDocument(User user) async {
    final userModel = UserModel(
      uid: user.uid,
      email: user.email!,
      createdAt: DateTime.now(),
    );
    
    await _firestore.collection('users').doc(user.uid).set(userModel.toMap());
  }
}