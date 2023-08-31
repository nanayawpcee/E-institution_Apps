import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> createClassroomDocument(
  String studentId,
  String tutorId,
  String courseId,
) async {
  try {
    final classroomRef = FirebaseFirestore.instance.collection('Classroom');
    
    final classroomDocRef = await classroomRef.add({
      'assignments': [],
      'atimestamps': [],
      'resources': [],
      'timestamps': [],
      'classId': '', 
      'courseId': courseId,
      'studentId': studentId,
      'tutorId': tutorId,
      'Starttime': FieldValue.serverTimestamp(), // Set to the current timestamp
    });

    // Fetch the classroom document snapshot to access the Starttime
    final classroomDocSnapshot = await classroomDocRef.get();
    final classroomData = classroomDocSnapshot.data() as Map<String, dynamic>;

    // Fetch course duration from Courses collection
    final courseDoc = await FirebaseFirestore.instance
        .collection('Courses')
        .doc(courseId)
        .get();
    final courseDuration = courseDoc['duration'] as double;

    // Calculate and set Endtime
    final startTime = (classroomData['Starttime'] as Timestamp).toDate();
    final endTime = startTime.add(Duration(hours: courseDuration.toInt()));

    // Update the classroom document with classId and Endtime
    await classroomDocRef.update({
      'classId': classroomDocRef.id,
      'Endtime': endTime,
    });

    // Prepare the data to update the Tutors collection
    final tutorDataToUpdate = {
      'classrooms': FieldValue.arrayUnion([
        {
          studentId: classroomDocRef.id, 
        },
      ]),
    };

    // Update the Tutors collection with the new classroom data
    await FirebaseFirestore.instance
        .collection('Tutors')
        .doc(tutorId)
        .update(tutorDataToUpdate);
  } catch (error) {
    print('Error creating classroom document: $error');
  }
}
