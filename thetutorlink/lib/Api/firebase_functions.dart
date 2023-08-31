import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseFunctions {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // this is get the user image from Firestore
  Future<String?> getUserImage() async {
    final userDocumentRef =
        FirebaseFirestore.instance.collection('Tutors').doc(_auth.currentUser!.uid);

    final userSnapshot = await userDocumentRef.get();

    if (userSnapshot.exists) {
      return userSnapshot.data()!['userImage'];
    } else {
      return null;
    }
  }

  // this is also to get student details based on student Ids
  Future<List<Map<String, dynamic>>> getStudentDetails(List<String> studentIds) async {
    final List<Map<String, dynamic>> students = [];

    for (final studentId in studentIds) {
      final studentDoc =
          await FirebaseFirestore.instance.collection('Students').doc(studentId).get();

      if (studentDoc.exists) {
        students.add(studentDoc.data() as Map<String, dynamic>);
      }
    }

    return students;
  }
}
