import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tutorlinkelearning/components/coursecard.dart';
import '../../constants.dart';
import '../../utils/persistent.dart';

class Allcourses extends StatefulWidget {
  static String routeName = 'Allcourses';
  final bool showNewCourses;

  Allcourses({required this.showNewCourses});

  @override
  State<Allcourses> createState() => _AllcoursesState();
}

class _AllcoursesState extends State<Allcourses> {
  String? departmentFilter;
  String? searchQuery;
  bool isSearchOpen = false;

  _showDepartmentDialog({required Size size}) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: kGreyColor600,
          title: const Text(
            'DEPARTMENTS',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              color: kPrimaryColor,
            ),
          ),
          content: SizedBox(
            width: size.width * 0.9,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: Persistent.departmentList.length,
              itemBuilder: (ctx, index) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      departmentFilter = Persistent.departmentList[index];
                    });
                    Navigator.canPop(context) ? Navigator.pop(context) : null;
                  },
                  child: Row(
                    children: [
                      const Icon(
                        Icons.arrow_right_alt_outlined,
                        color: kGreyColor700,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          Persistent.departmentList[index],
                          style: const TextStyle(
                            color: kBlueColor,
                            fontSize: 16,
                          ),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.canPop(context) ? Navigator.pop(context) : null;
              },
              child: const Text(
                'Close',
                style: TextStyle(
                  color: kBlackColor900,
                  fontSize: 16,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  departmentFilter = null;
                  searchQuery = ''; // Reset search query
                });
                Navigator.canPop(context) ? Navigator.pop(context) : null;
              },
              child: const Text(
                'Cancel Filter',
                style: TextStyle(color: kBlackColor800),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      decoration: const BoxDecoration(
        color: kWhiteColor,
      ),
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              color: kBlueColor,
            ),
          ),
          title: isSearchOpen
              ? TextField(
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                  onSubmitted: (_) {
                    setState(() {
                      isSearchOpen = false;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Search for a course...',
                    border: InputBorder.none,
                  ),
                )
              : const Text('Find A Course here'),
          leading: IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () {
              _showDepartmentDialog(size: size);
            },
          ),
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  isSearchOpen = !isSearchOpen;// show the seach field for user to enter search value
                  searchQuery = null;
                });
              },
              icon: const Icon(
                Icons.search_outlined,
                color: kBlackColor800,
              ),
            ),
          ],
        ),
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('Courses')
              .where('department', isEqualTo: departmentFilter)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                final now = DateTime.now();
                final List<QueryDocumentSnapshot<Map<String, dynamic>>>
                    courseDocs = snapshot.data!.docs.where((doc) {
                  if (widget.showNewCourses) {
                    final createdAtTimestamp =
                        doc.get('createdAt') as Timestamp;
                    final createdAt = createdAtTimestamp.toDate();
                    final difference = now.difference(createdAt);
                    return difference.inDays <= 7 &&
                        (searchQuery == null ||
                            doc
                                .get('courseName')
                                .toLowerCase()
                                .contains(searchQuery!.toLowerCase()));
                  } else {
                    return searchQuery == null ||
                        doc
                            .get('courseName')
                            .toLowerCase()
                            .contains(searchQuery!.toLowerCase());
                  }
                }).toList();

                return ListView.builder(
                  itemCount: courseDocs.length,
                  itemBuilder: (BuildContext context, int index) {
                    final doc = courseDocs[index];
                    final courseId = doc.get('courseId');
                    final courseIcon = doc.get('courseIcon');
                    final course = doc.get('courseName');
                    final description = doc.get('courseInfo');
                    final duration = doc.get('duration');
                    final rating = doc.get('ratings');
                    final department = doc.get('department');

                    return CoursesCard(
                      courseId: courseId,
                      courseIcon: courseIcon,
                      course: course,
                      duration: duration,
                      description: description,
                      rating: rating,
                      department: department,
                    );
                  },
                );
              } else {
                return const Center(
                  child: Text('There are no Courses'),
                );
              }
            }

            return const Center(
              child: Text(
                'Something went wrong',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            );
          },
        ),
      ),
    );
  }
}
