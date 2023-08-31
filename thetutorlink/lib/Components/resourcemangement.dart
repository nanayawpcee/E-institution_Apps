import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:thetutorlink/constants.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';

class ResourceItem extends StatelessWidget {
  final String tutorId;
  final String tutorDocumentId;
  final String resourceTitle;
  final String resourceUrl;
  final DateTime timestamp; // Changed from Timestamp to DateTime

  ResourceItem({
    required this.tutorId,
    required this.tutorDocumentId,
    required this.resourceTitle,
    required this.resourceUrl,
    required this.timestamp,
  });

  String formatDate(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void _downloadResource(BuildContext context) async {

    FileDownloader.downloadFile(
      url: resourceUrl,
      name: resourceTitle,
      onDownloadCompleted: (String filePath) {
          _showSnackBar(context, 'Download complete: $resourceTitle');
      },
      onDownloadError: (String error) {
         print('Error during download: $error');
        _showSnackBar(context, 'Download failed: $resourceTitle');
      },
    );
  }

  void _deleteResource(BuildContext context, String tutorDocumentId) async {
    final FirebaseStorage storage = FirebaseStorage.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    await storage.refFromURL(resourceUrl).delete();

    // Delete the resource entry from the Firestore document
    final DocumentSnapshot classroomDoc =
        await firestore.collection('Classroom').doc(tutorDocumentId).get();

    if (classroomDoc.exists) {
      final List<Map<String, dynamic>> resources =
          List.from(classroomDoc['resources']);
      final List<Map<String, dynamic>> timestamps =
          List.from(classroomDoc['timestamps']);

      // Find the index of the resource in the lists
      final int resourceIndex =
          resources.indexWhere((resource) => resource['url'] == resourceUrl);

      if (resourceIndex != -1) {
        // Remove the resource and timestamp entries from the lists
        resources.removeAt(resourceIndex);
        timestamps.removeAt(resourceIndex);

        // Update the Firestore document with the modified lists
        await firestore.collection('Classroom').doc(tutorDocumentId).update({
          'resources': resources,
          'timestamps': timestamps,
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: ListTile(
        tileColor: kGreyColor600,
        leading: Icon(Icons.insert_drive_file),
        iconColor: kBlueColor,
        title: Text(resourceTitle),
        subtitle: Text(formatDate(timestamp)),
        onLongPress: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.download),
                    title: Text('Download'),
                    onTap: () {
                      Navigator.pop(context);
                      _downloadResource(context); // Call the download function
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.delete),
                    title: Text('Delete'),
                    onTap: () {
                      Navigator.pop(context);
                      _deleteResource(
                          context, tutorDocumentId); // Call the delete function
                    },
                  ),
                ],
              );
            },
          );
        },
        onTap: () {
          // Handle resource item tap
        },
      ),
    );
  }
}
