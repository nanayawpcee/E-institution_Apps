import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Every destination the console can show. The design drives navigation from
/// a single `page` value rather than the Navigator, so detail views replace
/// the page body instead of pushing a route.
enum AdminPageKey {
  dashboard,
  courses,
  courseDetail,
  addCourse,
  tutors,
  tutorDetail,
  addTutor,
  reviews,
  books,
  requests,
  help,
  policy,
}

@immutable
class AdminNavState {
  const AdminNavState({this.page = AdminPageKey.dashboard, this.detailId});

  final AdminPageKey page;

  /// Course or tutor id backing [AdminPageKey.courseDetail] /
  /// [AdminPageKey.tutorDetail].
  final String? detailId;

  /// The sidebar row that should read as active. Detail views keep their
  /// parent list highlighted.
  AdminPageKey get activeNav {
    switch (page) {
      case AdminPageKey.courseDetail:
        return AdminPageKey.courses;
      case AdminPageKey.tutorDetail:
        return AdminPageKey.tutors;
      default:
        return page;
    }
  }
}

class AdminNavNotifier extends StateNotifier<AdminNavState> {
  AdminNavNotifier() : super(const AdminNavState());

  void go(AdminPageKey page) => state = AdminNavState(page: page);

  void openCourse(String id) =>
      state = AdminNavState(page: AdminPageKey.courseDetail, detailId: id);

  void openTutor(String id) =>
      state = AdminNavState(page: AdminPageKey.tutorDetail, detailId: id);
}

final adminNavProvider =
    StateNotifierProvider<AdminNavNotifier, AdminNavState>(
        (ref) => AdminNavNotifier());
