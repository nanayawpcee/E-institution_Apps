import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:thetutorlink/Screens/ClassRoom/models/showdialog.dart';

import '../../Components/resourcemangement.dart';

class ResourcePage extends StatefulWidget {
  final String studentId;

  const ResourcePage({required this.studentId,});

  @override
  State<ResourcePage> createState() => _ResourcePageState();
}

class _ResourcePageState extends State<ResourcePage> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  String? resourceID = '';
  String classid = '';


  Future<String> _uploadFile(File file) async {
  try {
    final filePath = '${file.path.split('/').last}';
    final storageRef = _storage.ref().child(filePath);
    await storageRef.putFile(file);
    final downloadUrl = await storageRef.getDownloadURL();
    return downloadUrl;
  } catch (e) {
    // Handle file upload error
    print('Error uploading file: $e');
    return '';
  }
}


   @override
  void initState() {
    super.initState();
    _loadClassId();
    print('Classid3: $classid');
  
  }


  Future<void> _loadClassId() async {
    try {
      DocumentSnapshot tutorSnapshot = await FirebaseFirestore.instance
          .collection('Tutors')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      if (tutorSnapshot.exists) {
        List<dynamic> classrooms = tutorSnapshot.get('classrooms');
        for (var classroom in classrooms) {
          if (classroom is Map && classroom.containsKey(widget.studentId)) {
            setState(() {
              classid = classroom[widget.studentId];
              print('class id: $classid');
            });
            break;
          }
        }
      }
    } catch (error) {
      print("Error loading classId: $error");
    }
  }


  Future<String?> _showTitleInputDialog(BuildContext context) async {
    String? resourceTitle = '';

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter Resource Title'),
          content: TextField(
            onChanged: (value) {
              resourceTitle = value;
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
                Navigator.pop(context, resourceTitle);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
Future<void> _sendFiles(List<File> files,) async {
  try {
    if (files.isNotEmpty) {

      List<Map<String, dynamic>> resourceList = [];
      List<Map<String, dynamic>> timestampList = [];

      // Check if a document already exists for the given classId
      DocumentSnapshot classDocument = await _firestore
          .collection('Classroom')
          .doc(classid)
          .get();

      if (!classDocument.exists) {
        // Handle case where the class document does not exist
        print('Class document with ID $classid does not exist.');
        return;
      }

      // Retrieve the existing assignments and timestamps from the class document
      List<dynamic> existingAssignment = classDocument['resources'];
      List<dynamic> existingaTimestamps = classDocument['timestamps'];

      // Add the existing assignments and timestamps to the lists
      resourceList.addAll(existingAssignment.cast<Map<String, dynamic>>());
      timestampList.addAll(existingaTimestamps.cast<Map<String, dynamic>>());

      // Upload files and get their URLs and timestamps
      for (File file in files) {
        String resourceUrl = await _uploadFile(file);
        String? resourceTitle = await _showTitleInputDialog(context);
        if (resourceTitle != null && resourceTitle.isNotEmpty) {
          // Add each resource as a map to the assignmentList
          resourceList.add({
            'title': resourceTitle,
            'url': resourceUrl,
          });

          // Add each timestamp as a map to the atimestampList
          timestampList.add({
            'title': resourceTitle,
            'time': Timestamp.now(),
          });
        }
      }

      // Update the 'assignments' and 'atimestamps' fields in the class document
      await _firestore.collection('Classroom').doc(classid).update({
        'resources': resourceList,
        'timestamps': timestampList,
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
        title: const Text('Resources Screen'),
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
            .where('classId', isEqualTo: classid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No resources available.'));
          }
          resourceID = snapshot.data!.docs.first.id;
          //  print(resourceID);

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final resources = doc['resources'] as List<dynamic>;
              final timestamps = doc['timestamps'] as List<dynamic>;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < resources.length; i++)
                    ResourceItem(
                      tutorId: FirebaseAuth.instance.currentUser!.uid,
                      resourceTitle: resources[i]['title'],
                      resourceUrl: resources[i]['url'],
                      timestamp: timestamps[i]['time'].toDate(),
                      tutorDocumentId: resourceID!,
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
