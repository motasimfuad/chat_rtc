import 'dart:developer';

import 'package:chat_rtc/src/core/services/cache/cache_keys.dart';
import 'package:chat_rtc/src/core/services/cache/cache_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  bool get isLoggedIn => _auth.currentUser != null;

  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      log(result.toString());

      await _persistUserData(result.user);

      return result.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _persistUserData(result.user);

      return result.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _clearPersistedUserData();
  }

  Future<void> _persistUserData(User? user) async {
    if (user != null) {
      await CacheService.setString(CacheKeys.userId, user.uid);
      await CacheService.setString(CacheKeys.userEmail, user.email ?? '');
    }
  }

  Future<void> _clearPersistedUserData() async {
    await CacheService.remove(CacheKeys.userId);
    await CacheService.remove(CacheKeys.userEmail);
  }

  Future<bool> checkPersistedUser() async {
    final userId = CacheService.getString(CacheKeys.userId);
    return userId != null;
  }

  String _handleAuthException(FirebaseAuthException e) {
    log('e.code ${e.code}');
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided for that user.';
      case 'invalid-credential':
        return 'The credential is invalid.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
