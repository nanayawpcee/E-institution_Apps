
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:thetutorlink/Api/classroomgen.dart';


class RequestCard extends StatelessWidget {
  final String studentName;
  final String studentImageUrl;
  final int status;
  final String requestId;
  final String studentId;
  final VoidCallback onAccept; // Add this callback
  final VoidCallback onReject;

  RequestCard({
    required this.studentId,
    required this.requestId,
    required this.studentName,
    required this.studentImageUrl,
    required this.status,
    required this.onAccept, // Include the callback
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (status == 2) {
          _showConfirmationDialog(context, requestId);
        }
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(studentImageUrl),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      studentName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Status: ${getStatusText(status)}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  void _showConfirmationDialog(BuildContext context, String requestId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        bool isProcessing = false; // Flag to track processing status

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Confirm Action'),
              content: isProcessing
                  ? Center(child: CircularProgressIndicator())
                  : Text('Do you want to accept or reject the student?'),
              actions: [
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      isProcessing = true; // Show the loading indicator
                    });

                    Navigator.pop(dialogContext);
                    // Fetch courseId from the request document
                    final requestDoc = await FirebaseFirestore.instance
                        .collection('Requests')
                        .doc(requestId)
                        .get();
                    final courseId = requestDoc['courseId'] as String?;

                    if (courseId != null) {
                      final tutorId = FirebaseAuth.instance.currentUser!.uid;
                      onAccept();
                      await _updateStudentData(studentId, courseId, tutorId);
                      await _updateTutorStudentsArray(tutorId, studentId);
                      await createClassroomDocument(
                          studentId, tutorId, courseId);

                      Navigator.pop(dialogContext); // Close the dialog
                    }
                    setState(() {
                      isProcessing = false; // Hide the loading indicator
                    });
                  },
                  child: Text('Accept'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(dialogContext);
                    onReject();
                  },
                  child: Text('Reject'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _updateTutorStudentsArray(
      String tutorId, String studentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('Tutors')
          .doc(tutorId)
          .update({
        'students': FieldValue.arrayUnion([studentId]),
      });
    } catch (error) {
      print('Error updating tutor\'s students array: $error');
    }
  }

  Future<void> _updateStudentData(
      String studentId, String courseId, String tutorId) async {
    try {
      await FirebaseFirestore.instance
          .collection('Students')
          .doc(studentId)
          .update({
        'Active': FieldValue.arrayUnion([courseId]),
        'All': FieldValue.arrayUnion([courseId]),
        'tutors': FieldValue.arrayUnion([tutorId]),
        'Pending': FieldValue.arrayRemove([courseId])
      });
    } catch (error) {
      print('Error updating student\'s ActiveCourses array: $error');
    }
  }
}


String getStatusText(int status) {
  switch (status) {
    case 0:
      return 'All';
    case 1:
      return 'Accepted';
    case 2:
      return 'Pending';
    case 3:
      return 'Rejected';
    default:
      return 'Unknown';
  }
}
