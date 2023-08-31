import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:thetutorlink/Screens/ClassRoom/models/showdialog.dart';

import '../../Components/resourcemangement.dart';

class AssignmentsPage extends StatefulWidget {
  final String studentId;
  const AssignmentsPage({required this.studentId});

  @override
  State<AssignmentsPage> createState() => _AssignmentsPageState();
}

class _AssignmentsPageState extends State<AssignmentsPage> {
  final _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  String? assignmentId = '';

  Future<String> _uploadFile(File file) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        // Handle user authentication error
        return '';
      }

      final filePath =
          'course_materials/${user.uid}/${file.path.split('/').last}';
      final storageRef = _storage.ref().child(filePath);
      await storageRef.putFile(file);
      return await storageRef.getDownloadURL();
    } catch (e) {
      // Handle file upload error
      print('Error uploading file: $e');
      return '';
    }
  }

  Future<String?> _showTitleInputDialog(BuildContext context) async {
    String? assignmentTitle = '';

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter Resource Title'),
          content: TextField(
            onChanged: (value) {
              assignmentTitle = value;
            },
            decoration: InputDecoration(hintText: 'e.g., Course Outline'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, assignmentTitle);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendFiles(List<File> files) async {
    try {
      if (files.isNotEmpty) {
        String tutorId = _auth.currentUser!.uid;
        String studentId = widget.studentId;

        List<Map<String, dynamic>> assignmentList = [];
        List<Map<String, dynamic>> atimestampList = [];

        // Check if a document already exists for the current student and tutor
        QuerySnapshot tutorDocuments = await _firestore
            .collection('Classroom')
            .where('studentId', isEqualTo: studentId)
            .where('tutorId', isEqualTo: tutorId)
            .get();

        String tutorDocumentId;

        if (tutorDocuments.docs.isEmpty) {
          // If no document exists, create a new one
          DocumentReference tutorDocumentRef =
              await _firestore.collection('Classroom').add({
            'tutorId': tutorId,
            'studentId': studentId,
          });
          // Get the ID of the newly created document
          tutorDocumentId = tutorDocumentRef.id;

          // Store the document ID in the 'resources' array in the 'Tutors' collection
          await _firestore.collection('Tutors').doc(tutorId).update({
            'assignments': FieldValue.arrayUnion([tutorDocumentId]),
          });
        } else {
          // If a document already exists, get the first document (as there should be only one)
          DocumentSnapshot tutorDocument = tutorDocuments.docs.first;
          // Get the ID of the existing document
          tutorDocumentId = tutorDocument.id;

          // Retrieve the existing resources and timestamps from Firestore
          List<dynamic> existingAssignment = tutorDocument['assignments'];
          List<dynamic> existingaTimestamps = tutorDocument['atimestamps'];

          // Add the existing resources and timestamps to the lists
          assignmentList
              .addAll(existingAssignment.cast<Map<String, dynamic>>());
          atimestampList
              .addAll(existingaTimestamps.cast<Map<String, dynamic>>());
        }

        // Upload files and get their URLs and timestamps
        for (File file in files) {
          String assignmentUrl = await _uploadFile(file);
          String? assignmentTitle = await _showTitleInputDialog(context);
          if (assignmentTitle != null && assignmentTitle.isNotEmpty) {
            // Add each resource as a map to the resourceList
            assignmentList.add({
              'title': assignmentTitle,
              'url': assignmentUrl,
            });

            // Add each timestamp as a map to the timestampList
            atimestampList.add({
              'title': assignmentTitle,
              'time': Timestamp.now(),
            });
          }
        }

        // Update the 'resources' and 'timestamps' fields in the tutor document
        await _firestore.collection('Classroom').doc(tutorDocumentId).update({
          'assignments': assignmentList,
          'atimestamps': atimestampList,
        });
      }
    } catch (e) {
      // Handle error
      print('Error sending files: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignments'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
      body: StreamBuilder(
        stream: _firestore
            .collection('Classroom')
            .where('studentId', isEqualTo: widget.studentId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No Assignments available.'));
          }
          assignmentId = snapshot.data!.docs.first.id;

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final assignments = doc['assignments'] as List<dynamic>;
              final timestamps = doc['atimestamps'] as List<dynamic>;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < assignments.length; i++)
                    ResourceItem(
                      resourceTitle: assignments[i]['title'],
                      resourceUrl: assignments[i]['url'],
                      timestamp: timestamps[i]['time'].toDate(),
                      tutorDocumentId: assignmentId!,
                      tutorId: FirebaseAuth.instance.currentUser!.uid,
                    ),
                  const Divider(),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            showMaterialDialog(context, _sendFiles);
          }),
    );
  }
}
