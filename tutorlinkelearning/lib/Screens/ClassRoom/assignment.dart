import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';


import '../../Components/resourcemangement.dart';
import 'models/dialog.dart';

class AssignmentsPage extends StatefulWidget {
  final String courseId;
  const AssignmentsPage({required this.courseId});

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
          title: Text('Enter Submission Title'),
          content: TextField(
            onChanged: (value) {
              assignmentTitle = value;
            },
            decoration: InputDecoration(hintText: 'eg.CSM4 Assignment submission'),
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
        String studentId = _auth.currentUser!.uid;
        String courseId = widget.courseId;

        List<Map<String, dynamic>> assignmentList = [];
        List<Map<String, dynamic>> atimestampList = [];

        // Check if a doc already exists for the current student and tutor
        QuerySnapshot tutorDocuments = await _firestore
            .collection('Classroom')
            .where('studentId', isEqualTo: studentId)
            .where('courseId', isEqualTo: courseId)
            .get();

        String tutorDocumentId;

        if (tutorDocuments.docs.isEmpty) {
          // If no document exists, create a new one
          DocumentReference tutorDocumentRef =
              await _firestore.collection('Classroom').add({
            'courseId': courseId,
            'studentId': studentId,
          });
          // Get the id of the newly created document
          tutorDocumentId = tutorDocumentRef.id;

        
        
        } else {
          // If a document already exists, get the first document (as there should be only one)
          DocumentSnapshot tutorDocument = tutorDocuments.docs.first;
          // Get the ID of the existing document
          tutorDocumentId = tutorDocument.id;

          // Retrieve the existing assignment and timestamps from Firestore
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
      // Handling error
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
            .where('studentId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
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
