import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../Api/firebase_functions.dart';
import '../../Components/studentscard.dart';
import '../../constants.dart';

class Mystudents extends StatefulWidget {
  @override
  State<Mystudents> createState() => _MystudentsState();
}

class _MystudentsState extends State<Mystudents> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFunctions _firebaseFunctions = FirebaseFunctions();
  String? userImage;
  List<Map<String, dynamic>> students = [];
  List<Map<String, dynamic>> filteredStudents = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final searchText = _searchController.text.toLowerCase();
    setState(() {
      filteredStudents = students.where((student) {
        final studentName = (student['name'] ?? '').toLowerCase();
        return studentName.contains(searchText);
      }).toList();
    });
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
      filteredStudents = studentDetails;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 40,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width - 30,
                          child: TextField(
                            controller: _searchController,
                            cursorHeight: 24,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              suffixIcon: const Icon(
                                Icons.search_outlined,
                                color: kBlueColor,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              hintText: 'Search students by name...',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'My Students',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Flexible(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        child: ListView.builder(
                          itemCount: filteredStudents.length,
                          itemBuilder: (context, index) {
                            final student = filteredStudents[index];
                            final studentName = student['name'] ?? '';
                            final studentAge = student['age'] ?? '';
                            final studentImage = student['userImage'] ?? '';

                            return StudentsCard(
                              name: studentName,
                              age: studentAge.toString(),
                              userImage: studentImage,
                              studentId: student['id'],
                            );
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
