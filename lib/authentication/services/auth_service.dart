import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:project1/common/models/user_system.dart';

abstract class AuthService {
  Future<FirebaseUser?> currentUser();

  Future<FirebaseUser?> reloadUser();
  Future<void> sendEmailVerification();
  Future<FirebaseUser?> signInWithEmailAndPassword(
      String email, String password);
  Future<FirebaseUser?> createUserWithEmailAndPassword(
      String email, String password);
  Future<void> sendPasswordResetEmail(String email);
  Future<FirebaseUser?> signInWithGoogle();
  Future<FirebaseUser?> signInWithFacebook();
  Future<FirebaseUser?> signInWithApple();
  Future<FirebaseUser?> submitOtpAndAuthenticate(
      ConfirmationResult confirmationResult, String otp);
  Future<void> signOut();
  Stream<FirebaseUser?> get onAuthStateChanged;
  void dispose();
}
