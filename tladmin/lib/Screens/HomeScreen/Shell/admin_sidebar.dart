import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/admin_data.dart';
import '../../../theme/app_assets.dart';
import '../../../services/local_auth_service.dart';
import '../../../theme/app_text.dart';
import '../../../theme/app_tokens.dart';
import '../../SignIn/signinscreen.dart';
import 'admin_nav.dart';

class _NavItem {
  const _NavItem(this.key, this.label, this.icon);
  final AdminPageKey key;
  final String label;
  final IconData icon;
}

class _NavGroup {
  const _NavGroup(this.header, this.items);
  final String header;
  final List<_NavItem> items;
}

/// Grouped navigation rail — 230px, card surface, hairline right border.
class AdminSidebar extends ConsumerWidget {
  const AdminSidebar({Key? key, this.onNavigate}) : super(key: key);

  /// Fired after a destination is picked, so the drawer can close itself on
  /// narrow layouts.
  final VoidCallback? onNavigate;

  static const List<_NavGroup> _groups = [
    _NavGroup('Overview', [
      _NavItem(AdminPageKey.dashboard, 'Dashboard', Icons.dashboard_outlined),
    ]),
    _NavGroup('Courses', [
      _NavItem(AdminPageKey.courses, 'All Courses', Icons.menu_book_outlined),
      _NavItem(AdminPageKey.addCourse, 'Add Course', Icons.add_circle_outline),
    ]),
    _NavGroup('Tutors', [
      _NavItem(AdminPageKey.tutors, 'All Tutors', Icons.people_outline),
      _NavItem(AdminPageKey.addTutor, 'Add Tutor', Icons.add_circle_outline),
      _NavItem(AdminPageKey.reviews, 'Reviews', Icons.star_outline_rounded),
    ]),
    _NavGroup('Content', [
      _NavItem(AdminPageKey.books, 'Books', Icons.library_books_outlined),
      _NavItem(AdminPageKey.requests, 'Requests', Icons.inbox_outlined),
    ]),
    _NavGroup('Support', [
      _NavItem(AdminPageKey.help, 'Help', Icons.help_outline_rounded),
      _NavItem(AdminPageKey.policy, 'Policy', Icons.shield_outlined),
    ]),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tl;
    final active = ref.watch(adminNavProvider).activeNav;
    final data = ref.watch(adminDataProvider);
    final pendingRequests = data.requests.where((r) => r.isPending).length;

    return Container(
      width: 230,
      decoration: BoxDecoration(
        color: t.card,
        border: Border(right: BorderSide(color: t.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _BrandLockup(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              children: [
                for (final group in _groups) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 14, 10, 6),
                    child: Text(
                      group.header.toUpperCase(),
                      style: TLText.groupHeader(t.textSub),
                    ),
                  ),
                  for (final item in group.items)
                    _NavRow(
                      item: item,
                      active: active == item.key,
                      badge: item.key == AdminPageKey.requests &&
                              pendingRequests > 0
                          ? '$pendingRequests'
                          : null,
                      onTap: () {
                        ref.read(adminNavProvider.notifier).go(item.key);
                        onNavigate?.call();
                      },
                    ),
                ],
              ],
            ),
          ),
          _LogoutRow(
            onTap: () async {
              await ref.read(authProvider.notifier).signOut();
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                context,
                SignInScreen.routeName,
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _BrandLockup extends StatelessWidget {
  const _BrandLockup();

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      child: Row(
        children: [
          Image.asset(
            TLAssets.logo,
            height: 34,
            fit: BoxFit.contain,
            // The wordmark already reads "TutorLink"; the adjacent label
            // qualifies it as the admin console.
            semanticLabel: 'TutorLink',
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Admin',
              style: TLText.sidebarBrand(t.text),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.item,
    required this.active,
    required this.onTap,
    this.badge,
  });

  final _NavItem item;
  final bool active;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    final color = active ? TLTokens.primary : t.textSub;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: active ? t.cardAlt : Colors.transparent,
        borderRadius: BorderRadius.circular(TLTokens.rSm),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(TLTokens.rSm),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            child: Row(
              children: [
                Icon(item.icon, size: 18, color: color),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.label,
                    style: TLText.navLabel(color),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (badge != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: TLTokens.danger,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(badge!, style: TLText.tag(Colors.white)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoutRow extends StatelessWidget {
  const _LogoutRow({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: t.border)),
        ),
        child: Row(
          children: [
            const Icon(Icons.logout_rounded, size: 17, color: TLTokens.danger),
            const SizedBox(width: 10),
            Text('Logout', style: TLText.navLabel(TLTokens.danger)),
          ],
        ),
      ),
    );
  }
}
