import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tutorlinkelearning/Screens/CourseDetails/allreviews.dart';
import 'package:tutorlinkelearning/components/othercourses.dart';
import 'package:tutorlinkelearning/constants.dart';

import '../../components/reviewcards.dart';

class ReviewScreen extends StatefulWidget {
  final String courseId;
  static String routeName = 'Review Screen';

  const ReviewScreen({required this.courseId});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  TextEditingController reviewController = TextEditingController();
  String? course = '';
  String? imageUrl = '';
  String? department = '';
  String? description = '';
  String? courseID = '';
  String? stds = '';
  int students = 0;
  int raters = 0;
  int ratings = 0;
  double adRating = 0;
  int sum = 0;

  List<QueryDocumentSnapshot> otherCourses = [];

  void getOtherCourses() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Courses')
          .where('courseId', isNotEqualTo: widget.courseId)
          .get();

      setState(() {
        otherCourses = snapshot.docs;
      });
    } catch (e) {
      print('Error fetching other courses: $e');
    }
  }

  String? userName;
  String? userImage;

  void getstudentImage() async {
    final DocumentSnapshot studentData = await FirebaseFirestore.instance
        .collection('Students')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    setState(() {
      userImage = studentData.get('userImage');
      userName = studentData.get('name');
    });
  }

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
        sum = userDoc.get('accRating');
        raters = userDoc.get('raters');
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getCoursesData();
    getOtherCourses();
    getstudentImage();
  }

  Future<List<ReviewCard>> fetchReviewsData(String courseId) async {
    List<ReviewCard> reviews = [];

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Reviews')
          .limit(2)
          .where('courseId', isEqualTo: courseId)
          .get();

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
      body: CustomScrollView(
        slivers: <Widget>[
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
                    decoration: const BoxDecoration(color: Colors.transparent),
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
            flexibleSpace: Stack(
              children: [
                FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                        color: kGreyColor600,
                        image: DecorationImage(
                          image: NetworkImage(
                            imageUrl!,
                          ),
                          fit: BoxFit.contain,
                        )),
                  ),
                ),
                Positioned(
                  bottom: -45,
                  left: 20,
                  child: Container(
                    height: 90,
                    width: 90,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: kBlueColor,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.reviews_sharp,
                        color: kWhiteColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            floating: true,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'students',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(width: 40),
                      Text(
                        'reviews',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "What's Students say",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AllReviewsPage(
                                  courseId: widget.courseId,
                                ),
                              ),
                            );
                          },
                          child: const Text(
                            'See all',
                            style: TextStyle(color: kBlueColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 260,
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
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: reviews.length,
                      itemBuilder: (context, index) {
                        return reviews[index];
                      },
                    );
                  }
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),
          const SliverToBoxAdapter(
            child: Row(
              children: [
                Text(
                  'Other Courses',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width - 32,
              child: CourseGridView(courses: otherCourses),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showRatingDialog();
        },
        label: const Text('Rate Course'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Future updateRatings() async {
    await FirebaseFirestore.instance
        .collection('Courses')
        .doc(widget.courseId)
        .update({'ratings': sum ~/ raters});
  }

  // increment the number of raters in the data
  void addRater() async {
    var docRef =
        FirebaseFirestore.instance.collection('Courses').doc(widget.courseId);
    docRef.update({'raters': raters + 1});
  }

  //Adding new rating to the backend to accumulate and get the total ratings
  void addNewRatingValue() async {
    var docRef =
        FirebaseFirestore.instance.collection('Courses').doc(widget.courseId);
    docRef.update({'accRating': (sum + adRating).toInt()});
    Navigator.pop(context);
  }

  void _showRatingDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rate Course and Leave a Review'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Please leave a star rating and a review',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(
                height: 16,
              ),
              RatingBar.builder(
                itemSize: 40,
                minRating: 0,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 5),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: kYellowColor,
                ),
                onRatingUpdate: (adRating) => setState(() {
                  this.adRating = adRating;
                }),
              ),
              const SizedBox(
                height: 16,
              ),
              TextField(
                controller: reviewController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Enter your review',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            MaterialButton(
              color: kBlueColor,
              onPressed: () {
                addRater();
                addNewRatingValue();
                updateRatings();

                String review = reviewController.text;

                // Save  the review

                FirebaseFirestore.instance.collection('Reviews').add({
                  'courseId': widget.courseId,
                  'postedBy': userName,
                  'message': review,
                  'timePosted': Timestamp.now(),
                  'userImage': userImage,
                });

                Navigator.pop(context);
              },
              child: const Text(
                'Rate and Review',
                style:
                    TextStyle(color: kWhiteColor, fontWeight: FontWeight.w400),
              ),
            ),
          ],
        );
      },
    );
  }
}
