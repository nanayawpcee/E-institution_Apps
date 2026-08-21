import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../components/coursecard.dart';
import '../../components/home.dart';
import '../../providers/student_data.dart';
import '../../services/chat_read_state.dart';
import '../../services/local_auth_service.dart';
import '../../theme/app_assets.dart';
import '../../theme/app_text.dart';
import '../../theme/app_tokens.dart';
import '../../theme/app_widgets.dart';
import '../Bookmark/bookmarkedcourses.dart';
import '../ChatRoom/chatheadpage.dart';
import 'allcourses.dart';

/// Home tab: greeting, search, the "new this week" banner, department filters
/// and the course list.
class DashBoardScreen extends ConsumerStatefulWidget {
  static String routeName = 'DashBoardScreen';

  const DashBoardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends ConsumerState<DashBoardScreen> {
  static const List<String> _departments = [
    'All',
    'Computer Science',
    'Mathematics',
    'Biology',
    'UI/UX',
  ];

  String _search = '';
  String _department = 'All';

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    final student = ref.watch(authProvider);
    final data = ref.watch(studentDataProvider);

    final firstName =
        (student?.name ?? '').split(' ').firstWhere((s) => s.isNotEmpty,
            orElse: () => 'there');

    final courses = data.courses.where((course) {
      final matchesDept =
          _department == 'All' || course.department == _department;
      final matchesSearch = _search.isEmpty ||
          course.name.toLowerCase().contains(_search.toLowerCase());
      return matchesDept && matchesSearch;
    }).toList();

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, kTabBottomInset),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, $firstName',
                        style: TLText.screenTitle(t.text),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'What do you want to learn today?',
                        style: TLText.sub(t.textSub),
                      ),
                    ],
                  ),
                ),
                TLIconButton(
                  icon: Icons.bookmark_border_rounded,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookedMarked(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _ChatButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChatPage()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            TLSearchField(
              hint: 'Search courses, tutors...',
              onChanged: (v) => setState(() => _search = v),
            ),
            const SizedBox(height: 18),
            _NewThisWeekBanner(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Allcourses(showNewCourses: true),
                ),
              ),
            ),
            const SizedBox(height: 26),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: Text('Courses', style: TLText.sectionTitle(t.text)),
                ),
                InkWell(
                  onTap: () => HomeTabScope.maybeOf(context)?.goToTab(2),
                  child: Text(
                    'View all',
                    style: TLText.sub(TLTokens.primary)
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TLChipBar(
              children: [
                for (final dept in _departments)
                  TLChip(
                    label: dept,
                    selected: _department == dept,
                    onTap: () => setState(() => _department = dept),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (courses.isEmpty)
              const TLEmptyState(
                icon: Icons.search_off_rounded,
                title: 'No courses match',
                message: 'Try another department or search term.',
              )
            else
              for (final course in courses)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CourseRow(course: course),
                ),
          ],
        ),
      ),
    );
  }
}

/// Promo banner pointing at courses published in the last week.
///
/// The bundled `newcourses` illustration already carries its own artwork and
/// call to action, so the banner just frames it at the design's height.
class _NewThisWeekBanner extends StatelessWidget {
  const _NewThisWeekBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    return Material(
      color: t.cardAlt,
      borderRadius: BorderRadius.circular(TLTokens.rXl),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 92,
          width: double.infinity,
          child: SvgPicture.asset(
            TLAssets.newCourses,
            fit: BoxFit.cover,
            alignment: Alignment.centerLeft,
            semanticsLabel: 'New courses this week',
          ),
        ),
      ),
    );
  }
}

/// Chat entry point in the header, badged when a tutor has written since the
/// student last opened that thread.
class _ChatButton extends ConsumerWidget {
  const _ChatButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tl;
    final student = ref.watch(authProvider);
    final chats = ref.watch(studentDataProvider).chats;
    ref.watch(chatReadProvider);
    final read = ref.read(chatReadProvider.notifier);

    final studentId = student?.id ?? '';
    final unread = chats.entries.any(
      (e) => read.isUnread(e.key, e.value, myId: studentId),
    );

    return Material(
      color: t.cardAlt,
      borderRadius: BorderRadius.circular(TLTokens.rMd),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(TLTokens.rMd),
        child: SizedBox(
          width: 38,
          height: 38,
          child: Center(
            child: TLChatIcon(color: t.text, size: 21, unread: unread),
          ),
        ),
      ),
    );
  }
}
