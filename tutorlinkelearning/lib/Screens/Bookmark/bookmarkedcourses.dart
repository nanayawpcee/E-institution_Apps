import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../components/coursecard.dart';
import '../../providers/student_data.dart';
import '../../services/local_auth_service.dart';
import '../../theme/app_tokens.dart';
import '../../theme/app_widgets.dart';
import '../../utils/coursename.dart';

/// Courses the student has saved, reachable from the Home header.
class BookedMarked extends ConsumerStatefulWidget {
  static String routeName = 'BookMarksScreen';

  const BookedMarked({Key? key}) : super(key: key);

  @override
  ConsumerState<BookedMarked> createState() => _BookedMarkedState();
}

class _BookedMarkedState extends ConsumerState<BookedMarked> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    final student = ref.watch(authProvider);
    ref.watch(studentDataProvider);

    final courses = student == null
        ? <CoursesType>[]
        : ref
            .read(studentDataProvider.notifier)
            .coursesByIds(student.bookmarks)
            .where((c) =>
                c.name.toLowerCase().contains(_search.toLowerCase()))
            .toList();

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(title: const Text('Bookmarks')),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            TLSearchField(
              hint: 'Search bookmarks',
              onChanged: (v) => setState(() => _search = v),
            ),
            const SizedBox(height: 16),
            if (courses.isEmpty)
              const TLEmptyState(
                icon: Icons.bookmark_border_rounded,
                title: 'No bookmarks yet',
                message: 'Save a course from Explore and it will show up here.',
              )
            else
              for (final course in courses)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: CourseCoverCard(
                    course: course,
                    bookmarked: true,
                    onToggleBookmark: () => ref
                        .read(authProvider.notifier)
                        .toggleBookmark(course.courseId),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
