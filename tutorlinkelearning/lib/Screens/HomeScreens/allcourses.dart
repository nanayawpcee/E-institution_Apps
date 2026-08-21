import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../components/coursecard.dart';
import '../../components/home.dart';
import '../../providers/student_data.dart';
import '../../services/local_auth_service.dart';
import '../../theme/app_assets.dart';
import '../../theme/app_text.dart';
import '../../theme/app_tokens.dart';
import '../../theme/app_widgets.dart';
import '../../utils/coursename.dart';

enum _Sort { rating, duration, newest }

/// Explore tab: the whole catalogue, filterable by department and sortable,
/// with an optional "new this week" narrowing arrived at from the Home banner.
class Allcourses extends ConsumerStatefulWidget {
  static String routeName = 'Allcourses';

  const Allcourses({Key? key, required this.showNewCourses}) : super(key: key);

  /// Opens pre-filtered to courses published in the last week.
  final bool showNewCourses;

  @override
  ConsumerState<Allcourses> createState() => _AllcoursesState();
}

class _AllcoursesState extends ConsumerState<Allcourses> {
  static const List<String> _departments = [
    'All',
    'Computer Science',
    'Mathematics',
    'Biology',
    'UI/UX',
    'Physics',
    'Design',
  ];

  String _search = '';
  String _department = 'All';
  _Sort _sort = _Sort.rating;
  late bool _newOnly = widget.showNewCourses;

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    final student = ref.watch(authProvider);
    final data = ref.watch(studentDataProvider);

    final courses = _visible(data.courses);

    // Reached from the Home banner as a pushed route, so it needs its own
    // Scaffold; as a tab it simply fills the shell's body.
    final body = GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            widget.showNewCourses ? 24 : kTabBottomInset,
          ),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Explore', style: TLText.screenTitle(t.text)),
                ),
                _FilterButton(onTap: _openDepartmentSheet),
              ],
            ),
            const SizedBox(height: 14),
            TLSearchField(
              hint: 'Search for a course...',
              onChanged: (v) => setState(() => _search = v),
            ),
            const SizedBox(height: 14),
            TLChipBar(
              children: [
                for (final sort in _Sort.values)
                  TLChip(
                    label: _sortLabel(sort),
                    selected: _sort == sort,
                    compact: true,
                    color: TLTokens.accent,
                    onTap: () => setState(() => _sort = sort),
                  ),
              ],
            ),
            if (_newOnly) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: _NewOnlyChip(
                  onClear: () => setState(() => _newOnly = false),
                ),
              ),
            ],
            if (_department != 'All') ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Department: $_department',
                  style: TLText.meta(t.textSub),
                ),
              ),
            ],
            const SizedBox(height: 16),
            if (courses.isEmpty)
              const TLEmptyState(
                icon: Icons.explore_outlined,
                title: 'Nothing to show',
                message: 'Try clearing a filter or searching for something else.',
              )
            else
              for (final course in courses)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: CourseCoverCard(
                    course: course,
                    bookmarked:
                        student?.bookmarks.contains(course.courseId) ?? false,
                    onToggleBookmark: () => _toggleBookmark(course),
                  ),
                ),
          ],
        ),
      ),
    );

    if (!widget.showNewCourses) return body;
    return Scaffold(backgroundColor: t.bg, body: body);
  }

  List<CoursesType> _visible(List<CoursesType> all) {
    final courses = all.where((course) {
      final matchesDept =
          _department == 'All' || course.department == _department;
      final matchesSearch = _search.isEmpty ||
          course.name.toLowerCase().contains(_search.toLowerCase());
      final matchesNew = !_newOnly ||
          DateTime.now().difference(course.createdAt).inDays <= 7;
      return matchesDept && matchesSearch && matchesNew;
    }).toList();

    switch (_sort) {
      case _Sort.rating:
        courses.sort((a, b) => b.rating.compareTo(a.rating));
      case _Sort.duration:
        courses.sort((a, b) => a.duration.compareTo(b.duration));
      case _Sort.newest:
        courses.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return courses;
  }

  String _sortLabel(_Sort sort) {
    switch (sort) {
      case _Sort.rating:
        return 'Top rated';
      case _Sort.duration:
        return 'Shortest';
      case _Sort.newest:
        return 'Newest';
    }
  }

  void _toggleBookmark(CoursesType course) {
    final wasBookmarked =
        ref.read(authProvider)?.bookmarks.contains(course.courseId) ?? false;
    ref.read(authProvider.notifier).toggleBookmark(course.courseId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          wasBookmarked ? 'Removed from bookmarks' : 'Added to bookmarks',
        ),
      ),
    );
  }

  Future<void> _openDepartmentSheet() async {
    final t = context.tl;
    await showTLSheet<void>(
      context: context,
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Department', style: TLText.cardTitle(t.text)),
          const SizedBox(height: 6),
          for (final dept in _departments)
            InkWell(
              onTap: () {
                setState(() => _department = dept);
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 4),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: t.border)),
                ),
                child: Text(
                  dept,
                  style: TLText.body(
                    _department == dept ? TLTokens.primary : t.text,
                  ).copyWith(
                    fontWeight:
                        _department == dept ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Department filter affordance, using the bundled filter mark.
class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    return Material(
      color: t.cardAlt,
      borderRadius: BorderRadius.circular(TLTokens.rMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TLTokens.rMd),
        child: SizedBox(
          width: 38,
          height: 38,
          child: Center(
            child: SvgPicture.asset(
              TLAssets.iconFilter,
              width: 18,
              height: 18,
              colorFilter: ColorFilter.mode(t.text, BlendMode.srcIn),
              semanticsLabel: 'Filter by department',
            ),
          ),
        ),
      ),
    );
  }
}

/// Dismissible marker showing the "new this week" narrowing is active.
class _NewOnlyChip extends StatelessWidget {
  const _NewOnlyChip({required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF1E6FF),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onClear,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'New this week',
                style: TLText.meta(TLTokens.accent)
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.close_rounded, size: 13, color: TLTokens.accent),
            ],
          ),
        ),
      ),
    );
  }
}
