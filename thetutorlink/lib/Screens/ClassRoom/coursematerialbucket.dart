import 'package:flutter/material.dart';
import 'package:thetutorlink/Screens/ClassRoom/assignment.dart';
import 'package:thetutorlink/Screens/ClassRoom/resourceroom.dart';
import 'package:thetutorlink/Screens/ClassRoom/settingspage.dart';
import 'package:thetutorlink/constants.dart';

class CourseMaterialPage extends StatefulWidget {
  final String studentId;
  final String tutorId;

  const CourseMaterialPage({required this.studentId, required this.tutorId});
  @override
  _CourseMaterialPageState createState() => _CourseMaterialPageState();
}

class _CourseMaterialPageState extends State<CourseMaterialPage> {
  final PageController _pageController = PageController();
  List<Widget> _pages = [];

  int _currentPageIndex = 0;



  void _onMenuItemTap(int index) {
    setState(() {
      _currentPageIndex = index;
      _pageController.jumpToPage(index);
    });
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    _pages = [
      ResourcePage(
        studentId: widget.studentId,
      ),
      AssignmentsPage(studentId: widget.studentId),
      SettingsPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: _pages,
        onPageChanged: (index) {
          setState(() {
            _currentPageIndex = index;
          });
        },
      ),
      drawer: Drawer(
        backgroundColor: kBlueColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              child: Text(
                'Classroom',
                style: TextStyle(fontSize: 30, color: kYellowColor),
              ),
              decoration: BoxDecoration(
                color: kGreyColor800,
                image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage('assets/images/class.png')),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.book,
                color: kGreyColor500,
              ),
              title: const Text('Resources',
                  style: TextStyle(color: kWhiteColor, fontSize: 18)),
              selected: _currentPageIndex == 0,
              onTap: () => _onMenuItemTap(0),
            ),
            ListTile(
              leading: const Icon(
                Icons.assignment_add,
                color: kGreyColor500,
              ),
              title: const Text(
                'Assignments',
                style: TextStyle(color: kWhiteColor, fontSize: 18),
              ),
              selected: _currentPageIndex == 1,
              onTap: () => _onMenuItemTap(1),
            ),
            ListTile(
              leading: const Icon(
                Icons.settings,
                color: kGreyColor500,
              ),
              title: const Text('Settings Page',
                  style: TextStyle(color: kWhiteColor, fontSize: 18)),
              selected: _currentPageIndex == 2,
              onTap: () => _onMenuItemTap(2),
            ),
          ],
        ),
      ),
    );
  }
}
