import 'package:firebase_auth/firebase_auth.dart';


//firebase sign up method
Future<User?> signUpWithEmailAndPassword(String email, String password) async {
  try {
    FirebaseAuth auth = FirebaseAuth.instance;
    UserCredential userCredential = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  } catch (e) {
    // Handle registration errors here
    print('User registration failed: $e');
    return null;
  }
}
