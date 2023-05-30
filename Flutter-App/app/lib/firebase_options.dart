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
    apiKey: 'AIzaSyCrceZ5SAULEw_wrNk4S7-aPGdJmnudQFQ',
    appId: '1:36419882218:web:05daf8924fa97ba9d91b93',
    messagingSenderId: '36419882218',
    projectId: 'ssds-112',
    authDomain: 'ssds-112.firebaseapp.com',
    storageBucket: 'ssds-112.appspot.com',
    measurementId: 'G-ERPCPGHRFT',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCBDerz7aywNLTUnYCWlJshdKrHKmHg2Ak',
    appId: '1:36419882218:android:75428c08fd1ae145d91b93',
    messagingSenderId: '36419882218',
    projectId: 'ssds-112',
    storageBucket: 'ssds-112.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC9JRNb5wWk_ofhMX1TMyD_13Ay3zDCUZk',
    appId: '1:36419882218:ios:52092fe24ae7e4d8d91b93',
    messagingSenderId: '36419882218',
    projectId: 'ssds-112',
    storageBucket: 'ssds-112.appspot.com',
    iosClientId: '36419882218-lca69jhu5871bt9g8fekkndfvsf4vl47.apps.googleusercontent.com',
    iosBundleId: 'com.example.ssdsApp',
  );
}
