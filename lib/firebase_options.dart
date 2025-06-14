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
    apiKey: 'AIzaSyD7DeGb7dZ6PLJ3sapp8TNxj5smsihUXe4',
    appId: '1:742248438948:web:cf69ce9ad2a3b43d481a31',
    messagingSenderId: '742248438948',
    projectId: 'haushalt-8548c',
    authDomain: 'haushalt-8548c.firebaseapp.com',
    storageBucket: 'haushalt-8548c.firebasestorage.app',
    measurementId: 'G-RKQTKPE3LC',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCTbzibBisnmdRyGyZ7jYuhpbx2L2NbWMk',
    appId: '1:742248438948:android:c4b3e94620a51eb6481a31',
    messagingSenderId: '742248438948',
    projectId: 'haushalt-8548c',
    storageBucket: 'haushalt-8548c.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBAl-YZjrk4FhmIGEJ_jFqN_G2si7rqUHc',
    appId: '1:742248438948:ios:c02c2670c4415dd5481a31',
    messagingSenderId: '742248438948',
    projectId: 'haushalt-8548c',
    storageBucket: 'haushalt-8548c.firebasestorage.app',
    iosBundleId: 'com.example.haushaltApp',
  );
}
