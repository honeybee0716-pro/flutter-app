import 'package:meta/meta.dart';

@immutable
class FirebaseUser {
  const FirebaseUser({
    required this.uid,
    required this.email,
    this.photoUrl,
    this.displayName,
    required this.isVerified,
    this.isNew = false,
    required this.providerId,
  });

  final String uid;
  final String email;
  final String? photoUrl;
  final String? displayName;
  final bool isVerified;
  final bool isNew;
  final String? providerId;

  const FirebaseUser.notFound()
      : uid = '',
        email = '',
        photoUrl = '',
        displayName = '',
        isVerified = false,
        isNew = false,
        providerId = '';
}
