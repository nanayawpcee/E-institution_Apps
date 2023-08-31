import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tutorlinkelearning/Screens/CourseDetails/reviews.dart';
import 'package:tutorlinkelearning/constants.dart';
import 'package:video_player/video_player.dart';
import '../../Backend/tutorcardlistbuild.dart';

class CourseDetailScreen extends StatefulWidget {
  final String courseId;

  const CourseDetailScreen({required this.courseId});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  String? course = '';
  String? imageUrl = '';
  String? department = '';
  String? description = '';
  int ratings = 0;
  bool _isVideoReady = false;
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    getCoursesData();
    initializeVideoPlayer();
  }

  void initializeVideoPlayer() async {
    FirebaseFirestore.instance
        .collection('Courses')
        .doc(widget.courseId)
        .get()
        .then((courseSnapshot) async {
      String courseVideoUrl = courseSnapshot['courseVid'];

      _videoPlayerController = VideoPlayerController.network(courseVideoUrl);

      await _videoPlayerController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: true,
      );

      setState(() {
        _isVideoReady = true;
      });
    });
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  void getCoursesData() async {
    final DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('Courses')
        .doc(widget.courseId)
        .get();

    // Check for null and update state
    if (userDoc.exists) {
      setState(() {
        course = userDoc.get('courseName');
        imageUrl = userDoc.get('courseIcon');
        department = userDoc.get('department');
        description = userDoc.get('courseInfo');
        ratings = userDoc.get('ratings');
      });
    }
  }

  void addBookmark() async {
    final studentId = FirebaseAuth.instance.currentUser!.uid;
    final docRef =
        FirebaseFirestore.instance.collection('Students').doc(studentId);

    DocumentSnapshot studentSnapshot = await docRef.get();
    List<dynamic>? bookmarks = studentSnapshot['bookmarks'];

    if (bookmarks == null) {
      bookmarks = [widget.courseId];
    } else {
      if (!bookmarks.contains(widget.courseId)) {
        bookmarks.add(widget.courseId);
      }
    }
    await docRef.update({'bookmarks': bookmarks});

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(
                        Icons.arrow_back_ios_new_outlined,
                        color: kBlackColor800,
                        size: 30,
                      ),
                    ),
                    const Text(
                      'Course Details',
                      style: TextStyle(color: kBlueColor, fontSize: 20),
                    ),
                    GestureDetector(
                      onTap: () {
                        addBookmark();
                      },
                      child: const Icon(
                        Icons.bookmark_add_outlined,
                        color: kBlueColor,
                        size: 35,
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 14,
                ),
                Container(
                  height: MediaQuery.of(context).size.height / 4.5,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: kBlueColor),
                  child: _isVideoReady
                      ? Chewie(
                          controller: _chewieController!,
                        )
                      : Center(child: CircularProgressIndicator()),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${course!} Course',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600),
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                Text(
                  description!,
                  textAlign: TextAlign.justify,
                  style: const TextStyle(letterSpacing: 0.5),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text(
                      'Tutors',
                      style: TextStyle(
                          color: kPrimaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ReviewScreen(courseId: widget.courseId)));
                      },
                      child: const Text(
                        'Reviews',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: kBlueColor),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                tutorcardbuilder_coursedetails(widget: widget)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
