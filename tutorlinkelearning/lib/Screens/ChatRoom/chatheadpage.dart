import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../Backend/firebase_funtions.dart';
import '../../constants.dart';
import 'Utils/chatpagecard.dart';

class ChatPage extends StatefulWidget {
  static String routeName = 'ChatPage';

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final FirebaseFunctions _firebaseFunctions = FirebaseFunctions();
  String? userImage;
  List<Map<String, dynamic>> tutors = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final StudentData = await FirebaseFirestore.instance
        .collection('Students')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    final tutorIds = List<String>.from(StudentData['tutors'] ?? []);
    final tutorDetails = await _firebaseFunctions.gettutorDetails(tutorIds);

    setState(() {
      this.tutors = tutorDetails;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'ChatRoom',
                  style: TextStyle(color: kWhiteColor),
                ),
                background: Image.asset(
                  'assets/images/chat.png',
                  fit: BoxFit.fill,
                ),
              ),
              floating: true,
              snap: true,
              pinned: true,
            ),
          ];
        },
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.builder(
            itemCount: tutors.length,
            itemBuilder: (context, index) {
              final tutor = tutors[index];
              final tutorName = tutor['name'] ?? '';
              final tutorId = tutor['id'] ?? '';
              final tutorstds = tutor['numberofstds'] ??
                  ''; //TODO: a count on of the students array in the firestore
              final tutorImage = tutor['userImage'] ?? '';
              final tutorRating = tutor['rating'] ?? '';
              final tutoravailable = tutor['available'] as bool;

              return TutorChatCard(
                  tutorId: tutorId,
                  imageUrl: tutorImage,
                  courseId: tutorId,
                  tutorName: tutorName,
                  students: tutorstds,
                  rating: tutorRating,
                  isOpen: tutoravailable);
            },
          ),
        ),
      ),
    );
  }
}
