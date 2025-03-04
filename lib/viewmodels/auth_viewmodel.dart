import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/auth_repository.dart';

// Auth repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// Auth state provider
final authStateProvider = StreamProvider<User?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges;
});

// Auth view model provider
final authViewModelProvider = StateNotifierProvider<AuthViewModel, AsyncValue<User?>>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthViewModel(authRepository);
});

class AuthViewModel extends StateNotifier<AsyncValue<User?>> {
  final AuthRepository _authRepository;

  AuthViewModel(this._authRepository) : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() {
    final user = _authRepository.currentUser;
    state = AsyncValue.data(user);
  }

  // Sign up with email and password
  Future<void> signUp(String email, String password) async {
    try {
      state = const AsyncValue.loading();
      final userCredential = await _authRepository.signUp(email, password);
      state = AsyncValue.data(userCredential.user);
    } on FirebaseAuthException catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // Sign in with email and password
  Future<void> signIn(String email, String password) async {
    try {
      state = const AsyncValue.loading();
      final userCredential = await _authRepository.signIn(email, password);
      state = AsyncValue.data(userCredential.user);
    } on FirebaseAuthException catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _authRepository.signOut();
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}