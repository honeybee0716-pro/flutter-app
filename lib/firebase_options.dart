// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDwgsxUPOO1Vsq6aoLTfRgUD-jWQGr67-s',
    appId: '1:286050939937:web:22cf7fca8275c9f14c9f60',
    messagingSenderId: '286050939937',
    projectId: 'fullaccezz-2756a',
    authDomain: 'fullaccezz-2756a.firebaseapp.com',
    databaseURL: 'https://fullaccezz-2756a-default-rtdb.firebaseio.com',
    storageBucket: 'fullaccezz-2756a.appspot.com',
    measurementId: 'G-NSFRXJG38D',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC63LpQL5iCYqlj-xuvugK9Y_DaLxs8-y0',
    appId: '1:286050939937:android:9bb7fcb356dd3a4b4c9f60',
    messagingSenderId: '286050939937',
    projectId: 'fullaccezz-2756a',
    databaseURL: 'https://fullaccezz-2756a-default-rtdb.firebaseio.com',
    storageBucket: 'fullaccezz-2756a.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC4ep-we1wExf9b5pHmO78qekl1Je2QoXs',
    appId: '1:286050939937:ios:a1ccaf85617ec0eb4c9f60',
    messagingSenderId: '286050939937',
    projectId: 'fullaccezz-2756a',
    databaseURL: 'https://fullaccezz-2756a-default-rtdb.firebaseio.com',
    storageBucket: 'fullaccezz-2756a.appspot.com',
    iosClientId: '286050939937-r0lorqhu50umu74gpvtaumtp59ru1i4r.apps.googleusercontent.com',
    iosBundleId: 'com.bundle.mynuu',
  );
}