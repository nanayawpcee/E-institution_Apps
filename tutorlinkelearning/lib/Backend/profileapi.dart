import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as fstorage;
import 'package:flutter/material.dart';
import 'package:tutorlinkelearning/constants.dart';

class UserProfileFunctions {
  static Future<void> updateImageInFirestore(
      File imageXFile, Function setStateCallback) async {
    String fileName = DateTime.now().microsecondsSinceEpoch.toString();
    fstorage.Reference reference = fstorage.FirebaseStorage.instance
        .ref()
        .child('userImages')
        .child(fileName);

    fstorage.UploadTask uploadTask = reference.putFile(imageXFile);
    fstorage.TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
    String userImageUrl = await taskSnapshot.ref.getDownloadURL();
    await FirebaseFirestore.instance
        .collection('Students')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'userImage': userImageUrl,
    });

    setStateCallback(); // Call the callback to trigger a widget rebuild
  }

  static Future<void> updateUserContact(String userContactInput) async {
    await FirebaseFirestore.instance
        .collection('Students')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'contact': userContactInput,
    });
  }

  static Future<void> updateUserName(String userNameInput) async {
    await FirebaseFirestore.instance
        .collection('Students')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'name': userNameInput,
    });
  }

  static Future<void> showTextInputDialog(
      BuildContext context, String fieldToUpdate, String? userNameInput, String? userContactInput) async {
    String title = fieldToUpdate == 'name'
        ? 'Update Your Name Here'
        : 'Update Your Contact Here';
    String hintText = fieldToUpdate == 'name'
        ? 'Type your new name here'
        : 'Type your new contact here';
    Function updateFunction =
        fieldToUpdate == 'name' ? updateUserName : updateUserContact;

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: TextField(
              maxLength: fieldToUpdate == 'contact' ? 10 : 27,
              onChanged: (value) {
                if (fieldToUpdate == 'name') {
                  userNameInput = value;
                } else if (fieldToUpdate == 'contact') {
                  userContactInput = value;
                }
              },
              decoration: InputDecoration(
                hintText: hintText,
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kBlueColor,
                ),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  updateFunction();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kBlueColor,
                ),
                child: const Text('Save'),
              )
            ],
          );
        });
  }
}
