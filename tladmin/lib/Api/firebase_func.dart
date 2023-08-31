import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as fstorage;

import 'package:flutter/material.dart';


Future<void> pickCourseOverviewVideo(context, String courseId) async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.video,
    dialogTitle: 'Select Course Overview Video',
  );

  if (result != null && result.files.isNotEmpty) {
   
    // code to upload video and get URL
    File videoFile = File(result.files.single.path!);
    String videoName = result.files.single.name;
    // Upload videoFile to Firebase Storage and get the URL
    String videoUrl = await uploadCourseOverviewVideo(videoFile, videoName);

    // Update the course document in Firestore
    await FirebaseFirestore.instance
        .collection('Courses')
        .doc(courseId)  // Replace with the actual course ID
        .update({'courseOverviewVideo': videoUrl});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Course overview video uploaded successfully')),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('No video selected')),
    );
  }
}

Future<String> uploadCourseOverviewVideo(File videoFile, String videoName) async {
  fstorage.Reference ref = fstorage.FirebaseStorage.instance
      .ref()
      .child('course_videos')
      .child('/' + videoName);

  fstorage.UploadTask uploadTask = ref.putFile(videoFile);

  await uploadTask.whenComplete(() => null);
  String videoUrl = await ref.getDownloadURL();
  return videoUrl;
}
