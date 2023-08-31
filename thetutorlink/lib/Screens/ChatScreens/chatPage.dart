import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:thetutorlink/constants.dart';

import '../../Api/firebase_functions.dart';

import 'models/chatcard.dart';

class ChatPage extends StatefulWidget {
  static String routeName = 'ChatPage';

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final FirebaseFunctions _firebaseFunctions = FirebaseFunctions();

  List<Map<String, dynamic>> students = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final tutorData = await FirebaseFirestore.instance
        .collection('Tutors')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    final studentIds = List<String>.from(tutorData['students'] ?? []);
    final studentDetails =
        await _firebaseFunctions.getStudentDetails(studentIds);

    setState(() {
      students = studentDetails;
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
              centerTitle: true,
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
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              final studentName = student['name'] ?? '';

              final studentImage = student['userImage'] ?? '';

              return ChatCard(
                name: studentName,
                userImage: studentImage,
                studentId: student['id'],
              );
            },
          ),
        ),
      ),
    );
  }
}
