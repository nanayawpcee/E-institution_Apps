import '../theme/app_assets.dart';

/// Copy and illustration for each onboarding slide, matching the design's
/// three-step introduction.
class OnboardContent {
  const OnboardContent({
    required this.image,
    required this.title,
    required this.description,
  });

  final String image;
  final String title;
  final String description;
}

final List<OnboardContent> onboard_data = [
  OnboardContent(
    image: TLAssets.onboarding[0],
    title: 'Welcome to TutorLink',
    description:
        'Teach what you know and reach students who need it.',
  ),
  OnboardContent(
    image: TLAssets.onboarding[1],
    title: 'Choose your students',
    description:
        'Accept the students that fit your schedule and start teaching.',
  ),
  OnboardContent(
    image: TLAssets.onboarding[2],
    title: 'Run your classroom',
    description:
        'Share material, set assignments and track every class in one place.',
  ),
];
