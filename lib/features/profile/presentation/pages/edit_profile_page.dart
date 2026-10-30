

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/resources/app_spacing.dart';

import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

/// Edit Profile form.
///
/// There is no separate edit-profile screenshot, so this follows the visual
/// language of the approved screens: a scrollable form with labeled fields,
/// a circular avatar with a camera overlay, and a primary save button.
///
/// Email is read-only. The photo is kept in memory for this UI-only stage.
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _cityController;
  late final TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    super.initState();

    _nameController = TextEditingController();
    _cityController = TextEditingController();
    _bioController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final state = context.read<ProfileBloc>().state;

    if (state is ProfileLoaded) {
      _populateFields(state.user);
    } else if (state is ProfileUpdateSuccess) {
      _populateFields(state.user);
    } else if (state is ProfileUpdating) {
      _populateFields(state.user);
    }
  }

  void _populateFields(dynamic user) {
    _nameController.text = user.fullName;
    _cityController.text = user.city;
    _bioController.text = user.bio;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  String? _required(String? value, String message) {
    return (value == null || value.trim().isEmpty) ? message : null;
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in again to update your profile.'),
        ),
      );
      return;
    }

    context.read<ProfileBloc>().add(
      ProfileUpdateRequested(
        uid: uid,
        fullName: _nameController.text.trim(),
        city: _cityController.text.trim(),
        bio: _bioController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return BlocConsumer<ProfileBloc, ProfileState>(
       listener: (context, state) {
        if (state is ProfileUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully.'),
            ),
          );

          Navigator.of(context).pop();
        } else if (state is ProfileFailureState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
         final isUpdating = state is ProfileUpdating;
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              tooltip: 'Back',
              // Cancelling never modifies stored data.
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text('Edit profile'),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageHorizontal,
                AppSpacing.md,
                AppSpacing.pageHorizontal,
                AppSpacing.xl,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Edit your profile',
                      style: theme.textTheme.displayMedium,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      'Update your name, city, and bio.',
                      style: theme.textTheme.bodyMedium,
                    ),

                    const SizedBox(height: AppSpacing.xl),
                    Text('Full name', style: theme.textTheme.labelLarge),
                    const SizedBox(height: AppSpacing.xs),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        hintText: 'Alex Morgan',
                      ),
                      validator: (String? v) =>
                          _required(v, 'Enter your full name'),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text('City', style: theme.textTheme.labelLarge),
                    const SizedBox(height: AppSpacing.xs),
                    TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(
                        hintText: 'Austin, Texas',
                      ),
                      validator: (String? v) => _required(v, 'Enter your city'),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text('Short bio', style: theme.textTheme.labelLarge),
                    const SizedBox(height: AppSpacing.xs),
                    TextFormField(
                      controller: _bioController,
                      minLines: 3,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: 'A little about you…',
                      ),
                      textInputAction: TextInputAction.newline,
                    ),
                
                 
                    const SizedBox(height: AppSpacing.xl),
                    FilledButton(
                      onPressed: _save,
                      child: isUpdating
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Save changes'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
