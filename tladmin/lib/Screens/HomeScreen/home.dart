import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/admin_data.dart';
import '../../theme/app_tokens.dart';
import '../../utils/responsive.dart';
import '../helpscreen.dart';
import '../policyscreen.dart';
import 'Books/addbooks.dart';
import 'Course/addcourses.dart';
import 'Course/allcourses.dart';
import 'Course/coursedetail.dart';
import 'Requests/requests.dart';
import 'Shell/admin_nav.dart';
import 'Shell/admin_sidebar.dart';
import 'Shell/admin_topbar.dart';
import 'Tutors/acceptedtutors.dart';
import 'Tutors/alltutors.dart';
import 'Tutors/tutordetail.dart';
import 'Tutors/tutorreviews.dart';
import 'dashboard.dart';

/// The admin console shell: navigation rail, topbar and the page it hosts.
///
/// Navigation is state-driven (see [adminNavProvider]) rather than route-based,
/// which is what lets a detail view swap the page body while the surrounding
/// chrome stays put.
class AdminPage extends ConsumerStatefulWidget {
  static String routeName = 'AdminPage';

  const AdminPage({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends ConsumerState<AdminPage> {
  final _searchController = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  String _query = '';
  bool _notificationsOpen = false;
  final Set<String> _readActivityIds = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _pageFor(AdminPageKey key, String? detailId) {
    switch (key) {
      case AdminPageKey.dashboard:
        return const DashboardBody();
      case AdminPageKey.courses:
        return const AllCoursesBody();
      case AdminPageKey.courseDetail:
        return CourseDetailBody(courseId: detailId!);
      case AdminPageKey.addCourse:
        return const AddCourseBody();
      case AdminPageKey.tutors:
        return const AllTutorsBody();
      case AdminPageKey.tutorDetail:
        return TutorDetailBody(tutorId: detailId!);
      case AdminPageKey.addTutor:
        return const AddTutorBody();
      case AdminPageKey.reviews:
        return const TutorReviewsBody();
      case AdminPageKey.books:
        return const BooksBody();
      case AdminPageKey.requests:
        return const RequestsBody();
      case AdminPageKey.help:
        return const HelpBody();
      case AdminPageKey.policy:
        return const PolicyBody();
    }
  }

  List<AdminSearchHit> _hits(AdminData data) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return const [];

    final nav = ref.read(adminNavProvider.notifier);
    void dismiss() {
      _searchController.clear();
      setState(() => _query = '');
    }

    return [
      for (final c in data.courses
          .where((c) => c.name.toLowerCase().contains(q))
          .take(3))
        AdminSearchHit(
          kind: 'Course',
          label: c.name,
          kindColor: TLTokens.primary,
          onSelect: () {
            dismiss();
            nav.openCourse(c.id);
          },
        ),
      for (final t in data.tutors
          .where((t) => t.name.toLowerCase().contains(q))
          .take(3))
        AdminSearchHit(
          kind: 'Tutor',
          label: t.name,
          kindColor: TLTokens.secondary,
          onSelect: () {
            dismiss();
            nav.openTutor(t.id);
          },
        ),
      for (final b in data.bookFiles
          .where((b) => b.name.toLowerCase().contains(q))
          .take(2))
        AdminSearchHit(
          kind: 'Book',
          label: b.name,
          kindColor: TLTokens.success,
          onSelect: () {
            dismiss();
            nav.go(AdminPageKey.books);
          },
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final nav = ref.watch(adminNavProvider);
    final data = ref.watch(adminDataProvider);
    final activity = buildAdminActivity(data);
    final hasUnread = activity.any((a) => !_readActivityIds.contains(a.id));
    final wide = Responsive.isDesktop(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: context.tl.bg,
      drawer: wide ? null : Drawer(
        backgroundColor: context.tl.card,
        width: 230,
        child: AdminSidebar(
          onNavigate: () => Navigator.of(context).pop(),
        ),
      ),
      body: Row(
        children: [
          if (wide) const AdminSidebar(),
          Expanded(
            child: Stack(
              children: [
                Column(
                  children: [
                    AdminTopbar(
                      searchController: _searchController,
                      onSearchChanged: (v) => setState(() => _query = v),
                      hasUnread: hasUnread,
                      onToggleNotifications: () => setState(() {
                        _notificationsOpen = !_notificationsOpen;
                      }),
                      onOpenMenu: wide
                          ? null
                          : () => _scaffoldKey.currentState?.openDrawer(),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(28, 26, 28, 40),
                        child: _pageFor(nav.page, nav.detailId),
                      ),
                    ),
                  ],
                ),
                if (_query.trim().isNotEmpty)
                  Positioned(
                    top: 70,
                    left: 22,
                    child: AdminSearchDropdown(hits: _hits(data)),
                  ),
                if (_notificationsOpen)
                  Positioned(
                    top: 64,
                    right: 20,
                    child: AdminActivityDropdown(
                      items: activity,
                      readIds: _readActivityIds,
                      onMarkAllRead: () => setState(() {
                        _readActivityIds.addAll(activity.map((a) => a.id));
                      }),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
