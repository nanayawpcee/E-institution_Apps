//import 'package:flutter/material.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
////import 'package:thetutorlink/Components/coursecard.dart';
//import 'package:thetutorlink/Components/home.dart';
//import 'package:thetutorlink/constants.dart';
//class SearchCourses extends StatefulWidget {
//  @override
//
//  State<SearchCourses> createState() => _SearchCoursesState();
//}
//class _SearchCoursesState extends State<SearchCourses> {
//  final TextEditingController _searchingController = TextEditingController();
//
//  String searchQuery = 'Search query';
//  Widget _buildSearchField() {
//    return TextField(
//      controller: _searchingController,
//      autocorrect: true,
//      decoration: const InputDecoration(
//          hintText: 'Search For Tutors...',
//          border: InputBorder.none,
//          hintStyle: TextStyle(color: kWhiteColor)),
//      style: const TextStyle(color: kWhiteColor, fontSize: 16),
//      onChanged: (query) => updateSearchingQuery(query),
//    );
//  }
//  List<Widget> _buildActions() {
//    return <Widget>[
//
//      IconButton(
//          onPressed: () {
//            _clearSearchingfield();
//          },
//          icon: const Icon(Icons.clear))
//    ];
//  }
//  void _clearSearchingfield() {
//    setState(() {
//
//      _searchingController.clear();
//      updateSearchingQuery('');
//    });
//  }
//  void updateSearchingQuery(String newQuery) {
//    setState(() {
//
//      searchQuery = newQuery;
//      print(searchQuery);
//    });
//  }
//  @override
//  Widget build(BuildContext context) {
//
//    return Container(
//      decoration: const BoxDecoration(
//        color: kWhiteColor,
//      ),
//      child: Scaffold(
//        backgroundColor: Colors.transparent,
//        appBar: AppBar(
//          flexibleSpace: Container(
//            decoration: const BoxDecoration(
//              color: kBlueColor,
//            ),
//          ),
//          leading: IconButton(
//            onPressed: () {
//              Navigator.pushReplacement(
//                  context,
//                  MaterialPageRoute(
//                      builder: (context) => HomeScreensBuilder()));
//            },
//            icon: const Icon(Icons.arrow_back),
//          ),
//          automaticallyImplyLeading: false,
//          title: _buildSearchField(),
//          actions: _buildActions(),
//        ),
//        body: StreamBuilder<QuerySnapshot>(
//          stream: FirebaseFirestore.instance
//              .collection('courses')
//              .where('Course', isGreaterThanOrEqualTo: searchQuery)
//              .snapshots(),
//          builder: (context, AsyncSnapshot snapshot) {
//            if (snapshot.connectionState == ConnectionState.waiting) {
//              return const Center(
//                child: CircularProgressIndicator(),
//              );
//            } else if (snapshot.connectionState == ConnectionState.active) {
//              if (snapshot.data?.docs.isNotEmpty) {
//                return ListView.builder(
//                    itemCount: snapshot.data!.docs.length,
//                    itemBuilder: (BuildContext context, int index) {
//                      return CoursesCard(
//                          courseId: snapshot.data?.docs[index]['ID'],
//                          courseIcon: snapshot.data?.docs[index]['ImageUrl'],
//                          course: snapshot.data?.docs[index]['Course'],
//                          students: snapshot.data?.docs[index]['Students'],
//                          description: snapshot.data?.docs[index]['Description'],
//                          rating: snapshot.data?.docs[index]['Ratings'],
//                          department: snapshot.data?.docs[index]['Department']);
//                    });
//              } else {
//                return const Center(
//                  child: Text('There are no Courses'),
//                );
//              }
//            }
//            return const Center(
//              child: Text(
//                'whoops! An error occurred',
//                style: TextStyle(
//                  color: kRedColor,
//                  fontWeight: FontWeight.bold,
//                  fontSize: 24,
//                ),
//              ),
//            );
//          },
//        ),
//      ),
//    );
//  }
//}
