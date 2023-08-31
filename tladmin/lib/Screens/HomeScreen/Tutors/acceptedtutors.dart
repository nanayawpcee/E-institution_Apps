import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as fstorage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:tladmin/constants.dart';
import 'package:tladmin/utils/passwordgen.dart';

import '../../../Components/inputtextform.dart';

class AddAcceptedTutorScreen extends StatefulWidget {
  static String routeName = 'AddAcceptedTutors';

  @override
  _AddAcceptedTutorScreenState createState() => _AddAcceptedTutorScreenState();
}

class _AddAcceptedTutorScreenState extends State<AddAcceptedTutorScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _tutorBioController = TextEditingController();
  final TextEditingController _courseNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String selectedImage = '';
  Uint8List? selectedIconBytes;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.only(top: 40),
          decoration: BoxDecoration(
            color: kGreyColor700,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height / 2,
                width: MediaQuery.of(context).size.width / 3,
                child: Column(
                  children: [
                    InputField(
                      hintText: 'Enter Tutor Name',
                      icon: Icons.person,
                      textEditingController: _nameController,
                    ),
                    const SizedBox(height: 10),
                    InputField(
                      length: 30,
                      hintText: 'Enter Tutor Email',
                      icon: Icons.email_outlined,
                      textEditingController: _emailController,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    InputField(
                      length: 350,
                      minlines: 6,
                      lines: 6,
                      hintText: 'Enter Tutor Bio',
                      icon: Icons.description_outlined,
                      textEditingController: _tutorBioController,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 2,
                width: MediaQuery.of(context).size.width / 5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: InputField(
                            hintText: 'Enter Tutor Password',
                            icon: Icons.lock,
                            textEditingController: _passwordController,
                          ),
                        ),
                        ElevatedButton(
                          onPressed:
                              _generatePassword, // password generation function
                          child: const Text('Generate'),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    InputField(
                      hintText: 'Enter contact',
                      length: 10,
                      icon: Icons.phone,
                      textEditingController: _contactController,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    InputField(
                      length: 60,
                      hintText: 'Enter Course',
                      CounterText: 'course name must exist',
                      icon: Icons.book_outlined,
                      textEditingController: _courseNameController,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              await _uploadTutor();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kBlueColor,
                        foregroundColor: kWhiteColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: _isLoading
                            ? const Center(
                                child:
                                    CircularProgressIndicator()) // Loading indicator
                            : const Center(
                                child:
                                    Text('Add Tutor')), // Original button text
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        // Clear the text fields
                        _tutorBioController.clear();
                        _nameController.clear();
                        selectedImage;
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kBlueColor,
                        foregroundColor: kWhiteColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: Center(child: Text('Clear form')),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height / 3.5,
                      width: MediaQuery.of(context).size.width / 8,
                      decoration: BoxDecoration(
                        color: kGreyColor900,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: selectedImage != ''
                          ? Image.memory(selectedIconBytes!)
                          : const Icon(Icons.image_outlined),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        await _pickImage();
                      },
                      child: const Center(
                        child: Text('Add Photo'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _generatePassword() {
    setState(() {
      _passwordController.text = generateRandomPassword();
    });
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg', 'jpeg'],
        dialogTitle: 'Select Tutor Image');

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        selectedImage = result.files.first.name;
        selectedIconBytes = result.files.single.bytes;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image selected')),
      );
    }
  }

  Future<void> _uploadTutor() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text;
    String tutorBio = _tutorBioController.text.trim();
    String courseName = _courseNameController.text.trim();

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential authResult =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String tutorId = authResult.user!.uid;

      // Upload the image to Firebase Storage
      fstorage.UploadTask uploadTask;
      fstorage.Reference ref = fstorage.FirebaseStorage.instance
          .ref()
          .child('tutor_Images')
          .child('/' + selectedImage);
      final metadata = fstorage.SettableMetadata(contentType: 'images');
      uploadTask = ref.putData(selectedIconBytes!, metadata);

      await uploadTask.whenComplete(() => null);
      String imageUrl = await ref.getDownloadURL();

      // Add the tutor details to Firestore
      FirebaseFirestore.instance.collection('Tutors').doc(tutorId).set({
        'name': _nameController.text,
        'email': email,
        'bio': tutorBio,
        'id': tutorId,
        'rating': 0,
        'numberofstds': 0,
        'students': [],
        'userImage': imageUrl,
        'available': true,
        'createdAt': Timestamp.now(),
        'fcmToken': '',
        'contact': _contactController.text,
      });

      QuerySnapshot courseSnapshot = await FirebaseFirestore.instance
          .collection('Courses')
          .where('courseName', isEqualTo: courseName)
          .limit(1)
          .get();

      if (courseSnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No matching course found.')),
        );
        return;
      }

      
      DocumentSnapshot courseDoc = courseSnapshot.docs.first;

      // add the tutorid to the 'tutors' array field in the course document
      FirebaseFirestore.instance
          .collection('Courses')
          .doc(courseDoc.id)
          .update({
        'tutors': FieldValue.arrayUnion([tutorId]),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tutor details uploaded successfully')),
      );

      setState(() {
        _nameController.clear();
        _emailController.clear();
        _tutorBioController.clear();
        _contactController.clear();
        _passwordController.clear();
        selectedImage = '';
        selectedIconBytes = null;
      });
    } catch (e) {
      print('Error uploading tutor details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('An error occurred. Please try again later.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
