import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../Screens/Profile/userProfileScreen.dart' show TLAvatar;
import '../providers/tutor_data.dart';
import '../services/local_auth_service.dart';
import '../theme/app_text.dart';
import '../theme/app_tokens.dart';
import '../theme/app_widgets.dart';

/// A student's request to join a course. Pending ones open an accept/reject
/// sheet; resolved ones just show their outcome.
class RequestCard extends ConsumerWidget {
  const RequestCard({
    Key? key,
    required this.studentId,
    required this.requestId,
    required this.studentName,
    required this.studentImageUrl,
    required this.courseName,
    required this.isPending,
    required this.isAccepted,
    required this.onAccept,
    required this.onReject,
  }) : super(key: key);

  final String studentId;
  final String requestId;
  final String studentName;
  final String studentImageUrl;
  final String courseName;
  final bool isPending;
  final bool isAccepted;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tl;
    return TLCard(
      padding: const EdgeInsets.all(12),
      onTap: isPending ? () => _confirm(context, ref) : null,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 52,
              height: 52,
              child: TLAvatar(imagePath: studentImageUrl, size: 52),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  studentName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TLText.cardTitle(t.text).copyWith(fontSize: 14.5),
                ),
                const SizedBox(height: 3),
                Text(
                  courseName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TLText.meta(t.textSub).copyWith(fontSize: 12.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TLStatusChip(
            label: isPending
                ? 'Pending'
                : isAccepted
                    ? 'Accepted'
                    : 'Rejected',
            color: isPending
                ? TLTokens.pendingInk
                : isAccepted
                    ? TLTokens.success
                    : TLTokens.danger,
            background: isPending
                ? TLTokens.pendingTint
                : isAccepted
                    ? TLTokens.completedTint
                    : TLTokens.danger.withValues(alpha: 0.12),
          ),
        ],
      ),
    );
  }

  /// Accepting also enrols the student and opens their classroom, which is
  /// what makes them appear under My Students.
  Future<void> _confirm(BuildContext context, WidgetRef ref) async {
    await showTLSheet<void>(
      context: context,
      builder: (context) {
        final t = context.tl;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$studentName wants to join', style: TLText.cardTitle(t.text)),
            const SizedBox(height: 4),
            Text(courseName, style: TLText.sub(t.textSub)),
            const SizedBox(height: 20),
            TLButton(
              label: 'Accept',
              onPressed: () {
                final data = ref.read(tutorDataProvider);
                final match = data.requests.where((r) => r.id == requestId);
                final courseId =
                    match.isEmpty ? null : match.first.courseId;
                final tutorId = ref.read(authProvider)?.id;

                onAccept();
                if (courseId != null && tutorId != null) {
                  ref.read(authProvider.notifier).addStudent(studentId);
                  ref
                      .read(tutorDataProvider.notifier)
                      .getOrCreateClassroom(studentId, tutorId, courseId);
                }
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 10),
            TLButton(
              label: 'Reject',
              color: TLTokens.danger,
              onPressed: () {
                onReject();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
