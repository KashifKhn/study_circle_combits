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
    apiKey: 'AIzaSyB3Aef7lkiuDiax9N0JMlrpt0n11IdtS24',
    appId: '1:685756734807:web:57459c66799d67e487f212',
    messagingSenderId: '685756734807',
    projectId: 'studycircle-3d924',
    authDomain: 'studycircle-3d924.firebaseapp.com',
    storageBucket: 'studycircle-3d924.firebasestorage.app',
    measurementId: 'G-FNWQJR1CJK',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAr7wzhH7LhwfZW1u5H6ybvZ48-osdEA58',
    appId: '1:685756734807:android:72002a63728614a687f212',
    messagingSenderId: '685756734807',
    projectId: 'studycircle-3d924',
    storageBucket: 'studycircle-3d924.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDxqInGhlesudmIyiU7VcQU5ko30_XJe2Y',
    appId: '1:685756734807:ios:856ea98e962e22cc87f212',
    messagingSenderId: '685756734807',
    projectId: 'studycircle-3d924',
    storageBucket: 'studycircle-3d924.firebasestorage.app',
    iosBundleId: 'com.example.studyCircle',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDxqInGhlesudmIyiU7VcQU5ko30_XJe2Y',
    appId: '1:685756734807:ios:856ea98e962e22cc87f212',
    messagingSenderId: '685756734807',
    projectId: 'studycircle-3d924',
    storageBucket: 'studycircle-3d924.firebasestorage.app',
    iosBundleId: 'com.example.studyCircle',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyB3Aef7lkiuDiax9N0JMlrpt0n11IdtS24',
    appId: '1:685756734807:web:f79314368ffa4e0387f212',
    messagingSenderId: '685756734807',
    projectId: 'studycircle-3d924',
    authDomain: 'studycircle-3d924.firebaseapp.com',
    storageBucket: 'studycircle-3d924.firebasestorage.app',
    measurementId: 'G-ENJ2VTP8ME',
  );
}
