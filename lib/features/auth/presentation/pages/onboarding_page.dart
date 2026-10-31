import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import '../../../../core/resources/app_colors.dart';
import '../../../../core/resources/app_spacing.dart';
import '../../../../core/widgets/app_brand_mark.dart';

import '../bloc/onboarding/onboarding_bloc.dart';
import '../bloc/onboarding/onboarding_event.dart';
import '../bloc/onboarding/onboarding_state.dart';
import 'login_page.dart';

/// Onboarding slide content, matching the three Figma frames.
class OnboardingSlide {
  const OnboardingSlide({
    required this.counter,
    required this.title,
    required this.description,
    required this.imageLabel,
    required this.imageUrl,
  });

  /// e.g. "01 — 03"
  final String counter;
  final String title;
  final String description;

  /// Text shown in the pill overlaid on the photo.
  final String imageLabel;
  final String imageUrl;
}

const List<OnboardingSlide> kOnboardingSlides = [
  OnboardingSlide(
    counter: '01 — 03',
    title: 'Find Your Next Home',
    description:
        'Explore welcoming rooms and housing listings in the neighborhoods '
        'you love.',
    imageLabel: 'A place that feels like you',
    imageUrl: "assets/images/Home, Community, and Cozy Spaces.png",
  ),
  OnboardingSlide(
    counter: '02 — 03',
    title: 'Find a Suitable Roommate',
    description:
        'View housing details and get to know the basics about who already '
        'lives there.',
    imageLabel: 'Live better together',
    imageUrl: "assets/images/Friends Gathering in a Cozy Green Living Room.png",
  ),
  OnboardingSlide(
    counter: '03 — 03',
    title: 'Connect & Apply',
    description:
        'Contact owners directly and send a simple housing application when '
        'you are ready.',
    imageLabel: 'One message away',
    imageUrl: "assets/images/Home, Community, and Cozy Spaces3.png",
  ),
];

/// Onboarding flow with three slides and a shared page indicator.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _index = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const LoginPage()),
    );
  }

  void _onNext() {
    if (_index == kOnboardingSlides.length - 1) {
      _goToLogin();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  void _completeOnboarding() {
    context.read<OnboardingBloc>().add(const OnboardingCompletedRequested());
  }

  @override
  Widget build(BuildContext context) {
    final bool isLast = _index == kOnboardingSlides.length - 1;

    return BlocListener<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
    if (state is OnboardingCompleted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => const LoginPage(),
        ),
        (route) => false,
      );
    }

    if (state is OnboardingError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              _TopBar(onSkip: _goToLogin),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: kOnboardingSlides.length,
                  onPageChanged: (int value) => setState(() => _index = value),
                  itemBuilder: (BuildContext context, int slideIndex) {
                    return _OnboardingSlideView(
                      slide: kOnboardingSlides[slideIndex],
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal,
                  0,
                  AppSpacing.pageHorizontal,
                  AppSpacing.lg,
                ),
                child: Row(
                  children: [
                    _SlideIndicator(
                      count: kOnboardingSlides.length,
                      activeIndex: _index,
                    ),
                    const Spacer(),
                  FilledButton(
  onPressed: isLast ? _completeOnboarding : _onNext,
  style: FilledButton.styleFrom(
    minimumSize: const Size(140, 52),
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
    ),
    shape: const StadiumBorder(),
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(isLast ? 'Get Started' : 'Next'),
      const SizedBox(width: AppSpacing.xs),
      const Icon(
        Icons.arrow_forward_rounded,
        size: 18,
      ),
    ],
  ),
)
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onSkip});

  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        AppSpacing.md,
        AppSpacing.pageHorizontal,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          const AppBrandMark(size: 34),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'Roommate',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontSize: 16),
          ),
          const Spacer(),

          TextButton(onPressed: () {}, child: const Text('Skip')),
        ],
      ),
    );
  }
}

class _OnboardingSlideView extends StatelessWidget {
  const _OnboardingSlideView({required this.slide});

  final OnboardingSlide slide;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageHorizontal,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1.05,
            child: _SlideImage(
              label: slide.imageLabel,
              imageUrl: slide.imageUrl,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            slide.counter,
            style: theme.textTheme.labelLarge?.copyWith(
              color: AppColors.primary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(slide.title, style: theme.textTheme.displayMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(slide.description, style: theme.textTheme.bodyLarge),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

/// Photo placeholder for the slide.
///
/// The Figma frames use interior photography that has not been exported as an
/// asset yet. A tinted placeholder keeps the composition and the overlaid label
/// pill intact so the real image can be dropped in later.
class _SlideImage extends StatelessWidget {
  const _SlideImage({required this.label, required this.imageUrl});

  final String label;

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return ColoredBox(
                color: AppColors.primaryTint,
                child: const Center(
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    size: 48,
                    color: AppColors.primary,
                  ),
                ),
              );
            },
          ),

          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Segmented page indicator: the active slide is a wider green bar.
class _SlideIndicator extends StatelessWidget {
  const _SlideIndicator({required this.count, required this.activeIndex});

  final int count;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List<Widget>.generate(count, (int index) {
        final bool active = index == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: active ? 24 : 8,
          height: 6,
          margin: const EdgeInsets.only(right: AppSpacing.xs),
          decoration: BoxDecoration(
            color: active
                ? AppColors.primary
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
        );
      }),
    );
  }
}
