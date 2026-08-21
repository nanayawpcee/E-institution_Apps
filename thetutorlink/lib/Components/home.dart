import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../Screens/ChatScreens/aithread.dart';
import '../Screens/ChatScreens/chatPage.dart';
import '../Screens/HomeScreens/books.dart';
import '../Screens/HomeScreens/dashboard.dart';
import '../Screens/HomeScreens/mystudents.dart';
import '../Screens/Profile/userProfileScreen.dart';
import '../providers/tutor_data.dart';
import '../services/chat_read_state.dart';
import '../services/local_auth_service.dart';
import '../theme/app_tokens.dart';
import '../theme/app_widgets.dart';

/// The signed-in shell: five tabs behind a frosted bottom bar, matching the
/// design's Dashboard / Students / Chat / Books / Profile order.
///
/// The bar floats over the content (the tabs pad their own bottoms), which is
/// what gives the translucent blur something to blur.
class HomeScreensBuilder extends ConsumerStatefulWidget {
  static String routeName = 'HomeScreensBuilder';

  const HomeScreensBuilder({Key? key, this.initialTab = 0}) : super(key: key);

  final int initialTab;

  @override
  ConsumerState<HomeScreensBuilder> createState() => _HomeScreensBuilderState();
}

class _HomeScreensBuilderState extends ConsumerState<HomeScreensBuilder> {
  /// Nav items for this frame. [unreadChats] is resolved in [build] so the
  /// Riverpod dependency is registered on this widget, not on the child that
  /// runs the icon builder.
  List<TLNavItem> _items({required bool unreadChats}) => [
        _base[0],
        _base[1],
        TLNavItem(
          icon: _base[2].icon,
          activeIcon: _base[2].activeIcon,
          label: _base[2].label,
          iconBuilder: (context, selected, color) =>
              TLChatIcon(color: color, size: 22, unread: unreadChats),
        ),
        _base[3],
        _base[4],
      ];

  static const List<TLNavItem> _base = [
    TLNavItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
      label: 'Dashboard',
    ),
    TLNavItem(
      icon: Icons.people_outline,
      activeIcon: Icons.people_rounded,
      label: 'Students',
    ),
    TLNavItem(
      icon: Icons.forum_outlined,
      activeIcon: Icons.forum_rounded,
      label: 'Chat',
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

  /// IndexedStack preserves each tab's scroll offset and field contents
  /// across switches.
  late final List<Widget> _screens = const [
    DashBoardScreen(),
    MyStudents(),
    ChatPage(),
    Books(),
    UserProfileScreen(),
  ];

  void _goTo(int index) => setState(() => _tab = index);

  @override
  Widget build(BuildContext context) {
    // True when any student has written since the tutor last opened that
    // thread; drives the badge on the Chat tab.
    final tutorId = ref.watch(authProvider)?.id ?? '';
    final chats = ref.watch(tutorDataProvider).chats;
    ref.watch(chatReadProvider);
    final read = ref.read(chatReadProvider.notifier);
    final unreadChats = chats.entries
        .any((e) => read.isUnread(e.key, e.value, myId: tutorId));

    return HomeTabScope(
      goToTab: _goTo,
      child: Scaffold(
        backgroundColor: context.tl.bg,
        extendBody: true,
        body: IndexedStack(index: _tab, children: _screens),
        // Sits just above the nav bar so the assistant is one tap away from
        // any tab. Hidden on Chat, where its row is already on screen.
        floatingActionButton: _tab == 2
            ? null
            : const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: AiFab(),
              ),
        bottomNavigationBar: TLBottomNav(
          currentIndex: _tab,
          onTap: _goTo,
          items: _items(unreadChats: unreadChats),
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
