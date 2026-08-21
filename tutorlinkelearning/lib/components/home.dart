import 'package:flutter/material.dart';

import '../Screens/ChatRoom/aithread.dart';
import '../Screens/HomeScreens/allcourses.dart';
import '../Screens/HomeScreens/books.dart';
import '../Screens/HomeScreens/dashboard.dart';
import '../Screens/HomeScreens/mycourses.dart';
import '../Screens/Profile/userProfileScreen.dart';
import '../theme/app_tokens.dart';
import '../theme/app_widgets.dart';

/// The signed-in shell: five tabs behind a frosted bottom bar, matching the
/// design's Home / My Courses / Explore / Books / Profile order.
///
/// The bar floats over the content (the tabs pad their own bottoms), which is
/// what gives the translucent blur something to blur.
class HomeScreensBuilder extends StatefulWidget {
  static String routeName = 'HomeScreensBuilder';

  const HomeScreensBuilder({Key? key, this.initialTab = 0}) : super(key: key);

  final int initialTab;

  @override
  State<HomeScreensBuilder> createState() => _HomeScreensBuilderState();
}

class _HomeScreensBuilderState extends State<HomeScreensBuilder> {
  static const List<TLNavItem> _items = [
    TLNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    TLNavItem(
      icon: Icons.school_outlined,
      activeIcon: Icons.school_rounded,
      label: 'My Courses',
    ),
    TLNavItem(
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore_rounded,
      label: 'Explore',
    ),
    TLNavItem(
      icon: Icons.menu_book_outlined,
      activeIcon: Icons.menu_book_rounded,
      label: 'Books',
    ),
    TLNavItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  late int _tab = widget.initialTab;

  /// Each tab keeps its own Navigator-free page; IndexedStack preserves their
  /// scroll offsets and field contents across switches.
  late final List<Widget> _screens = const [
    DashBoardScreen(),
    Mycourses(),
    Allcourses(showNewCourses: false),
    Books(),
    UserProfileScreen(),
  ];

  /// Lets a tab hand the user to another tab — "View all" jumps to Explore.
  void _goTo(int index) => setState(() => _tab = index);

  @override
  Widget build(BuildContext context) {
    return HomeTabScope(
      goToTab: _goTo,
      child: Scaffold(
        backgroundColor: context.tl.bg,
        extendBody: true,
        body: IndexedStack(index: _tab, children: _screens),
        // Sits just above the nav bar so the assistant is one tap away from
        // any tab.
        floatingActionButton: const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: AiFab(),
        ),
        bottomNavigationBar: TLBottomNav(
          currentIndex: _tab,
          onTap: _goTo,
          items: _items,
        ),
      ),
    );
  }
}

/// Exposes tab switching to descendants without threading callbacks through
/// every screen.
class HomeTabScope extends InheritedWidget {
  const HomeTabScope({
    Key? key,
    required this.goToTab,
    required Widget child,
  }) : super(key: key, child: child);

  final void Function(int index) goToTab;

  static HomeTabScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<HomeTabScope>();

  @override
  bool updateShouldNotify(HomeTabScope oldWidget) => false;
}

/// Bottom padding a tab needs so its last row clears the floating nav bar.
const double kTabBottomInset = 96;
