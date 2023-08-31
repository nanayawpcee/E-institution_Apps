import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../components/reviewcards.dart';
import '../../constants.dart';

class AllReviewsPage extends StatefulWidget {
  static String routeName = 'AllReviewsPage';
  final String courseId;

  const AllReviewsPage({required this.courseId});

  @override
  State<AllReviewsPage> createState() => _AllReviewsPageState();
}

class _AllReviewsPageState extends State<AllReviewsPage> {
  String? imageUrl = '';
  final TextEditingController _reviewController = TextEditingController();

  String? course = '';
  String? department = '';
  String? description = '';
  String? courseID = '';
  int students = 0;
  int raters = 0;
  int ratings = 0;
  double adRating = 0;
  int sum = 0;

  //these variables are for the reviews
  String? userName;
  String? userImage;

  Future<void> _showAddReviewDialog() async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      String userId = currentUser.uid;

      // Retrieve user information from the 'students' collection
      final DocumentSnapshot studentDoc = await FirebaseFirestore.instance
          .collection('Students')
          .doc(userId)
          .get();
      if (studentDoc.exists) {
        userName = studentDoc.get('name');
        userImage = studentDoc.get('userImage');

        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Add Review'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _reviewController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Your Review',
                      hintText: 'Write your review here...',
                    ),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () async {
                    final String reviewMessage = _reviewController.text;

                    // getting user info for the review posting
                    final String postedBy = userName ?? 'Unknown';
                    final String stdImage = userImage ?? '';

                    // adding review to "Reviews" collection
                    final reviewsCollection =
                        FirebaseFirestore.instance.collection('Reviews');
                    final newReviewDoc = await reviewsCollection.add({
                      'courseId': widget.courseId,
                      'postedBy': postedBy,
                      'userImage': stdImage,
                      'timePosted': Timestamp.now(),
                      'message': reviewMessage,
                    });

                    // this method gets the review Id in  the review collection and add it to field reviews
                    //in the Course Collection's document
                    final newReviewId = newReviewDoc.id;
                    final courseDoc = await FirebaseFirestore.instance
                        .collection('Courses')
                        .doc(widget.courseId)
                        .get();
                    final List<String> currentReviews =
                        List<String>.from(courseDoc['reviews']);
                    currentReviews.add(newReviewId);
                    await FirebaseFirestore.instance
                        .collection('Courses')
                        .doc(widget.courseId)
                        .update({
                      'reviews': currentReviews,
                    });

                    Navigator.pop(context);
                  },
                  child: const Text('Post Review'),
                ),
              ],
            );
          },
        );
      }
    }
  }

//to  the course details
  void getCoursesData() async {
    final DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('Courses')
        .doc(widget.courseId)
        .get();

    // ignore: unnecessary_null_comparison
    if (userDoc == null) {
      return;
    } else {
      setState(() {
        course = userDoc.get('courseName');
        imageUrl = userDoc.get('courseIcon');
        department = userDoc.get('department');
        description = userDoc.get('courseInfo');
        ratings = userDoc.get('ratings');
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getCoursesData();
  }

  Future<List<ReviewCard>> fetchReviewsData(String courseId) async {
    List<ReviewCard> reviews = [];

    try {
      // Query Firestore to fetch reviews based on the courseId
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Reviews')
          .where('courseId', isEqualTo: courseId)
          .get();

      // Process the fetched data and convert to ReviewCard widgets
      for (QueryDocumentSnapshot doc in snapshot.docs) {
        ReviewCard reviewCard = ReviewCard(
          courseId: doc['courseId'],
          postedBy: doc['postedBy'],
          message: doc['message'],
          timePosted: doc['timePosted'],
          userImage: doc['userImage'],
        );
        reviews.add(reviewCard);
      }
    } catch (e) {
      print('Error fetching reviews: $e');
    }

    return reviews;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
          headerSliverBuilder: (context, innnerBoxIsScrolled) {
            return [
              SliverAppBar(
                leading: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: 2,
                    width: 2,
                    child: Hero(
                      tag: '${widget.courseId}_icon',
                      child: Container(
                        height: 10,
                        width: 10,
                        decoration:
                            const BoxDecoration(color: Colors.transparent),
                        padding: const EdgeInsets.all(10),
                        child: SvgPicture.asset(
                          'assets/svgs/icon-back.svg',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
                expandedHeight: 200,
                flexibleSpace: FlexibleSpaceBar(
                  background: Hero(
                    tag: '${widget.courseId}_image',
                    child: imageUrl != null
                        ? Image.network(
                            imageUrl!,
                            fit: BoxFit.fill,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(color: kGreyColor500);
                            },
                          )
                        : Container(color: kGreyColor500),
                  ),
                ),
              )
            ];
          },
          body: Padding(
            padding: EdgeInsets.all(8.0),
            child: FutureBuilder<List<ReviewCard>>(
              future: fetchReviewsData(widget.courseId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text('Error fetching reviews'),
                  );
                } else {
                  List<ReviewCard> reviews = snapshot.data ?? [];
                  return ListView.builder(
                    itemCount: reviews.length,
                    itemBuilder: (context, index) {
                      return reviews[index];
                    },
                  );
                }
              },
            ),
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddReviewDialog();
        },
        child: const Icon(
          Icons.reviews_outlined,
          color: kWhiteColor,
        ),
      ),
    );
  }
}
