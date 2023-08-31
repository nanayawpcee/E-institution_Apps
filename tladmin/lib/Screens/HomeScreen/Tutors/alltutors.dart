import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tladmin/constants.dart';
import '../../../models/tutorclass.dart';

class AllTutorsScreen extends StatefulWidget {
  static String routeName = 'AllTutorsScreen';

  @override
  _AllTutorsScreenState createState() => _AllTutorsScreenState();
}

class _AllTutorsScreenState extends State<AllTutorsScreen> {
  List<AllTutors> _tutors = [];
  AllTutors? _selectedTutor;

  @override
  void initState() {
    super.initState();
    fetchTutors();
  }

 void fetchTutors() async {
  QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('Tutors').get();

  List<AllTutors> tutors = [];

  for (QueryDocumentSnapshot doc in querySnapshot.docs) {
    AllTutors tutor = AllTutors(
      id: doc.id,
      name: doc['name'],
      email: doc['email'],
      imageUrl: doc['userImage'],
      contact: doc['contact'],
      completedClassCount: doc['numberofstds'],
      tutorAvailability: doc['available'],
      tutorRating: doc['rating'],
      activeClassCount: 0,
      pendingClassCount: 0,
      courses: [],
    );

    // Fetch additional data
    await fetchActiveClasses(tutor);
    await fetchPendingClasses(tutor);
    await fetchCourses(tutor);

    tutors.add(tutor);
  }

  setState(() {
    _tutors = tutors;
    if (tutors.isNotEmpty) {
      _selectedTutor = tutors[0]; 
    }
  });
}

Future<void> fetchActiveClasses(AllTutors tutor) async {
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('Classroom')
      .where('tutorId', isEqualTo: tutor.id)
      .get();

  tutor.activeClassCount = querySnapshot.docs.length;
}

Future<void> fetchPendingClasses(AllTutors tutor) async {
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('Requests')
      .where('tutorId', isEqualTo: tutor.id)
      .where('isPending', isEqualTo: true)
      .get();

  tutor.pendingClassCount = querySnapshot.docs.length;
}

Future<void> fetchCourses(AllTutors tutor) async {
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('Courses')
      .where('tutors', arrayContains: tutor.id)
      .get();

  List<String> courses = querySnapshot.docs
      .map((doc) => doc['courseName'] as String)
      .toList();

  tutor.courses = courses;
}


  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: DataTable(
            decoration: const BoxDecoration(color: kGreyColor500),
            border: TableBorder.all(
              color: kGreyColor600,
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(8)),
            ),
            dividerThickness: 3,
            showBottomBorder: true,
            columns: const [
              DataColumn(label: Text('Image')),
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Email')),
              DataColumn(label: Text('Contact')),
            ],
            rows: _tutors.map((allTutors) {
              return DataRow(
                onSelectChanged: (selected) {
                  setState(() {
                    _selectedTutor = allTutors;
                  });
                },
                cells: [
                  DataCell(
                    Container(
                      decoration: BoxDecoration(
                        color: kBlueColor,
                        image: DecorationImage(
                          image: NetworkImage(allTutors.imageUrl),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),
                  DataCell(Text(allTutors.name)),
                  DataCell(Text(allTutors.email)),
                  DataCell(Text(allTutors.contact.isNotEmpty
                      ? allTutors.contact
                      : 'N/A')),
                ],
              );
            }).toList(),
          ),
        ),
        Expanded(
          flex: 0,
          child: _selectedTutor != null
              ? SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Container(
                    width: MediaQuery.of(context).size.width / 5,
                    height: MediaQuery.of(context).size.height / 1.5,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: kGreyColor700),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Container(
                          height: 100,
                          width: 80,
                          decoration: BoxDecoration(
                            color: kBlueColor,
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: NetworkImage(_selectedTutor!.imageUrl),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text('Name: ${_selectedTutor!.name}'),
                            Text('Email: ${_selectedTutor!.email}'),
                            Text(
                              _selectedTutor!.contact.isNotEmpty
                                  ? 'Contact: ${_selectedTutor!.contact}'
                                  : 'Contact: N/A',
                            ),
                            Text(
                                'Active Classes: ${_selectedTutor!.activeClassCount}'),
                            Text(
                                'Pending Classes: ${_selectedTutor!.pendingClassCount}'),
                            Text(
                                'Completed Classes: ${_selectedTutor!.completedClassCount}'),
                            Text(
                                'Rating: ${_selectedTutor!.tutorRating.toString()}.0'),
                            Text(
                                'Availability: ${_selectedTutor!.tutorAvailability ? "Available" : "Not Available"}'),
                            Text(
                              'Courses: ${_selectedTutor!.courses.join(', ')}',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              : const Center(
                  child: Text('No tutor selected'),
                ),
        ),
      ],
    );
  }

}
