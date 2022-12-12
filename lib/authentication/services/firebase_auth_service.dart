import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:project1/common/models/user_system.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'auth_service.dart';

class FirebaseAuthService implements AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  bool? isNewUser;

  FirebaseUser? _userFromFirebase(User? user) {
    if (user == null) {
      return null;
    }

    return FirebaseUser(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
        photoUrl: user.photoURL,
        isVerified: user.emailVerified,
        isNew: isNewUser ?? false,
        providerId: user.providerData[0].providerId);
  }

  @override
  Stream<FirebaseUser?> get onAuthStateChanged {
    return _firebaseAuth.authStateChanges().map(_userFromFirebase);
  }

  @override
  Future<FirebaseUser?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final UserCredential authResult =
          await _firebaseAuth.signInWithCredential(EmailAuthProvider.credential(
        email: email,
        password: password,
      ));
      isNewUser = authResult.additionalUserInfo?.isNewUser;
      return _userFromFirebase(authResult.user);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<FirebaseUser?> createUserWithEmailAndPassword(
      String email, String password) async {
    final UserCredential authResult = await _firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: password);
    // Sending email verification
    if (authResult.user != null) await authResult.user!.sendEmailVerification();
    return _userFromFirebase(authResult.user);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<FirebaseUser?> signInWithGoogle() async {
    GoogleSignIn googleSignIn = GoogleSignIn();
    if (kIsWeb) {
      googleSignIn = GoogleSignIn(
        scopes: [
          'email',
          'https://www.googleapis.com/auth/contacts.readonly',
        ],
      );
    }
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser != null) {
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.accessToken != null && googleAuth.idToken != null) {
        final UserCredential authResult = await _firebaseAuth
            .signInWithCredential(GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.accessToken,
        ));
        isNewUser = authResult.additionalUserInfo!.isNewUser;
        return _userFromFirebase(authResult.user);
      } else {
        throw PlatformException(
            code: 'ERROR_MISSING_GOOGLE_AUTH_TOKEN',
            message: 'Missing Google Auth Token');
      }
    } else {
      throw PlatformException(
          code: 'ERROR_ABORTED_BY_USER', message: 'Sign in aborted by user');
    }
  }

  @override
  Future<FirebaseUser?> submitOtpAndAuthenticate(
      ConfirmationResult confirmationResult, String otp) async {
    try {
      UserCredential userCredential = await confirmationResult.confirm(otp);
      isNewUser = userCredential.additionalUserInfo?.isNewUser;
      return _userFromFirebase(userCredential.user);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<FirebaseUser?> reloadUser() async {
    final User? user = _firebaseAuth.currentUser;
    await user!.reload();
    return _userFromFirebase(user);
  }

  @override
  Future<FirebaseUser?> signInWithApple() async {
    // To prevent replay attacks with the credential returned from Apple, we
    // include a nonce in the credential request. When signing in with
    // Firebase, the nonce in the id token returned by Apple, is expected to
    // match the sha256 hash of `rawNonce`.
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    // Request credential for the currently signed in Apple account.
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    // Create an `OAuthCredential` from the credential returned by Apple.
    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );

    // Sign in the user with Firebase. If the nonce we generated earlier does
    // not match the nonce in `appleCredential.identityToken`, sign in will fail.
    final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(oauthCredential);
    return _userFromFirebase(userCredential.user);
  }

  @override
  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  @override
  void dispose() {}

  @override
  Future<void> sendEmailVerification() async {
    final User? user = _firebaseAuth.currentUser;
    await user!.sendEmailVerification();
  }

  @override
  Future<FirebaseUser?> currentUser() async {
    final User? user = _firebaseAuth.currentUser;
    return _userFromFirebase(user);
  }

  /// Generates a cryptographically secure random nonce, to be included in a
  /// credential request.
  String generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  @override
  Future<FirebaseUser?> signInWithFacebook() async {
    final LoginResult result = await FacebookAuth.instance.login();

    if (result.accessToken != null) {
      final UserCredential authResult =
          await _firebaseAuth.signInWithCredential(
        FacebookAuthProvider.credential(result.accessToken!.token),
      );

      isNewUser = authResult.additionalUserInfo!.isNewUser;
      return _userFromFirebase(authResult.user);
    } else {
      throw PlatformException(
          code: 'ERROR_ABORTED_BY_USER', message: 'Sign in aborted by user');
    }
  }
}
