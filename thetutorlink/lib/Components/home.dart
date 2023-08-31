import 'package:flutter/material.dart';
import 'package:thetutorlink/Screens/ChatScreens/chatPage.dart';
import 'package:thetutorlink/Screens/HomeScreens/books.dart';
import 'package:thetutorlink/Screens/HomeScreens/dashboard.dart';
import 'package:thetutorlink/Screens/HomeScreens/mystudents.dart';
import 'package:thetutorlink/Screens/Profile/userProfileScreen.dart';
import 'package:thetutorlink/constants.dart';

class HomeScreenBuilder extends StatefulWidget {
  static String routeName = 'HomeScreenBuilder';

  @override
  State<HomeScreenBuilder> createState() => _HomeScreenBuilderState();
}

class _HomeScreenBuilderState extends State<HomeScreenBuilder> {
  int currentTab = 0;
  final List<Widget> screens = [
    DashBoardScreen(),
    Books(),
    UserProfileScreen(),
    Mystudents(),
  ];

  final PageStorageBucket bucket = PageStorageBucket();
  Widget currentScreen = DashBoardScreen();
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
          //To navigate to the chat screen
          //TODO: Later in hours
          setState(() {
            currentScreen = ChatPage();
            currentTab = 4;
          });
        },
        child: const Icon(
          Icons.wechat_rounded,
          size: 30,
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 60,
          width: MediaQuery.of(context).size.width - 24,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              MaterialButton(
                minWidth: 35,
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
                      color: currentTab == 0 ? kBlueColor : kBlackColor900,
                      height: 28,
                      width: 35,
                    ),
                    Text(
                      'Dashboard',
                      style: TextStyle(
                          fontSize: 10,
                          color: currentTab == 0 ? kBlueColor : kBlackColor900),
                    )
                  ],
                ),
              ),
              MaterialButton(
                minWidth: 40,
                onPressed: () {
                  setState(() {
                    currentScreen = Mystudents();
                    currentTab = 1;
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 40,
                      weight: 10,
                      color: currentTab == 1 ? kBlueColor : kBlackColor900,
                    ),
                    Text(
                      'My Students',
                      style: TextStyle(
                          fontSize: 10,
                          color: currentTab == 1 ? kBlueColor : kBlackColor900),
                    )
                  ],
                ),
              ),
              MaterialButton(
                minWidth: 40,
                onPressed: () {
                  setState(() {
                    currentScreen = Books();
                    currentTab = 2;
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/icons/book.png',
                      color: currentTab == 2 ? kBlueColor : kBlackColor900,
                      height: 30,
                      width: 40,
                    ),
                    Text(
                      'Books',
                      style: TextStyle(
                          fontSize: 10,
                          color: currentTab == 2 ? kBlueColor : kBlackColor900),
                    )
                  ],
                ),
              ),
              MaterialButton(
                minWidth: 35,
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
                      color: currentTab == 3 ? kBlueColor : kBlackColor900,
                      height: 30,
                      width: 30,
                    ),
                    Text(
                      'Profile',
                      style: TextStyle(
                          color: currentTab == 3 ? kBlueColor : kBlackColor900),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
