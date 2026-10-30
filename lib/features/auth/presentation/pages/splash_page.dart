import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rommate_finder/core/config/di.dart';

import '../../../../core/resources/app_colors.dart';
import '../../../../core/resources/app_spacing.dart';
import '../../../shell/presentation/pages/main_shell.dart';
import '../../domain/usecases/is_onboarding_completed_use_case.dart';
import '../bloc/auth_session/auth_session_bloc.dart';
import '../bloc/auth_session/auth_session_state.dart';
import 'login_page.dart';
import 'onboarding_page.dart';

/// Splash screen.
///
/// The design uses a deep green background (#145039) regardless of theme, a
/// white rounded-square logo tile with a green house glyph, the wordmark
/// "Roommate", the tagline, and three page dots near the bottom.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key, this.onComplete});

  /// Invoked once the splash delay elapses. Defaults to pushing the
  /// onboarding flow.
  final VoidCallback? onComplete;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _startRouting();
  }

  Future<void> _startRouting() async {
    await Future<void>.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    try {
      // 1. Check whether onboarding was completed.
      final onboardingCompleted = await getIt<IsOnboardingCompletedUseCase>()();

      if (!mounted) return;

      if (!onboardingCompleted) {
        _navigateTo(const OnboardingPage());
        return;
      }

      // 2. Read the current authentication session.
      final sessionBloc = context.read<AuthSessionBloc>();
      final currentState = sessionBloc.state;

      final AuthSessionState sessionState;

      if (currentState is AuthSessionAuthenticated ||
          currentState is AuthSessionUnauthenticated ||
          currentState is AuthSessionError) {
        sessionState = currentState;
      } else {
        sessionState = await sessionBloc.stream
            .firstWhere(
              (state) =>
                  state is AuthSessionAuthenticated ||
                  state is AuthSessionUnauthenticated ||
                  state is AuthSessionError,
            )
            .timeout(const Duration(seconds: 15));
      }

      if (!mounted) return;

      if (sessionState is AuthSessionAuthenticated) {
        _navigateTo(const MainShell());
      } else if (sessionState is AuthSessionUnauthenticated) {
        _navigateTo(const LoginPage());
      } else if (sessionState is AuthSessionError) {
        throw Exception(sessionState.message);
      }
    } catch (e) {
      print(e);
    }
  }

  void _navigateTo(Widget page) {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute<void>(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDeep,
      body: Stack(
        children: [
          // Soft decorative circles, as in the design.
          const Positioned(
            top: -80,
            right: -60,
            child: _DecorativeCircle(size: 240, opacity: 0.10),
          ),
          const Positioned(
            bottom: -60,
            left: -90,
            child: _DecorativeCircle(size: 260, opacity: 0.08),
          ),
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 3),
                const _SplashLogoTile(),
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'Roommate',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Find a place that feels right.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 14,
                  ),
                ),
                const Spacer(flex: 4),
                const _PageDots(count: 3, activeIndex: 0),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashLogoTile extends StatelessWidget {
  const _SplashLogoTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.home_rounded, size: 44, color: AppColors.primary),
    );
  }
}

class _DecorativeCircle extends StatelessWidget {
  const _DecorativeCircle({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}

/// Three small dots shown near the bottom of the splash screen.
class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.activeIndex});

  final int count;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(count, (int index) {
        final bool active = index == activeIndex;
        return Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: active ? 0.9 : 0.35),
          ),
        );
      }),
    );
  }
}
