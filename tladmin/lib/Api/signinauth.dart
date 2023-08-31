import 'package:firebase_auth/firebase_auth.dart';

//firebase signin method 
Future<User?> signInWithEmailAndPassword(String email, String password) async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
    return userCredential.user;
  } on FirebaseAuthException catch (e) {
    print('Sign-in error: ${e.message}');
    return null;
  }
}
