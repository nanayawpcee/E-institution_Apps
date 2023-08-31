import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:tutorlinkelearning/components/coursecard.dart';
import 'package:tutorlinkelearning/components/courses.dart';
import 'package:tutorlinkelearning/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'allcourses.dart';

class DashBoardScreen extends StatefulWidget {
  static String routeName = 'DashBoardScreen';
  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? userName = '';
  String searchText = '';

  String selectedDepartment = 'All';

  void updateSelectedDepartment(String department) {
    setState(() {
      selectedDepartment = department;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      String? title = message.notification!.title;
      String? body = message.notification!.body;
      AwesomeNotifications().createNotification(
          content: NotificationContent(
              id: 123,
              channelKey: 'request_channel',
              color: Colors.white,
              title: title,
              body: body,
              category: NotificationCategory.Call,
              wakeUpScreen: true,
              fullScreenIntent: true,
              autoDismissible: false,
              backgroundColor: Colors.orange),
          actionButtons: [
            NotificationActionButton(
                key: "Ok",
                label: "Okay",
                color: kBlueColor,
                autoDismissible: true),
          ]);
    });
  }

  Future<void> _loadUserData() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final userData = await FirebaseFirestore.instance
          .collection('Students')
          .doc(currentUser.uid)
          .get();
      final fullName = userData['name'] ?? '';
      userName = getFirstName(fullName);
      setState(() {});
    }
  }

  String getFirstName(String fullName) {
    if (fullName.isEmpty) return '';

    List<String> names = fullName.split(' ');
    String firstName = names[0];

    return firstName;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                          onTap: () {
                            Scaffold.of(context).openDrawer();
                          },
                          child:
                              SvgPicture.asset('assets/icons/hamburger.svg')),
                    ],
                  ),
                  const SizedBox(
                    height: 14,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.headlineMedium,
                          children: <TextSpan>[
                            const TextSpan(
                              text: 'Hello, ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: userName,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall!
                                  .copyWith(
                                    color: kBlackColor900,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 14,
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'What do you want to learn?',
                        style: TextStyle(wordSpacing: 2),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextField(
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
                        borderRadius: BorderRadius.circular(20),
                      ),
                      hintText: 'Search...',
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchText = value;
                      });
                    },
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height / 6,
                    child: Stack(children: [
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: kGreyColor600,
                            image: const DecorationImage(
                                image:
                                    AssetImage('assets/images/newcourse.jpeg'),
                                fit: BoxFit.fill)),
                      ),
                      Positioned(
                        bottom: 4,
                        left: 8,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    Allcourses(showNewCourses: true),
                              ),
                            );
                          },
                          child: const Text('View'),
                        ),
                      )
                    ]),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Course',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, 'Allcourses');
                        },
                        child: const Text(
                          'View all',
                          style: TextStyle(fontSize: 16, color: kBlueColor),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      DepartmentsList(
                          onDepartmentSelected: updateSelectedDepartment),
                    ],
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  SizedBox(
                    height: 200,
                    width: MediaQuery.of(context).size.width - 30,
                    child: CourseCardListView(
                      selectedDepartment: selectedDepartment,
                      searchText: searchText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
