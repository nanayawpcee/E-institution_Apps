import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseFunctions {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // this is get the user image from Firestore
  Future<String?> getUserImage() async {
    final userDocumentRef = FirebaseFirestore.instance
        .collection('Students')
        .doc(_auth.currentUser!.uid);

    final userSnapshot = await userDocumentRef.get();

    if (userSnapshot.exists) {
      return userSnapshot.data()!['userImage'];
    } else {
      return null;
    }
  }

  // this is also to get student details based on student Ids
  Future<List<Map<String, dynamic>>> gettutorDetails(
      List<String> tutorIds) async {
    final List<Map<String, dynamic>> tutors = [];

    for (final tutorId in tutorIds) {
      final tutorDoc = await FirebaseFirestore.instance
          .collection('Tutors')
          .doc(tutorId)
          .get();

      if (tutorDoc.exists) {
        tutors.add(tutorDoc.data() as Map<String, dynamic>);
      }
    }

    return tutors;
  }
}
