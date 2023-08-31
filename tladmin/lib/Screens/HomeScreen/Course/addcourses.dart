import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as fstorage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tladmin/Components/durationtxtfield.dart';
import 'package:tladmin/Components/inputtextform.dart';
import 'package:tladmin/utils/responsive.dart';
import '../../../Components/dropdownmenu.dart';
import '../../../constants.dart';

class AddCourse extends StatefulWidget {
  static String routeName = 'AddCourse';

  @override
  State<AddCourse> createState() => _AddCourseState();
}

class _AddCourseState extends State<AddCourse> {
  final TextEditingController _courseNameController = TextEditingController();
  final TextEditingController _courseInfoController = TextEditingController();

  String _courseOverviewVideoUrl = '';

  String selectedImage = '';
  Uint8List? selectedIconBytes;

  String videoName = '';
  Uint8List? selectedVideoBytes;

  String? _selectedDepartment;
  List<String> departments = [
    '3D Design',
    'Programming Languages',
    'Biology',
    'Physics',
    'Mathematics',
    'Chemistry',
    'Computer Science',
    'Acturial Science',
    'Biochemistry',
    'Information Technology',
    'Arts and Design',
    'Geography',
    'Languages',
    'Social sciences',
  ];

  double _durationInHours = 0.0;
  void updateDuration(double duration) {
    setState(() {
      _durationInHours = duration;
    });
  }

  bool _isUploadingVideo = false;
  bool _isUploadingCourseDetails = false;

  @override
  Widget build(BuildContext context) {
    return Responsive(
      mobile: buildMobileLayout(),
      tablet: buildTabletLayout(),
      desktop: buildDesktopLayout(),
    );
  }

  Widget buildDesktopLayout() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.only(top: 30),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10), color: kGreyColor700),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height / 2,
                width: MediaQuery.of(context).size.width / 3,
                child: Column(
                  children: [
                    InputField(
                      length: 100,
                      hintText: 'Enter Course Name',
                      icon: Icons.school,
                      textEditingController: _courseNameController,
                    ),
                    const SizedBox(height: 10),
                    CustomDropdownButton(
                      value: _selectedDepartment,
                      items: departments,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedDepartment = newValue;
                        });
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    InputField(
                      length: 350,
                      minlines: 6,
                      lines: 6,
                      hintText: 'Enter Course Info',
                      icon: Icons.description_outlined,
                      textEditingController: _courseInfoController,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 2.4,
                width: MediaQuery.of(context).size.width / 5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    DurationInputWidget(
                      onDurationUpdated:
                          updateDuration, // pass the callback function
                    ),
                    ElevatedButton(
                      onPressed: _isUploadingCourseDetails
                          ? null
                          : () async {
                              await _uploadCourseDetails();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kBlueColor,
                        foregroundColor: kWhiteColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: _isUploadingCourseDetails
                          ? CircularProgressIndicator()
                          : const SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: Center(child: Text('Add Course')),
                            ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _isUploadingCourseDetails
                          ? null
                          : () {
                              // Clear the text fields
                              _courseInfoController.clear();
                              _courseNameController.clear();
                              selectedImage;
                              _selectedDepartment = null;
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kBlueColor,
                        foregroundColor: kWhiteColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: _isUploadingCourseDetails
                          ? CircularProgressIndicator()
                          : const SizedBox(
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
                          ? _getImageWidget()
                          //Image.memory(selectedIconBytes!)
                          : Icon(Icons.image_outlined),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _isUploadingCourseDetails
                          ? null
                          : () async {
                              await _pickIcon();
                            },
                      child: Center(
                        child: Text('Add Photo'),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                      onPressed: _isUploadingCourseDetails
                          ? null
                          : () async {
                              await _pickCourseOverviewVideo();
                            },
                      child: _isUploadingVideo
                          ? CircularProgressIndicator()
                          : const Center(
                              child: Text('Add Course Overview Video'),
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

  Widget buildTabletLayout() {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width / 15),
      child: Container(
        color: kGreyColor500,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // wrapped tablet specific layout inside a Column
            Container(
              height: MediaQuery.of(context).size.height / 4,
              width: MediaQuery.of(context).size.width / 4,
              decoration: BoxDecoration(
                color: kGreyColor900,
                borderRadius: BorderRadius.circular(8),
              ),
              child: selectedImage != ''
                  ? _getImageWidget()
                  //Image.memory(selectedIconBytes!)
                  : Icon(Icons.image_outlined),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 200),
              child: ElevatedButton(
                  onPressed: () async {
                    await _pickIcon();
                  },
                  child: const Center(
                    child: Text('Add Photo'),
                  )),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 200),
              child: ElevatedButton(
                onPressed: _isUploadingCourseDetails
                    ? null
                    : () async {
                        await _pickCourseOverviewVideo();
                      },
                child: _isUploadingVideo
                    ? CircularProgressIndicator()
                    : const Center(
                        child: Text('Add Course Overview Video'),
                      ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            InputField(
              hintText: 'Enter Course Name',
              icon: Icons.school,
              textEditingController: _courseNameController,
            ),
            const SizedBox(height: 10),
            CustomDropdownButton(
              value: _selectedDepartment,
              items: departments,
              onChanged: (newValue) {
                setState(() {
                  _selectedDepartment = newValue;
                });
              },
            ),
            const SizedBox(
              height: 20,
            ),
            InputField(
              length: 150,
              lines: 3,
              hintText: 'Enter Course Info',
              icon: Icons.description_outlined,
              textEditingController: _courseInfoController,
            ),
            const SizedBox(
              height: 10,
            ),
            DurationInputWidget(
              onDurationUpdated: updateDuration, // pass the callback function
            ),
            ElevatedButton(
              onPressed: () async {
                await _uploadCourseDetails();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kBlueColor,
                foregroundColor: kWhiteColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: SizedBox(
                height: 50,
                child: Center(child: Text('Add Course')),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Clear the text fields
                _courseInfoController.clear();
                _courseNameController.clear();
                selectedImage;
                _selectedDepartment = null;
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kBlueColor,
                foregroundColor: kWhiteColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: SizedBox(
                height: 50,
                child: Center(child: Text('Clear form')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMobileLayout() {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width / 15),
      child: Container(
        color: kGreyColor500,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Wrap tablet specific layout inside a Column
            Container(
              height: MediaQuery.of(context).size.height / 4,
              width: MediaQuery.of(context).size.width / 4,
              decoration: BoxDecoration(
                color: kGreyColor900,
                borderRadius: BorderRadius.circular(8),
              ),
              child: selectedImage != ''
                  ? _getImageWidget()
                  //Image.memory(selectedIconBytes!)
                  : Icon(Icons.image_outlined),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 100),
              child: ElevatedButton(
                  onPressed: () async {
                    await _pickIcon();
                  },
                  child: const Center(
                    child: Text('Add Photo'),
                  )),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 100),
              child: ElevatedButton(
                onPressed: _isUploadingCourseDetails
                    ? null
                    : () async {
                        await _pickCourseOverviewVideo();
                      },
                child: _isUploadingVideo
                    ? CircularProgressIndicator()
                    : const Center(
                        child: Text('Add Course Overview Video'),
                      ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            InputField(
              hintText: 'Enter Course Name',
              icon: Icons.school,
              textEditingController: _courseNameController,
            ),
            const SizedBox(height: 10),
            CustomDropdownButton(
              value: _selectedDepartment,
              items: departments,
              onChanged: (newValue) {
                setState(() {
                  _selectedDepartment = newValue;
                });
              },
            ),
            const SizedBox(
              height: 20,
            ),
            InputField(
              length: 150,
              lines: 3,
              hintText: 'Enter Course Info',
              icon: Icons.description_outlined,
              textEditingController: _courseInfoController,
            ),
            const SizedBox(
              height: 10,
            ),
            DurationInputWidget(
              onDurationUpdated: updateDuration, // pass callback function
            ),
            ElevatedButton(
              onPressed: () async {
                await _uploadCourseDetails();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kBlueColor,
                foregroundColor: kWhiteColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const SizedBox(
                height: 50,
                child: Center(child: Text('Add Course')),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Clear the text fields
                _courseInfoController.clear();
                _courseNameController.clear();
                selectedImage;
                _selectedDepartment = null;
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kBlueColor,
                foregroundColor: kWhiteColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: SizedBox(
                height: 50,
                child: Center(child: Text('Clear form')),
              ),
            ),
          ],
        ),
      ),
    );
  }

//this is to get the image
  Widget _getImageWidget() {
    if (selectedImage.toLowerCase().endsWith('.svg')) {
      return SvgPicture.memory(
        selectedIconBytes!,
        fit: BoxFit.fill,
      );
    } else {
      return Image.memory(
        selectedIconBytes!,
        fit: BoxFit.fill,
      );
    }
  }

//this is to pick a course icon which is an image
  Future<void> _pickIcon() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg', 'jpeg', 'svg'],
        dialogTitle: 'Select Course Icon');

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        selectedImage = result.files.first.name;
        selectedIconBytes = result.files.single.bytes;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No image selected')),
      );
    }
  }

//upload the course details to the firebase
  Future<void> _uploadCourseDetails() async {
    try {
      if (selectedImage == '') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select an image')),
        );
        return;
      }

      // Upload the image to Firebase Storage
      fstorage.UploadTask uploadTask;
      fstorage.Reference ref = fstorage.FirebaseStorage.instance
          .ref()
          .child('course_Icons')
          .child('/' + selectedImage);
      final metadata = fstorage.SettableMetadata(contentType: 'images/svg+xml');
      uploadTask = ref.putData(selectedIconBytes!, metadata);

      await uploadTask.whenComplete(() => null);
      String imageUrl = await ref.getDownloadURL();

      // Add the tutor details to Firestore
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      String courseId = firestore.collection('Courses').doc().id;
      firestore.collection('Courses').doc(courseId).set({
        'courseId': courseId,
        'duration': _durationInHours,
        'ratings': 0,
        'reviews': [],
        'tutors': [],
        'createdAt': Timestamp.now(),
        'courseName': _courseNameController.text,
        'department': _selectedDepartment,
        'courseInfo': _courseInfoController.text,
        'courseIcon': imageUrl,
        'courseVid': _courseOverviewVideoUrl
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Course details uploaded successfully')),
      );

      // Clear the form and selected image
      setState(() {
        _courseNameController.clear();
        _selectedDepartment = null;
        _courseInfoController.clear();
        selectedImage = '';
        selectedIconBytes = null;
      });
    } catch (e) {
      print('Error uploading course details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. Please try again later.')),
      );
    }
  }

  Future<void> _pickCourseOverviewVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp4'],
      dialogTitle: 'Select Course video',
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _isUploadingVideo = true;
        videoName = result.files.single.name;
        selectedVideoBytes = result.files.single.bytes;
      });

      try {
        String videoUrl = await _uploadCourseOverviewVideo(videoName);

        // Store the video url in a class variable to use when adding the course
        _courseOverviewVideoUrl = videoUrl;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Course overview video uploaded successfully')),
        );
      } catch (e) {
        print('Error uploading course overview video: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred while uploading video')),
        );
      } finally {
        setState(() {
          _isUploadingVideo = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No video selected')),
      );
    }
  }

  Future<String> _uploadCourseOverviewVideo(String videoName) async {
    fstorage.UploadTask uploadTask;
    fstorage.Reference ref = fstorage.FirebaseStorage.instance
        .ref()
        .child('course_videos')
        .child('/' + videoName);

    final metadata = fstorage.SettableMetadata(contentType: 'video/mp4');
    uploadTask = ref.putData(selectedVideoBytes!, metadata);

    await uploadTask.whenComplete(() => null);
    String videoUrl = await ref.getDownloadURL();
    return videoUrl;
  }
}
