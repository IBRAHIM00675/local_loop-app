// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return macos;
      case TargetPlatform.windows:
        return windows;
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
    apiKey: 'AIzaSyDU6Hjbw6VStvfe8-yZzuf6QIsgex8gVkg',
    appId: '1:608390507938:web:2cf39dfd3ef81cf22d96fb',
    messagingSenderId: '608390507938',
    projectId: 'localloop-app-development',
    authDomain: 'localloop-app-development.firebaseapp.com',
    storageBucket: 'localloop-app-development.firebasestorage.app',
    measurementId: 'G-0RLMJJXHLW',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCp3ZzL53CN9c-FNv0WMRQCyT3wLL66nLY',
    appId: '1:608390507938:android:4fef402e166dabb02d96fb',
    messagingSenderId: '608390507938',
    projectId: 'localloop-app-development',
    storageBucket: 'localloop-app-development.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAwOPfow6Srrg3Zg0r9fbTk2Ba2XijBLSY',
    appId: '1:608390507938:ios:5a52ba2f5dd4b1e32d96fb',
    messagingSenderId: '608390507938',
    projectId: 'localloop-app-development',
    storageBucket: 'localloop-app-development.firebasestorage.app',
    iosBundleId: 'com.example.localLoop',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAwOPfow6Srrg3Zg0r9fbTk2Ba2XijBLSY',
    appId: '1:608390507938:ios:5a52ba2f5dd4b1e32d96fb',
    messagingSenderId: '608390507938',
    projectId: 'localloop-app-development',
    storageBucket: 'localloop-app-development.firebasestorage.app',
    iosBundleId: 'com.example.localLoop',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDU6Hjbw6VStvfe8-yZzuf6QIsgex8gVkg',
    appId: '1:608390507938:web:18ffd73a734719e72d96fb',
    messagingSenderId: '608390507938',
    projectId: 'localloop-app-development',
    authDomain: 'localloop-app-development.firebaseapp.com',
    storageBucket: 'localloop-app-development.firebasestorage.app',
    measurementId: 'G-JGQ0WCNYZD',
  );
}
