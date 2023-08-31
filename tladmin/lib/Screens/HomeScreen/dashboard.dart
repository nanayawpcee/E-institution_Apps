import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tladmin/constants.dart';

class DashBoard extends StatelessWidget {
  static String routeName = 'DashBoard';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DashboardBody(),
      ],
    );
  }
}

//Body widget for the dashboard
class DashboardBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, int>>(
      future: fetchDataFromFirestore(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error fetching data'));
        } else if (!snapshot.hasData) {
          return Center(child: Text('No data available'));
        }

        final data = snapshot.data!;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Welcome To TutorLink'),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  DashboardCard(
                    title: 'Total Courses',
                    value: data['courses'],
                  ),
                  DashboardCard(
                    title: 'Total Tutors',
                    value: data['tutors'],
                  ),
                  DashboardCard(
                    title: 'Total Classrooms',
                    value: data['classrooms'],
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DashboardCard(
                    title: 'Total Requests',
                    value: data['requests'],
                  ),
                  DashboardCard(
                    title: 'Pending Requests',
                    value: data['pendingRequests'],
                  ),
                  DashboardCard(
                    title: 'Total Course Reviews',
                    value: data['reviews'],
                  ),
                  DashboardCard(
                    title: 'Total Tutor Reviews',
                    value: data['tutorReviews'],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

//Dashboad function to hightlight some few quick snap of the platform activities
  Future<Map<String, int>> fetchDataFromFirestore() async {
    final firestore = FirebaseFirestore.instance;

    final coursesQuery = await firestore.collection('Courses').get();
    final tutorsQuery = await firestore.collection('Tutors').get();
    final classroomsQuery = await firestore.collection('Classroom').get();
    final requestsQuery = await firestore.collection('Requests').get();
    final pendingRequestsQuery = await firestore
        .collection('Requests')
        .where('Pending', isEqualTo: true)
        .get();
    final reviewsQuery = await firestore.collection('Reviews').get();
    final tutorReviewsQuery = await firestore.collection('TutorReviews').get();

    final data = {
      'courses': coursesQuery.size,
      'tutors': tutorsQuery.size,
      'classrooms': classroomsQuery.size,
      'requests': requestsQuery.size,
      'pendingRequests': pendingRequestsQuery.size,
      'reviews': reviewsQuery.size,
      'tutorReviews': tutorReviewsQuery.size,
    };

    return data;
  }
}

//Dashboard cards
class DashboardCard extends StatelessWidget {
  final String title;
  final int? value;

  DashboardCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      width: 120,
      decoration: BoxDecoration(
          color: kGreyColor500, borderRadius: BorderRadius.circular(8)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(title,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ),
          SizedBox(height: 8),
          Center(
            child: Text(value.toString(),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
