import 'package:firebase_auth/firebase_auth.dart';

class EmailAuthFirebase {
  final auth = FirebaseAuth.instance;

  //Para dar de Alta un usuario.
  Future<bool> signUpUser(
      {required String name,
      required String password,
      required String email}) async {
    try {
      final UserCredential = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      if (UserCredential.user != null) {
        //Se valida el correo usando firebase
        if (UserCredential.user != null) {
          UserCredential.user!.sendEmailVerification();
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> signInUser(
      {required String email, required String password}) async {
        var band = false;
        final userCredential = await auth.signInWithEmailAndPassword(email: email, password: password);
        if(userCredential.user!=null){
          if(userCredential.user!.emailVerified){
            band=true;
          }
        }
        return band;
      }
}
