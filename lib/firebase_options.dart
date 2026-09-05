import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyCgLdocw6PP4Px7_T-bv3XXKvynzmevd_k',
    appId: '1:806176960963:web:a44c5f87f34c8f6fbecd76',
    messagingSenderId: '806176960963',
    projectId: 'project1-32aae',
    authDomain: 'project1-32aae.firebaseapp.com',
    storageBucket: 'project1-32aae.firebasestorage.app',
    measurementId: 'G-9KWYW8TDTS',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAkJ-3bk01duo6ebGYuGQcZVdS7e2ZwaNM',
    appId: '1:806176960963:android:369ec3db21631d68becd76',
    messagingSenderId: '806176960963',
    projectId: 'project1-32aae',
    storageBucket: 'project1-32aae.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCKt8ThMV-dDDQoWGR-zKw13ReILs2C1mA',
    appId: '1:806176960963:ios:1bb188c4ba0f9d68becd76',
    messagingSenderId: '806176960963',
    projectId: 'project1-32aae',
    storageBucket: 'project1-32aae.firebasestorage.app',
    iosBundleId: 'com.example.journly',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCKt8ThMV-dDDQoWGR-zKw13ReILs2C1mA',
    appId: '1:806176960963:ios:1bb188c4ba0f9d68becd76',
    messagingSenderId: '806176960963',
    projectId: 'project1-32aae',
    storageBucket: 'project1-32aae.firebasestorage.app',
    iosBundleId: 'com.example.journly',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCgLdocw6PP4Px7_T-bv3XXKvynzmevd_k',
    appId: '1:806176960963:web:b1342b592bfc009dbecd76',
    messagingSenderId: '806176960963',
    projectId: 'project1-32aae',
    authDomain: 'project1-32aae.firebaseapp.com',
    storageBucket: 'project1-32aae.firebasestorage.app',
    measurementId: 'G-NCK2SBCKEK',
  );
}
