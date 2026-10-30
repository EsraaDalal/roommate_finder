import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rommate_finder/features/auth/presentation/pages/login_page.dart';

import '../../../../core/config/di.dart';
import '../../../../core/domain/entities/user_entity.dart';
import '../../../../core/resources/app_colors.dart';
import '../../../../core/resources/app_spacing.dart';
import '../../../../core/resources/theme_controller.dart';
import '../../../../core/widgets/section_label.dart';

import '../../../applications/presentation/bloc/application_bloc.dart';
import '../../../applications/presentation/pages/my_applications_page.dart';
import '../../../auth/presentation/bloc/auth/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth/auth_event.dart';
import '../../../auth/presentation/bloc/auth/auth_state.dart';
import '../../../auth/presentation/widgets/auth_form_widgets.dart';

import '../../../hosting/presentation/bloc/hosting/hosting_bloc.dart';
import '../../../hosting/presentation/pages/my_listings_page.dart';
import '../../../notifications/presentation/pages/notifications_page.dart';

import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import 'edit_profile_page.dart';

/// Profile screen.
///
/// Mirrors `ai/design/profile_page.png`: an app bar with an Edit action,
/// the user's avatar, name, location, and bio, an email card, a Housing
/// section with derived counts, and an Appearance theme selector.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  void _click() {
    FocusScope.of(context).unfocus();

    context.read<AuthBloc>().add(LogoutRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileBloc>(
      create: (_) {
        final bloc = getIt<ProfileBloc>();
        final uid = FirebaseAuth.instance.currentUser?.uid;

        if (uid != null) {
          bloc.add(ProfileLoadRequested(uid: uid));
        }

        return bloc;
      },
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLogoutSuccess) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute<void>(builder: (_) => const LoginPage()),
              (route) => false,
            );
          } else if (state is AuthFailureState) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          return Scaffold(
            appBar: AppBar(
              title: const Text('Profile'),
              actions: [
                TextButton(
                  onPressed: () => _openEditProfile(context),
                  child: const Text('Edit'),
                ),
              ],
            ),
            body: SafeArea(
              child: BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, profileState) {
                  if (profileState is ProfileInitial ||
                      profileState is ProfileLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (profileState is ProfileFailureState) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              profileState.message,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                final uid =
                                    FirebaseAuth.instance.currentUser?.uid;

                                if (uid != null) {
                                  context.read<ProfileBloc>().add(
                                    ProfileLoadRequested(uid: uid),
                                  );
                                }
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  UserEntity? user;

                  if (profileState is ProfileLoaded) {
                    user = profileState.user;
                  } else if (profileState is ProfileUpdating) {
                    user = profileState.user;
                  } else if (profileState is ProfileUpdateSuccess) {
                    user = profileState.user;
                  }

                  if (user == null) {
                    return const Center(child: Text('Unable to load profile.'));
                  }
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.pageHorizontal,
                      AppSpacing.md,
                      AppSpacing.pageHorizontal,
                      AppSpacing.lg,
                    ),
                    children: <Widget>[
                      _ProfileHeader(user: user),
                      const SizedBox(height: AppSpacing.xl),
                      _EmailCard(email: user.email),
                      const SizedBox(height: AppSpacing.xl),
                      const SectionLabel('Housing'),
                      const SizedBox(height: AppSpacing.sm),
                      _HousingCard(name: user.fullName,),
                      const SizedBox(height: AppSpacing.xl),
                      const SectionLabel('Appearance'),
                      const SizedBox(height: AppSpacing.sm),
                      const _AppearanceCard(),
                      const SizedBox(height: AppSpacing.sm),
                      AuthPrimaryButton(
                        label: isLoading ? 'Log out ...' : 'Log out',
                        onPressed: isLoading ? null : _click,
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  void _openEditProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: context.read<ProfileBloc>(),
          child: const EditProfilePage(),
        ),
      ),
    );
  }
}

/// Profile header: avatar, name, location, and bio.

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final UserEntity user;

  String get _initials {
    final name = user.fullName.trim();

    if (name.isEmpty) return '?';

    final parts = name.split(RegExp(r'\s+'));

    if (parts.length == 1) {
      return parts.first.characters.first.toUpperCase();
    }

    return '${parts.first.characters.first}${parts.last.characters.first}'
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      children: <Widget>[
        CircleAvatar(
          radius: 44,
          backgroundColor: AppColors.avatarGreen,
          child: Text(
            _initials,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 26,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(user.fullName, style: theme.textTheme.displayMedium),
        const SizedBox(height: AppSpacing.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.place_outlined,
              size: 14,
              color: theme.textTheme.bodySmall?.color,
            ),
            const SizedBox(width: AppSpacing.xxs),
            Text(user.city, style: theme.textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Text(
            user.bio,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

/// Email card showing the user's read-only email address.
class _EmailCard extends StatelessWidget {
  const _EmailCard({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Email', style: theme.textTheme.bodySmall),
          const SizedBox(height: AppSpacing.xxs),
          Text(email, style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }
}

/// Housing section with navigation to listings, applications, and
/// notifications. Counts are derived from the stores.
class _HousingCard extends StatelessWidget {
  const _HousingCard({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: <Widget>[
          _HousingRow(
            icon: Icons.home_work_outlined,
            label: 'My listings',

            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => BlocProvider(
                  create: (_) => getIt<HostingBloc>(),
                  child:  MyListingsPage(name: name,),
                ),
              ),
            ),
          ),

          const Divider(height: 1),
          _HousingRow(
            icon: Icons.description_outlined,
            label: 'My applications',

            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => BlocProvider(
                  create: (_) => getIt<ApplicationBloc>(),
                  child: MyApplicationsPage(),
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          _HousingRow(
            icon: Icons.notifications_none_rounded,
            label: 'Notifications',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const NotificationsPage(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A single row in the Housing card.
class _HousingRow extends StatelessWidget {
  const _HousingRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: theme.colorScheme.secondary),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(label, style: theme.textTheme.titleMedium)),

            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: theme.textTheme.bodySmall?.color,
            ),
          ],
        ),
      ),
    );
  }
}

/// Appearance theme selector: Light, Dark, System.
class _AppearanceCard extends StatelessWidget {
  const _AppearanceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: <Widget>[
          _AppearanceRow(
            icon: Icons.wb_sunny_rounded,
            label: 'Light',
            mode: ThemeMode.light,
          ),
          const Divider(height: 1),
          _AppearanceRow(
            icon: Icons.nightlight_round,
            label: 'Dark',
            mode: ThemeMode.dark,
          ),
          const Divider(height: 1),
          _AppearanceRow(
            icon: Icons.brightness_auto_rounded,
            label: 'System',
            mode: ThemeMode.system,
          ),
        ],
      ),
    );
  }
}

/// A single appearance option row.
class _AppearanceRow extends StatelessWidget {
  const _AppearanceRow({
    required this.icon,
    required this.label,
    required this.mode,
  });

  final IconData icon;
  final String label;
  final ThemeMode mode;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool selected = ThemeController.instance.mode == mode;

    return InkWell(
      onTap: () => ThemeController.instance.setMode(mode),
      child: Container(
        color: selected ? theme.colorScheme.primaryContainer : null,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: <Widget>[
            Icon(
              icon,
              size: 20,
              color: selected
                  ? Colors.white
                  : theme.textTheme.bodyMedium?.color,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: selected
                      ? Colors.white
                      : theme.textTheme.titleMedium?.color,
                ),
              ),
            ),
            if (selected)
              Icon(
                Icons.check_rounded,
                size: 20,
                color: theme.colorScheme.secondary,
              ),
          ],
        ),
      ),
    );
  }
}
