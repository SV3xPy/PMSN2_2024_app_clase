import 'package:firebase_auth/firebase_auth.dart';

class GoogleAuthFirebase {
  final auth = FirebaseAuth.instance;
  Future<bool> signUpUser() async {
    try {
      GoogleAuthProvider _googleAuthProvider = GoogleAuthProvider();
      final userCredential = await auth.signInWithProvider(_googleAuthProvider);
      if (userCredential.user != null) {
        //Se valida el correo usando firebase
        if (userCredential.user != null) {
          userCredential.user!.sendEmailVerification();
          return true;
        }
      }
      return false;
    } catch (error) {
      return false;
    }
  }
}
