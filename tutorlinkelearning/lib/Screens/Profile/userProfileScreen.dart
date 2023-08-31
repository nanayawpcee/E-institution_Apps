import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tutorlinkelearning/Screens/SignIn/sign_in_screen.dart';
import 'package:tutorlinkelearning/constants.dart';
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
  // String email = '';
  String? userImage;
  String? contact;
  String? userContactInput = '';
  String? userNameInput = '';
  String? userImageUrl;

  File? imageXFile;

  @override
  void initState() {
    super.initState();
    // Listen for changes in the Firestore data
    FirebaseFirestore.instance
        .collection('Students')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        setState(() {
          name = snapshot.data()!['name'];
          //email = snapshot.data()!['email'];
          userImage = snapshot.data()!['userImage'];
          contact = snapshot.data()!['contact'];
        });
      }
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
                InkWell(
                  onTap: () {
                    // update name
                    _displayTextInputDialog(context, 'name');
                  },
                  child: const Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.edit,
                          // color: kGreenColor,
                        ),
                      ),
                      Text(
                        'Edit Name',
                        style: TextStyle(color: kPrimaryColor),
                      )
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    // update contact
                    _displayTextInputDialog(context, 'contact');
                  },
                  child: const Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.edit,
                          color: kBlueColor,
                        ),
                      ),
                      Text(
                        'Edit Contact',
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

//method to update the student image in the firebase
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
        .collection('Students')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'userImage': userImageUrl,
    });
  }

//method to enable the user to take a photo to update profile photo
  void _getFromCamera() async {
    XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    _cropImage(pickedFile!.path);
    Navigator.pop(context);
  }

//method to enable the user to use an image store on the phone as new profile
  void _getFromGallery() async {
    XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    _cropImage(pickedFile!.path);
    Navigator.pop(context);
  }

//method to crop user image to prefered size after taking picture
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

//method to update the user contact 
  Future _updateUserContact() async {
    await FirebaseFirestore.instance
        .collection('Students')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'contact': userContactInput,
    });
  }

//method to update the userName
  Future _updateUserName() async {
    await FirebaseFirestore.instance
        .collection('Students')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'name': userNameInput,
    });
  }

//method to update the user info based on the selected field
//this method contains two methods ie to update the usercontact or the  user name
  _displayTextInputDialog(BuildContext context, String fieldToUpdate) async {
    String title = fieldToUpdate == 'name'
        ? 'Update Your Name Here'
        : 'Update Your Contact Here';
    String hintText = fieldToUpdate == 'name'
        ? 'Type your new name here'
        : 'Type your new contact here';
    Function updateFunction =
        fieldToUpdate == 'name' ? _updateUserName : _updateUserContact;

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: TextField(
              maxLength: fieldToUpdate == 'contact' ? 10 : 27,
              onChanged: (value) {
                setState(() {
                  if (fieldToUpdate == 'name') {
                    userNameInput = value;
                  } else if (fieldToUpdate == 'contact') {
                    userContactInput = value;
                  }
                });
              },
              decoration: InputDecoration(
                hintText: hintText,
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
                                        Text(
                                          contact ?? '000x000x0000',
                                        ),
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
                                    _showImageDialog();
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
                        _displayTextInputDialog(context, 'name');
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
                            'Change Name',
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
                      height: MediaQuery.of(context).size.height / 5,
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      height: MediaQuery.of(context).size.height / 5,
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
                                helpCenterDialog(context);
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
                      _auth.signOut();// this is to allow the user to sign up and user is taken back to sign in page
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
