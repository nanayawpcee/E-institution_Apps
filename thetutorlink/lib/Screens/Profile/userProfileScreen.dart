import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:thetutorlink/Screens/SignIn/sign_in_screen.dart';
import 'package:thetutorlink/constants.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as fstorage;

import 'models/dialog.dart';

class UserProfileScreen extends StatefulWidget {
  static String routeName = 'UserProfileScreen';

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? name;
  String email = '';
  String? userImage;
  String? contact;
  bool? available; // will include this later
  String? userContactInput = '';
  String? userImageUrl;

  File? imageXFile;

  @override
  void initState() {
    super.initState();
    // Listen for changes in the Firestore data
    FirebaseFirestore.instance
        .collection('Tutors')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        setState(() {
          name = snapshot.data()!['name'];
          available = snapshot.data()!['available'];
          userImage = snapshot.data()!['userImage'];
          contact = snapshot.data()!['contact'];
        });
      }
    });
  }

  void _updateAvailability(bool newAvailability) async {
    await FirebaseFirestore.instance
        .collection('Tutors')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'available': newAvailability,
    });
  }

  void _showImageDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Please choose an option'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () {
                    //get from camera
                    _getFromCamera();
                  },
                  child: const Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.camera_alt_rounded,
                          color: kBlueColor,
                        ),
                      ),
                      Text(
                        'Camera',
                        style: TextStyle(color: kPrimaryColor),
                      )
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    //get from gallery
                    _getFromGallery();
                  },
                  child: const Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.image_rounded,
                          color: kBlackColor900,
                        ),
                      ),
                      Text(
                        'Gallery',
                        style: TextStyle(color: kPrimaryColor),
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  void _updateImageInFirestore() async {
    String fileName = DateTime.now().microsecondsSinceEpoch.toString();
    fstorage.Reference reference = fstorage.FirebaseStorage.instance
        .ref()
        .child('userImages')
        .child(fileName);

    fstorage.UploadTask uploadTask = reference.putFile(File(imageXFile!.path));
    fstorage.TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
    await taskSnapshot.ref.getDownloadURL().then((url) async {
      userImageUrl = url;
    });
    await FirebaseFirestore.instance
        .collection('Tutors')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'userImage': userImageUrl,
    });
  }

  void _getFromCamera() async {
    XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    _cropImage(pickedFile!.path);
    Navigator.pop(context);
  }

  void _getFromGallery() async {
    XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    _cropImage(pickedFile!.path);
    Navigator.pop(context);
  }

  void _cropImage(filePath) async {
    CroppedFile? croppedImage = await ImageCropper()
        .cropImage(sourcePath: filePath, maxHeight: 1080, maxWidth: 1080);
    if (croppedImage != null) {
      setState(() {
        imageXFile = File(croppedImage.path);
        _updateImageInFirestore();
      });
    }
  }

  Future _updateUserContact() async {
    await FirebaseFirestore.instance
        .collection('Tutors')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'contact': userContactInput,
    });
  }

  _displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Update Your Contact Here'),
            content: TextField(
              maxLength: 10,
              onChanged: (value) {
                setState(() {
                  userContactInput = value;
                });
              },
              decoration: const InputDecoration(
                hintText: 'Type here',
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kBlueColor,
                ),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  _updateUserContact();
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 40, left: 20, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'My Account',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: kBlueColor,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                    height: MediaQuery.of(context).size.width / 3,
                    decoration: BoxDecoration(
                      color: kGreyColor400,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: userImage != null
                        ? Stack(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 10, left: 10),
                                child: Row(
                                  children: [
                                    Container(
                                      height: 85,
                                      width: 85,
                                      decoration: BoxDecoration(
                                          color: kBlueColor,
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                              image: NetworkImage(userImage!),
                                              fit: BoxFit.fill)),
                                      child: const Icon(
                                        Icons.add_a_photo_outlined,
                                        color: kWhiteColor,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name ?? 'Enter name',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              contact ?? '000x000x0000',
                                            ),
                                            Container(
                                              height: 24,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 3,
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                color: available!
                                                    ? kGreenLightColor
                                                    : kRedLightColor,
                                              ),
                                              child: Text(
                                                available! ? 'Open' : 'Close',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleSmall!
                                                    .copyWith(
                                                      color: available!
                                                          ? kGreenColor
                                                          : kRedColor,
                                                    ),
                                              ),
                                            )
                                          ],
                                        ),
                                        const SizedBox(height: 5),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Positioned(
                                bottom: 4,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title:
                                              const Text('Change Availability'),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ListTile(
                                                title: const Text('Open'),
                                                leading: Radio<bool>(
                                                  value: true,
                                                  groupValue: available,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      available = value;
                                                    });
                                                    _updateAvailability(
                                                        available!);
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                              ),
                                              ListTile(
                                                title: const Text('Close'),
                                                leading: Radio<bool>(
                                                  value: false,
                                                  groupValue: available,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      available = value;
                                                    });
                                                    _updateAvailability(
                                                        available!);
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: const Text(
                                    'Edit',
                                    style: TextStyle(
                                      color: kBlueColor,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : const Center(child: CircularProgressIndicator())),
                const SizedBox(
                  height: 10,
                ),
                Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        _showImageDialog();
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 30,
                        decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 175, 220, 241),
                            borderRadius: BorderRadius.circular(8)),
                        child: const Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                          child: Text(
                            'Change Profile Photo',
                            style: TextStyle(
                                color: kBlueColor, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height / 5.5,
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 169, 220, 243),
                          borderRadius: BorderRadius.circular(8)),
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Account Settings',
                                  style: TextStyle(
                                      color: kBlueColor,
                                      fontWeight: FontWeight.bold),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: kWhiteColor,
                                )
                              ],
                            ),
                            Divider(
                              thickness: 1,
                              color: kWhiteColor,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Download Options',
                                  style: TextStyle(
                                      color: kBlueColor,
                                      fontWeight: FontWeight.bold),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: kWhiteColor,
                                )
                              ],
                            ),
                            Divider(
                              thickness: 1,
                              color: kWhiteColor,
                            ),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Notification Setting',
                                  style: TextStyle(
                                      color: kBlueColor,
                                      fontWeight: FontWeight.bold),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: kWhiteColor,
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height / 5.5,
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 175, 220, 241),
                          borderRadius: BorderRadius.circular(8)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 6),
                        child: Column(
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Privacy and Policy',
                                  style: TextStyle(
                                      color: kBlueColor,
                                      fontWeight: FontWeight.bold),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: kWhiteColor,
                                )
                              ],
                            ),
                            const Divider(
                              thickness: 1,
                              color: kWhiteColor,
                            ),
                            GestureDetector(
                              onTap: () {
                                HelpCenterDialog(context);
                              },
                              child: const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Help Center',
                                    style: TextStyle(
                                        color: kBlueColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: kWhiteColor,
                                  )
                                ],
                              ),
                            ),
                            const Divider(
                              thickness: 1,
                              color: kWhiteColor,
                            ),
                            GestureDetector(
                              onTap: () {
                                aboutUs(context);
                              },
                              child: const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'About Us',
                                    style: TextStyle(
                                        color: kBlueColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: kWhiteColor,
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        minimumSize: const Size(140, 35)),
                    onPressed: () {
                      _auth.signOut();
                      Navigator.pushNamedAndRemoveUntil(
                          context, SignInScreen.routeName, (route) => false);
                    },
                    child: const Text('Logout')),
                const SizedBox(
                  height: 80,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
