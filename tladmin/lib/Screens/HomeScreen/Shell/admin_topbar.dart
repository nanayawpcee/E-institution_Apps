import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/admin_data.dart';
import '../../../theme/app_text.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/app_tokens.dart';
import '../../../theme/app_widgets.dart';

/// A hit from the global search well.
class AdminSearchHit {
  const AdminSearchHit({
    required this.kind,
    required this.label,
    required this.kindColor,
    required this.onSelect,
  });

  final String kind;
  final String label;
  final Color kindColor;
  final VoidCallback onSelect;
}

/// An entry in the activity dropdown, derived from live admin data rather
/// than a separate notification store.
class AdminActivity {
  const AdminActivity({
    required this.id,
    required this.title,
    required this.time,
  });

  final String id;
  final String title;
  final String time;
}

/// Console topbar: global search, theme toggle, activity bell, identity chip.
class AdminTopbar extends ConsumerWidget {
  const AdminTopbar({
    Key? key,
    required this.searchController,
    required this.onSearchChanged,
    required this.onToggleNotifications,
    required this.hasUnread,
    this.onOpenMenu,
  }) : super(key: key);

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onToggleNotifications;
  final bool hasUnread;

  /// Supplied on narrow layouts, where the sidebar collapses into a drawer.
  final VoidCallback? onOpenMenu;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tl;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        color: t.card,
        border: Border(bottom: BorderSide(color: t.border)),
      ),
      child: Row(
        children: [
          if (onOpenMenu != null) ...[
            TLIconButton(icon: Icons.menu_rounded, onPressed: onOpenMenu),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              width: 320,
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: t.cardAlt,
                borderRadius: BorderRadius.circular(TLTokens.rSm),
              ),
              child: Row(
                children: [
                  Icon(Icons.search_rounded, size: 16, color: t.textSub),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      onChanged: onSearchChanged,
                      style: TLText.sub(t.text).copyWith(fontSize: 13.5),
                      decoration: InputDecoration(
                        isDense: true,
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        hintText: 'Search courses, tutors, books...',
                        hintStyle: TLText.sub(t.textSub).copyWith(fontSize: 13.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          TLIconButton(
            icon: isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            tooltip: isDark ? 'Switch to light' : 'Switch to dark',
            onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
          ),
          const SizedBox(width: 10),
          TLIconButton(
            icon: Icons.notifications_none_rounded,
            badge: hasUnread,
            tooltip: 'Activity',
            onPressed: onToggleNotifications,
          ),
          const SizedBox(width: 10),
          Container(width: 1, height: 26, color: t.border),
          const SizedBox(width: 10),
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              gradient: TLTokens.brandGradient,
              shape: BoxShape.circle,
            ),
            child: Text(
              'AD',
              style: TLText.buttonSm(Colors.white).copyWith(fontSize: 12),
            ),
          ),
          const SizedBox(width: 8),
          Text('Admin', style: TLText.bodyStrong(t.text).copyWith(fontSize: 13)),
        ],
      ),
    );
  }
}

/// Floating result list under the search well.
class AdminSearchDropdown extends StatelessWidget {
  const AdminSearchDropdown({Key? key, required this.hits}) : super(key: key);

  final List<AdminSearchHit> hits;

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    return _Dropdown(
      width: 320,
      padding: EdgeInsets.zero,
      child: hits.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(14),
              child: Text('No matches', style: TLText.sub(t.textSub)),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final hit in hits)
                  InkWell(
                    onTap: hit.onSelect,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: t.border)),
                      ),
                      child: Row(
                        children: [
                          TLTag(
                            label: hit.kind,
                            color: hit.kindColor,
                            background: t.cardAlt,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              hit.label,
                              overflow: TextOverflow.ellipsis,
                              style: TLText.sub(t.text).copyWith(fontSize: 13.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

/// Floating activity list under the bell.
class AdminActivityDropdown extends StatelessWidget {
  const AdminActivityDropdown({
    Key? key,
    required this.items,
    required this.readIds,
    required this.onMarkAllRead,
  }) : super(key: key);

  final List<AdminActivity> items;
  final Set<String> readIds;
  final VoidCallback onMarkAllRead;

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    return _Dropdown(
      width: 300,
      maxHeight: 340,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text('Activity', style: TLText.cardTitle(t.text)),
                ),
                InkWell(
                  onTap: onMarkAllRead,
                  child: Text(
                    'Mark all read',
                    style: TLText.bodyStrong(TLTokens.primary)
                        .copyWith(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text('Nothing new', style: TLText.sub(t.textSub)),
            ),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 9),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    margin: const EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: readIds.contains(item.id)
                          ? t.border
                          : TLTokens.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: TLText.bodyStrong(t.text).copyWith(fontSize: 13),
                        ),
                        const SizedBox(height: 2),
                        Text(item.time, style: TLText.caption(t.textSub)),
                      ],
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

/// Shared chrome for both dropdowns: card surface, hairline border, drop shadow.
class _Dropdown extends StatelessWidget {
  const _Dropdown({
    required this.child,
    required this.width,
    this.maxHeight,
    this.padding = const EdgeInsets.all(10),
  });

  final Widget child;
  final double width;
  final double? maxHeight;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    return Material(
      color: t.card,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: width,
        constraints:
            maxHeight != null ? BoxConstraints(maxHeight: maxHeight!) : null,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: t.border),
          boxShadow: [
            BoxShadow(
              color: t.shadow,
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

/// Builds the activity feed the bell shows, straight from admin data.
List<AdminActivity> buildAdminActivity(AdminData data) {
  final items = <AdminActivity>[];

  for (final request in data.requests.where((r) => r.isPending)) {
    final course = data.courses.where((c) => c.id == request.courseId);
    final tutor = data.tutors.where((t) => t.id == request.tutorId);
    items.add(AdminActivity(
      id: 'req-${request.id}',
      title: 'Pending request'
          '${course.isEmpty ? '' : ' · ${course.first.name}'}',
      time: tutor.isEmpty ? 'Awaiting approval' : 'For ${tutor.first.name}',
    ));
  }

  final reviews = [...data.tutorReviews]
    ..sort((a, b) => b.timePosted.compareTo(a.timePosted));
  for (final review in reviews.take(3)) {
    items.add(AdminActivity(
      id: 'rev-${review.id}',
      title: '${review.postedBy} reviewed a tutor',
      time: _relative(review.timePosted),
    ));
  }

  return items;
}

String _relative(DateTime when) {
  final diff = DateTime.now().difference(when);
  if (diff.inDays >= 1) return '${diff.inDays}d ago';
  if (diff.inHours >= 1) return '${diff.inHours}h ago';
  if (diff.inMinutes >= 1) return '${diff.inMinutes}m ago';
  return 'Just now';
}
