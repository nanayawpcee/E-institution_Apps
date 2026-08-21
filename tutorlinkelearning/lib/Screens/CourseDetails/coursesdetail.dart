import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../components/tutorcard.dart';
import '../../providers/student_data.dart';
import '../../services/local_auth_service.dart';
import '../../theme/app_text.dart';
import '../../theme/app_tokens.dart';
import '../../theme/app_widgets.dart';
import '../../utils/dateformat.dart';
import '../../utils/image_helpers.dart';
import 'reviews.dart';

/// Course detail: preview video, metadata, description and the tutors who
/// teach it.
class CourseDetailScreen extends ConsumerStatefulWidget {
  const CourseDetailScreen({Key? key, required this.courseId})
      : super(key: key);

  final String courseId;

  @override
  ConsumerState<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends ConsumerState<CourseDetailScreen> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _videoReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initVideo());
  }

  Future<void> _initVideo() async {
    final course =
        ref.read(studentDataProvider.notifier).courseById(widget.courseId);
    if (course == null || course.videoUrl.isEmpty) return;

    _videoController =
        VideoPlayerController.networkUrl(Uri.parse(course.videoUrl));
    await _videoController!.initialize();
    _chewieController = ChewieController(
      videoPlayerController: _videoController!,
      autoPlay: false,
      looping: true,
    );

    if (!mounted) return;
    setState(() => _videoReady = true);
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tl;
    final student = ref.watch(authProvider);
    ref.watch(studentDataProvider);
    final notifier = ref.read(studentDataProvider.notifier);
    final course = notifier.courseById(widget.courseId);

    if (course == null) {
      return Scaffold(
        backgroundColor: t.bg,
        appBar: AppBar(),
        body: const TLEmptyState(
          icon: Icons.search_off_rounded,
          title: 'Course not found',
        ),
      );
    }

    final bookmarked = student?.bookmarks.contains(course.courseId) ?? false;
    final tutors = notifier.tutorsForCourse(course.courseId);

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            Row(
              children: [
                TLIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Text(
                    'Course Details',
                    textAlign: TextAlign.center,
                    style: TLText.cardTitle(TLTokens.primary),
                  ),
                ),
                TLIconButton(
                  icon: bookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  iconColor: TLTokens.primary,
                  onPressed: () => ref
                      .read(authProvider.notifier)
                      .toggleBookmark(course.courseId),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(TLTokens.rXl),
              child: SizedBox(
                height: 190,
                child: _videoReady && _chewieController != null
                    ? Chewie(controller: _chewieController!)
                    : _CoverPlaceholder(imagePath: course.image),
              ),
            ),
            const SizedBox(height: 16),
            Text(course.name, style: TLText.sectionTitle(t.text)),
            const SizedBox(height: 8),
            Row(
              children: [
                TLRating(value: course.rating.toDouble(), size: 13),
                const SizedBox(width: 14),
                Text(
                  formatDuration(course.duration),
                  style: TLText.meta(t.textSub).copyWith(fontSize: 13),
                ),
                const SizedBox(width: 14),
                Text(
                  course.department,
                  style: TLText.meta(t.textSub).copyWith(fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              course.details,
              textAlign: TextAlign.justify,
              style: TLText.sub(t.textSub).copyWith(height: 1.6),
            ),
            const SizedBox(height: 22),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: Text(
                    'Tutors',
                    style: TLText.sectionTitle(TLTokens.accent)
                        .copyWith(fontSize: 16),
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ReviewScreen(courseId: course.courseId),
                    ),
                  ),
                  child: Text(
                    'Reviews',
                    style: TLText.sub(TLTokens.primary)
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (tutors.isEmpty)
              const TLEmptyState(
                icon: Icons.people_outline,
                title: 'No tutors assigned yet',
              )
            else
              for (final tutor in tutors)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TutorCard(
                    tutorId: tutor.id,
                    courseId: course.courseId,
                    imageUrl: tutor.userImage,
                    tutorName: tutor.name,
                    students: tutor.students.length,
                    rating: tutor.rating,
                    isOpen: tutor.available,
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

/// Cover art with a play badge, shown until the preview video is ready.
class _CoverPlaceholder extends StatelessWidget {
  const _CoverPlaceholder({required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image(image: appImageProvider(imagePath), fit: BoxFit.cover),
        ColoredBox(color: Colors.black.withValues(alpha: 0.18)),
        Center(
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              size: 28,
              color: TLTokens.primary,
            ),
          ),
        ),
      ],
    );
  }
}
