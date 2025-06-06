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
    apiKey: 'AIzaSyA6lS--MGbWpW3NB5caf6iWef2j61UmNBY',
    appId: '1:263198672727:web:c0a5a6e83206730f80e012',
    messagingSenderId: '263198672727',
    projectId: 'moneytracker-lyf',
    authDomain: 'moneytracker-lyf.firebaseapp.com',
    storageBucket: 'moneytracker-lyf.firebasestorage.app',
    measurementId: 'G-PFBQWWZKY6',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA1ZdiKI2v6w3dQRMNXXod4QHgxpc3tjN8',
    appId: '1:263198672727:android:5c603cf627535c9f80e012',
    messagingSenderId: '263198672727',
    projectId: 'moneytracker-lyf',
    storageBucket: 'moneytracker-lyf.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCzl-BG_oaVrQTtxtnMLPSm_RWODXlxBxo',
    appId: '1:263198672727:ios:6857cbe4015059a880e012',
    messagingSenderId: '263198672727',
    projectId: 'moneytracker-lyf',
    storageBucket: 'moneytracker-lyf.firebasestorage.app',
    iosBundleId: 'com.example.tfgMonetrackerLeireyafer',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCzl-BG_oaVrQTtxtnMLPSm_RWODXlxBxo',
    appId: '1:263198672727:ios:6857cbe4015059a880e012',
    messagingSenderId: '263198672727',
    projectId: 'moneytracker-lyf',
    storageBucket: 'moneytracker-lyf.firebasestorage.app',
    iosBundleId: 'com.example.tfgMonetrackerLeireyafer',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA6lS--MGbWpW3NB5caf6iWef2j61UmNBY',
    appId: '1:263198672727:web:db5ed756ac18359180e012',
    messagingSenderId: '263198672727',
    projectId: 'moneytracker-lyf',
    authDomain: 'moneytracker-lyf.firebaseapp.com',
    storageBucket: 'moneytracker-lyf.firebasestorage.app',
    measurementId: 'G-YQS66G9PMD',
  );
}
