import 'package:tutorlinkelearning/Screens/ChatRoom/chatheadpage.dart';
import 'package:tutorlinkelearning/Screens/HomeScreens/allcourses.dart';
import 'package:tutorlinkelearning/Screens/HomeScreens/books.dart';
import 'package:tutorlinkelearning/Screens/HomeScreens/dashboard.dart';
import 'package:tutorlinkelearning/Screens/HomeScreens/mycourses.dart';
import 'package:tutorlinkelearning/Screens/Profile/userProfileScreen.dart';
import 'package:tutorlinkelearning/constants.dart';
import 'package:flutter/material.dart';

class HomeScreensBuilder extends StatefulWidget {
  static String routeName = 'HomeScreensBuilder';

  @override
  State<HomeScreensBuilder> createState() => _HomeScreensBuilderState();
}

class _HomeScreensBuilderState extends State<HomeScreensBuilder> {
  int currentTab = 0;
  final List<Widget> screens = [
    DashBoardScreen(),
    const Books(),
    UserProfileScreen(),
    const Mycourses(),
    Allcourses(
      showNewCourses: false,
    ),
  ];

  final PageStorageBucket bucket = PageStorageBucket();
  Widget currentScreen = DashBoardScreen();

  void openDrawer() {
    Scaffold.of(context).openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageStorage(
        child: currentScreen,
        bucket: bucket,
      ),
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onPressed: () {
          //To navigate to the courses screen
          //TODO: Later in hours
          setState(() {
            currentScreen = Allcourses(
              showNewCourses: false,
            );
            currentTab = 4;
          });
        },
        child: const Icon(
          Icons.add,
          size: 30,
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MaterialButton(
                    minWidth: 30,
                    onPressed: () {
                      setState(() {
                        currentScreen = DashBoardScreen();
                        currentTab = 0;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/icons/homepage.png',
                          color: currentTab == 0 ? kBlueColor : Colors.black38,
                          height: 30,
                          width: 30,
                        ),
                        Text(
                          'Dashboard',
                          style: TextStyle(
                              fontSize: 10,
                              color: currentTab == 0
                                  ? kBlueColor
                                  : Colors.black38),
                        )
                      ],
                    ),
                  ),
                  MaterialButton(
                    minWidth: 30,
                    onPressed: () {
                      setState(() {
                        currentScreen = const Mycourses();
                        currentTab = 1;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/icons/e-learning.png',
                          color: currentTab == 1 ? kBlueColor : Colors.black38,
                          height: 30,
                          width: 40,
                        ),
                        Text(
                          'My Courses',
                          style: TextStyle(
                              fontSize: 10,
                              color: currentTab == 1
                                  ? kBlueColor
                                  : Colors.black38),
                        )
                      ],
                    ),
                  )
                ],
              ),
              // Right tab side of the navigation bar
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  MaterialButton(
                    minWidth: 50,
                    onPressed: () {
                      setState(() {
                        currentScreen = const Books();
                        currentTab = 2;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/icons/book.png',
                          color: currentTab == 2 ? kBlueColor : Colors.black38,
                          height: 30,
                          width: 40,
                        ),
                        Text(
                          'Books',
                          style: TextStyle(
                              color: currentTab == 2
                                  ? kBlueColor
                                  : Colors.black38),
                        )
                      ],
                    ),
                  ),
                  MaterialButton(
                    minWidth: 30,
                    onPressed: () {
                      setState(() {
                        currentScreen = UserProfileScreen();
                        currentTab = 3;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/icons/user.png',
                          color: currentTab == 3 ? kBlueColor : Colors.black38,
                          height: 30,
                          width: 30,
                        ),
                        Text(
                          'Profile',
                          style: TextStyle(
                              color: currentTab == 3
                                  ? kBlueColor
                                  : Colors.black38),
                        )
                      ],
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(color: kBlueColor),
              child: Text(
                "TutorLink\n Menu",
                style: TextStyle(color: kWhiteColor, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.bookmark),
              title: const Text('Booksmarks'),
              onTap: () {
                Navigator.pushNamed(context, "BookMarksScreen");
              },
            ),
            ListTile(
              leading: Icon(Icons.chat_rounded),
              title: Text('Chatroom'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ChatPage(), //chat page for the user and his subscribed course with tutor
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
