import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (credential.user == null) {
      throw FirebaseAuthException(
        code: 'user-creation-failed',
        message: 'The user account could not be created.',
      );
    }

    return credential.user!;
  }

  Future<User> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (credential.user == null) {
      throw FirebaseAuthException(
        code: 'sign-in-failed',
        message: 'Login failed.',
      );
    }

    return credential.user!;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  String getErrorMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'email-already-in-use':
        return 'An account already exists with this email.';

      case 'invalid-email':
        return 'Please enter a valid email address.';

      case 'weak-password':
        return 'Please choose a stronger password.';

      case 'invalid-credential':
      case 'user-not-found':
      case 'wrong-password':
        return 'Invalid email or password.';

      case 'user-disabled':
        return 'This account has been disabled.';

      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';

      case 'network-request-failed':
        return 'Please check your internet connection.';

      default:
        return error.message ?? 'Authentication failed. Please try again.';
    }
  }
}
