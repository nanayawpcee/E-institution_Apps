import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

import '../../components/reviewcards.dart';
import '../../constants.dart';

class TutorDetailScreen extends StatefulWidget {
  final String tutorId;
  final String courseId;

  const TutorDetailScreen({
    required this.tutorId,
    required this.courseId,
  });

  @override
  State<TutorDetailScreen> createState() => _TutorDetailScreenState();
}

class _TutorDetailScreenState extends State<TutorDetailScreen> {
  //tutor detail screen variables
  String? name = '';
  String? userImageUrl = '';
  String? studentName = '';
  String? tutorSubject = '';
  String? tutorDescription = '';
  String? school = '';
  String? contact = '';
  String? experience = '';
  String? fcmtoken = '';
  String? requestid = '';
  int students = 0;
  bool available = true;
  bool isavailable = true;
  int? ratings = 0;
  bool isSendingRequest = false;
  bool isRequestAlreadySent = false;

  bool isActive = false;
  bool isPending = false;

//function to check if the student has an active class session for this course
  Future<void> checkIfCourseIsActive() async {
    try {
      String studentId = FirebaseAuth.instance.currentUser!.uid;

      final DocumentSnapshot studentDoc = await FirebaseFirestore.instance
          .collection('Students')
          .doc(studentId)
          .get();

      if (studentDoc.exists) {
        List<dynamic> activeCourses = studentDoc.get('Active');
        List<dynamic> pendingCourses = studentDoc.get('Pending');

        setState(() {
          isActive = activeCourses.contains(widget.courseId);
          isPending = pendingCourses.contains(widget.courseId);
        });
      }
    } catch (e) {
      print('Error checking if course is active or pending: $e');
    }
  }

  //  FCM server key
  final String fcmServerKey =
      'AAAAjRMB0Ac:APA91bGE970mDcSRHT6lUv-wyaw1Ao1DFUhKSzIaiMUc3uGsUPfErYi4-we9GztgQ-Vj6lDX5NVT662WmW67pf_sTslzf2S8eFqSES87enSqYCGE8mgDipCAj2oFb7kWTN1jx4OYEbnh';

 //method to get the details of a tutor and hold them in the variables declared using the setstate method
  Future<void> getTutorData() async {
    try {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Tutors')
          .doc(widget.tutorId)
          .get();

      if (userDoc.exists) {
        setState(() {
          name = userDoc.get('name');
          userImageUrl = userDoc.get('userImage');
          contact = userDoc.get('contact');
          tutorDescription = userDoc.get('bio');
          List<dynamic> studentsList = userDoc.get('students');
          students = studentsList.length;
          fcmtoken = userDoc.get('fcmToken');
          ratings = userDoc.get('rating');
          available = userDoc.get('available');
          isavailable = available;
        });
      }
    } catch (e) {
      print('Error getting tutor data: $e');
    }
  }

  Future<void> checkIfRequestAlreadySent() async {
    try {
      String studentId = FirebaseAuth.instance.currentUser!.uid;

      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Requests')
          .where('studentId', isEqualTo: studentId)
          .where('courseId', isEqualTo: widget.courseId)
          .get();

      setState(() {
        isRequestAlreadySent = querySnapshot.docs.isNotEmpty;
      });
    } catch (e) {
      print('Error checking if request already sent: $e');
    }
  }

  Future<void> sendAndroidNotification() async {
    try {
      http.Response response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'key=$fcmServerKey',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': name,
              'title': 'Request',
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done',
              'requestId': requestid
            },
            'to': fcmtoken,
          },
        ),
      );
      response;
    } catch (e) {
      e;
    }
  }

//function to send a request for tutor for a particular course
  Future<void> sendRequestToTutor() async {
    try {
      String studentId = FirebaseAuth.instance.currentUser!.uid;
      String requestId = const Uuid().v4();
      setState(() {
        isSendingRequest = true;
      });

      await FirebaseFirestore.instance
          .collection('Requests')
          .doc(requestId)
          .set({
        'courseId': widget.courseId,
        'tutorId': widget.tutorId,
        'studentId': studentId,
        'requestId': requestId,
        'isPending': true,
        'isAccepted': false,
        'isRejected': false,
      });

      // Update student's pending courses array
      await FirebaseFirestore.instance
          .collection('Students')
          .doc(studentId)
          .update({
        'Pending': FieldValue.arrayUnion([widget.courseId]),
      });

      setState(() {
        isSendingRequest = false;
        isRequestAlreadySent = true;
        requestid = requestId;
      });
      print('Request added to Firestore and notification sent successfully!');
    } catch (e) {
      setState(() {
        isSendingRequest = false;
      });
      print('Error sending request and notification: $e');
    }
  }

//on page reload, the following methods are called to get the required data
//for the tutor detail page
  @override
  void initState() {
    super.initState();
    getTutorData();
    checkIfRequestAlreadySent();
    fetchReviewsData(widget.tutorId);// fetch the reviews for the opened tutor
    checkIfCourseIsActive();// check if the student has a class session for this particular course
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height * 0.5,
            pinned: true,
            flexibleSpace: Hero(
              tag: 'userImage_${widget.tutorId}',
              child: Material(
                type: MaterialType.transparency,
                child: Container(
                  alignment: Alignment.topCenter,
                  decoration: BoxDecoration(
                    color: kGreyColor600,
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(userImageUrl!),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 1,
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.wechat,
                        size: 40,
                        color: kBlueColor,
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Hero(
                        tag: 'userName_${widget.tutorId}',
                        child: Material(
                          color: Colors.transparent,
                          child:
                              Text(name!, style: const TextStyle(fontSize: 18)),
                        ),
                      ),
                      Row(
                        children: [
                          Text('$ratings.0'),
                          const Icon(
                            Icons.star,
                            color: kYellowColor,
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('10'),
                          Icon(Icons.timer),
                          Text('Experience')
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(students.toString()),
                          const Icon(Icons.people),
                          const Text('Student(s)')
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            available ? 'Open' : 'Closed',
                            style: TextStyle(
                              fontSize: 16,
                              color: available ? Colors.green : Colors.red,
                            ),
                          ),
                          const Icon(Icons.event_available),
                          const Text('Availability')
                        ],
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    'About',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    tutorDescription!,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 6,
                    style: const TextStyle(
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Reviews'),
                      Text(
                        'All reviews',
                        style: TextStyle(color: kBlueColor),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
          //Reviews for the tutor to fit to the 
          SliverToBoxAdapter(
            child: SizedBox(
              height: 260,
              child: FutureBuilder<List<ReviewCard>>(
                future: fetchReviewsData(widget.tutorId),
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
                    //stream builder of reviews made by students 
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
        ],
      ),
      //dynamic floating button to indicate the status of the student request
      floatingActionButton: isavailable
          ? isActive
              ? const FloatingActionButton.extended(
                  onPressed: null,
                  label: Text('You have an active session'),
                )
              : isPending
                  ? const FloatingActionButton.extended(
                      onPressed: null,
                      label: Text('You have a pending request'),
                    )
                  : FloatingActionButton.extended(
                      onPressed: () {
                        sendRequestToTutor();//send the student request to the tutor
                        sendAndroidNotification();//send a notification to tutor 
                      },
                      label: isSendingRequest
                          ? const Row(
                              children: [
                                Text('Sending...'),
                                SizedBox(width: 8),
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              ],
                            )
                          : const Text('Request Tutor'),
                    )
          : const FloatingActionButton.extended(
              onPressed: null,
              label: Text('Unavailable'),
            ),
    );
  }
//this is a method to fetch reviews data for the tutor
  Future<List<ReviewCard>> fetchReviewsData(String tutorId) async {
    List<ReviewCard> reviews = [];

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('TutorReviews')
          .where('tutorId', isEqualTo: widget.tutorId)
          .get();

      for (QueryDocumentSnapshot doc in snapshot.docs) {
        ReviewCard reviewCard = ReviewCard(
          tutorId: doc['tutorId'],
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
}
