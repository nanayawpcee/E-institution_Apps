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
        'Learn world-changing skills and get closer to a better job.',
  ),
  OnboardContent(
    image: TLAssets.onboarding[1],
    title: 'Choose your course',
    description:
        'Pick the course that fits you and gain real knowledge and experience.',
  ),
  OnboardContent(
    image: TLAssets.onboarding[2],
    title: 'Get certified',
    description:
        'Finish your training and get certified to unlock better opportunities.',
  ),
];
