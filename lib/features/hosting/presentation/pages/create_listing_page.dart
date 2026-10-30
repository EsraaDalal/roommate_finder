import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/resources/app_spacing.dart';
import '../../../../core/widgets/section_label.dart';
import '../../../auth/presentation/bloc/auth_session/auth_session_bloc.dart';
import '../../../auth/presentation/bloc/auth_session/auth_session_state.dart';
import '../../../../core/domain/entities/listing_entity.dart';
import '../../../../core/domain/entities/listing_host.dart';
import '../../../../core/domain/entities/roommate.dart';

import '../bloc/hosting/hosting_bloc.dart';
import '../bloc/hosting/hosting_event.dart';
import '../bloc/hosting/hosting_state.dart';
import '../bloc/user/users_bloc.dart';
import '../bloc/user/users_event.dart';
import '../bloc/user/users_state.dart';

/// Create and Edit listing form.
///
/// `ai/design/add_listing_page.png` covers the top of the form (photos, title,
/// description, price, location, room type, furnishing). The remaining fields
/// required by the project specification continue below.
///
/// Passing [listing] switches the same form into edit mode with the current
/// values prefilled; submitting updates that listing instead of creating a
/// duplicate. Cancelling pops without touching stored data.
class CreateListingPage extends StatefulWidget {
  const CreateListingPage({super.key, this.listing, required this.name});
  final String name;

  /// The listing being edited, or null when creating a new one.
  final ListingEntity? listing;

  @override
  State<CreateListingPage> createState() => _CreateListingPageState();
}

class _CreateListingPageState extends State<CreateListingPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _areaController;
  late final TextEditingController _peopleController;
  late final TextEditingController _spacesController;
  late final TextEditingController _rulesController;
  late final TextEditingController _roommateNameController;

  final Set<String> _selectedRoommateIds = <String>{};
  final List<Roommate> _manualRoommates = <Roommate>[];
  late final TextEditingController _hostNameController;
  late final TextEditingController _hostNoteController;


  late RoomType _roomType;
  late bool _furnished;
  final ImagePicker _imagePicker = ImagePicker();

  final List<XFile> _selectedImages = <XFile>[];

  bool _isPickingImages = false;
  bool _isSubmitting = false;

  static const int _maxPhotos = 6;

  bool get _isEditing => widget.listing != null;

  @override
  void initState() {
    super.initState();
    final ListingEntity? existing = widget.listing;

    _titleController = TextEditingController(text: existing?.title ?? '');
    _descriptionController = TextEditingController(
      text: existing?.description ?? '',
    );
    _priceController = TextEditingController(
      text: existing == null ? '' : '${existing.priceMonthly}',
    );
    _areaController = TextEditingController(text: existing?.area ?? '');
    _peopleController = TextEditingController(
      text: existing == null ? '' : '${existing.peopleCount}',
    );
    _spacesController = TextEditingController(
      text: existing == null ? '' : '${existing.spacesRemaining}',
    );
    _rulesController = TextEditingController(
      text: existing?.rules.join('\n') ?? '',
    );

    final List<Roommate> existingRoommates =
        existing?.roommates ?? const <Roommate>[];

    _selectedRoommateIds.addAll(
      existingRoommates
          .where((Roommate roommate) => roommate.userId != null)
          .map((Roommate roommate) => roommate.userId!),
    );

    _manualRoommates.addAll(
      existingRoommates.where((Roommate roommate) => roommate.userId == null),
    );

    _roommateNameController = TextEditingController();

   _hostNameController = TextEditingController(
    text: widget.name,
  );
    _hostNoteController = TextEditingController(
      text: existing?.host.responseTime ?? '',
    );

    _roomType = existing?.roomType ?? RoomType.apartment;
    _furnished = existing?.furnished ?? true;

  }

  Future<void> _pickImages() async {
    if (_isPickingImages || _selectedImages.length >= _maxPhotos) {
      return;
    }

    setState(() => _isPickingImages = true);

    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        imageQuality: 85,
      );

      if (!mounted || images.isEmpty) return;

      setState(() {
        final int remaining = _maxPhotos - _selectedImages.length;

        _selectedImages.addAll(images.take(remaining));
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not select images. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isPickingImages = false);
      }
    }
  }

  void _addManualRoommate() {
    final String name = _roommateNameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the roommate name first.')),
      );
      return;
    }

    final bool alreadyExists = _manualRoommates.any(
      (Roommate roommate) => roommate.name.toLowerCase() == name.toLowerCase(),
    );

    if (alreadyExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This roommate has already been added.')),
      );
      return;
    }

    setState(() {
      _manualRoommates.add(
        Roommate(
          initials: _initialsFor(name),
          name: name,
          tagline: '',
          userId: null,
        ),
      );

      _roommateNameController.clear();
    });
  }

  void _removeManualRoommate(Roommate roommate) {
    setState(() {
      _manualRoommates.remove(roommate);
    });
  }

  void _toggleRegisteredRoommate(String userId, bool selected) {
    setState(() {
      if (selected) {
        _selectedRoommateIds.add(userId);
      } else {
        _selectedRoommateIds.remove(userId);
      }
    });
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _areaController.dispose();
    _peopleController.dispose();
    _spacesController.dispose();
    _rulesController.dispose();
    _roommateNameController.dispose();

    _hostNameController.dispose();
    _hostNoteController.dispose();
    super.dispose();
  }

  String? _validateRequired(String? value, String message) {
    return (value == null || value.trim().isEmpty) ? message : null;
  }

  String? _validateNumber(String? value, String message, {int min = 0}) {
    final String raw = value?.trim() ?? '';
    if (raw.isEmpty) {
      return message;
    }
    final int? parsed = int.tryParse(raw);
    if (parsed == null) {
      return 'Enter a whole number';
    }
    if (parsed < min) {
      return 'Must be at least $min';
    }
    return null;
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final sessionState = context.read<AuthSessionBloc>().state;
    if (sessionState is! AuthSessionAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to manage listings.')),
      );
      return;
    }

    final String currentUserId = sessionState.user.uid;
    final ListingEntity? existing = widget.listing;
    final List<Roommate> roommates = <Roommate>[];
    final UsersState usersState = context.read<UsersBloc>().state;

    for (final String userId in _selectedRoommateIds) {
      final Iterable<Roommate> previousMatches =
          existing?.roommates.where(
            (Roommate roommate) => roommate.userId == userId,
          ) ??
          const <Roommate>[];

      final Roommate? previousRoommate = previousMatches.isEmpty
          ? null
          : previousMatches.first;

      if (usersState is UsersLoaded) {
        final matchingUsers = usersState.users.where(
          (user) => user.uid == userId,
        );

        if (matchingUsers.isNotEmpty) {
          final user = matchingUsers.first;

          roommates.add(
            Roommate(
              initials: _initialsFor(user.fullName),
              name: user.fullName,
              tagline: previousRoommate?.tagline ?? '',
              userId: user.uid,
            ),
          );

          continue;
        }
      }

      if (previousRoommate != null) {
        roommates.add(previousRoommate);
      }
    }

   
roommates.addAll(_manualRoommates);

// Add the currently typed manual roommate.
final String manualName = _roommateNameController.text.trim();

if (manualName.isNotEmpty &&
    !roommates.any(
      (Roommate roommate) =>
          roommate.userId == null &&
          roommate.name.toLowerCase() == manualName.toLowerCase(),
    )) {
  roommates.add(
    Roommate(
      initials: _initialsFor(manualName),
      name: manualName,
      tagline: '',
      userId: null,
    ),
  );
}

// Debugging
debugPrint('Total roommates: ${roommates.length}');
for (final roommate in roommates) {
  debugPrint(
    'Roommate: ${roommate.name}, userId: ${roommate.userId}',
  );
}


final String hostName = widget.name.trim();

  

    final ListingEntity listing = ListingEntity(
      id: existing?.id ?? '',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      priceMonthly: int.parse(_priceController.text.trim()),
      area: _areaController.text.trim(),
      roomType: _roomType,
      category: _roomType == RoomType.universityRoom
          ? ListingCategory.university
          : ListingCategory.apartment,
      furnished: _furnished,
      peopleCount: int.parse(_peopleController.text.trim()),
      spacesRemaining: int.parse(_spacesController.text.trim()),
      rules: _rulesController.text
          .split('\n')
          .map((String rule) => rule.trim())
          .where((String rule) => rule.isNotEmpty)
          .toList(growable: false),
      roommates: roommates,
      host: ListingHost(
        initials: _initialsFor(hostName),
        name: hostName,
        responseTime: _hostNoteController.text.trim().isEmpty
            ? 'Usually responds within an hour'
            : _hostNoteController.text.trim(),
      ),
      photoCount: existing?.photoCount ?? 0,
      photoPaths: existing?.photoPaths ?? const [],
      photoUrls: existing?.photoUrls ?? const [],
      isPublished: existing?.isPublished ?? true,
      ownerId: existing?.ownerId ?? currentUserId,
    );

    setState(() {
      _isSubmitting = true;
    });

    if (_isEditing) {
      context.read<HostingBloc>().add(UpdateListingEvent(listing: listing));
    } else {
      // The selected photos are uploaded by the bloc before the listing is
      // saved, so the page only passes their local paths along.
      final List<String> imageFilePaths = _selectedImages
          .map((XFile image) => image.path)
          .toList(growable: false);

      context.read<HostingBloc>().add(
        CreateListingEvent(listing: listing, imageFilePaths: imageFilePaths),
      );
    }
  }

  String _initialsFor(String name) {
    final List<String> parts = name
        .split(' ')
        .where((String part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return '?';
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return BlocConsumer<HostingBloc, HostingState>(
      listener: (BuildContext context, HostingState state) {
        if (!_isSubmitting) return;
    
        if (state.status == HostingStatus.failure) {
          setState(() {
            _isSubmitting = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.errorMessage ??
                    'Failed to save listing. Please try again.',
              ),
            ),
          );
        } else if (state.status == HostingStatus.success) {
          setState(() {
            _isSubmitting = false;
          });
          final String message =
              state.successMessage ??
              (_isEditing
                  ? 'Listing updated successfully.'
                  : 'Listing created successfully.');
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
          Navigator.of(context).pop();
        }
      },
      builder: (BuildContext context, HostingState state) {
        final bool isLoading =
            _isSubmitting && state.status == HostingStatus.loading;
    
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              tooltip: 'Back',
              // Cancelling never modifies stored data.
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(_isEditing ? 'Edit listing' : 'Create listing'),
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
                      'Share your space',
                      style: theme.textTheme.displayMedium,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      'Add the essentials. You can edit them anytime.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Photos (${_selectedImages.length}/$_maxPhotos)',
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            for (int i = 0; i < _selectedImages.length; i++)
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      File(_selectedImages[i].path),
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: IconButton(
                                      onPressed: () => _removeImage(i),
                                      icon: const Icon(Icons.close),
                                      style: IconButton.styleFrom(
                                        backgroundColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            if (_selectedImages.length < _maxPhotos)
                              SizedBox(
                                width: 100,
                                height: 100,
                                child: OutlinedButton(
                                  onPressed: _isPickingImages
                                      ? null
                                      : _pickImages,
                                  child: _isPickingImages
                                      ? const CircularProgressIndicator()
                                      : const Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.add_a_photo_outlined),
                                            SizedBox(height: 4),
                                            Text('Add photos'),
                                          ],
                                        ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _LabeledField(
                      label: 'Listing title',
                      child: TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          hintText: 'e.g. Bright room near campus',
                        ),
                        validator: (String? v) =>
                            _validateRequired(v, 'Enter a listing title'),
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _LabeledField(
                      label: 'Description',
                      child: TextFormField(
                        controller: _descriptionController,
                        minLines: 3,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          hintText: 'What makes this place feel like home?',
                        ),
                        validator: (String? v) =>
                            _validateRequired(v, 'Enter a description'),
                        textInputAction: TextInputAction.newline,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _LabeledField(
                            label: 'Monthly price',
                            child: TextFormField(
                              controller: _priceController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: '\$750',
                              ),
                              validator: (String? v) =>
                                  _validateNumber(v, 'Enter a price', min: 1),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _LabeledField(
                            label: 'Location',
                            child: TextFormField(
                              controller: _areaController,
                              decoration: const InputDecoration(
                                hintText: 'Area, city',
                              ),
                              validator: (String? v) =>
                                  _validateRequired(v, 'Enter a location'),
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _LabeledField(
                      label: 'Room type',
                      child: DropdownButtonFormField<RoomType>(
                        initialValue: _roomType,
                        decoration: const InputDecoration(),
                        items: [
                          for (final RoomType type in RoomType.values)
                            DropdownMenuItem<RoomType>(
                              value: type,
                              child: Text(type.label),
                            ),
                        ],
                        onChanged: (RoomType? value) {
                          if (value != null) {
                            setState(() => _roomType = value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _LabeledField(
                      label: 'Furnishing',
                      child: DropdownButtonFormField<bool>(
                        initialValue: _furnished,
                        decoration: const InputDecoration(),
                        items: const [
                          DropdownMenuItem<bool>(
                            value: true,
                            child: Text('Furnished'),
                          ),
                          DropdownMenuItem<bool>(
                            value: false,
                            child: Text('Unfurnished'),
                          ),
                        ],
                        onChanged: (bool? value) {
                          if (value != null) {
                            setState(() => _furnished = value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    const SectionLabel('Household'),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _LabeledField(
                            label: 'Number of people',
                            child: TextFormField(
                              controller: _peopleController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: '2',
                              ),
                              validator: (String? v) => _validateNumber(
                                v,
                                'Enter how many people live here',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _LabeledField(
                            label: 'Remaining spaces',
                            child: TextFormField(
                              controller: _spacesController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: '1',
                              ),
                              validator: (String? v) => _validateNumber(
                                v,
                                'Enter remaining spaces',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _LabeledField(
                      label: 'Housing rules',
                      helper: 'One rule per line',
                      child: TextFormField(
                        controller: _rulesController,
                        minLines: 2,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: 'No smoking\nQuiet hours after 10 PM',
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
    
                    _LabeledField(
                      label: 'Registered roommates',
                      helper: 'Select all that apply',
                      child: BlocBuilder<UsersBloc, UsersState>(
                        builder: (context, usersState) {
                          if (usersState is UsersInitial ||
                              usersState is UsersLoading) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
    
                          if (usersState is UsersFailure) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Could not load registered users.',
                                ),
                                TextButton(
                                  onPressed: () {
                                    context.read<UsersBloc>().add(
                                      UsersLoadRequested(),
                                    );
                                  },
                                  child: const Text('Retry'),
                                ),
                              ],
                            );
                          }
    
                          if (usersState is! UsersLoaded) {
                            return const SizedBox.shrink();
                          }
    
                          final users = usersState.users;
    
                          if (users.isEmpty) {
                            return const Text('No registered users found.');
                          }
    
                          return Column(
                            children: [
                              for (final user in users)
                                CheckboxListTile(
                                  contentPadding: EdgeInsets.zero,
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  title: Text(
                                    user.fullName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  value: _selectedRoommateIds.contains(
                                    user.uid,
                                  ),
                                  onChanged: (bool? selected) {
                                    _toggleRegisteredRoommate(
                                      user.uid,
                                      selected ?? false,
                                    );
                                  },
                                ),
                            ],
                          );
                        },
                      ),
                    ),
    
                    const SizedBox(height: AppSpacing.md),
    
                    _LabeledField(
                      label: 'Add someone manually',
                      helper: 'Optional',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _roommateNameController,
                                  decoration: const InputDecoration(
                                    hintText: 'Enter a name',
                                  ),
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) =>
                                      _addManualRoommate(),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              IconButton.filled(
                                tooltip: 'Add roommate',
                                onPressed: _addManualRoommate,
                                icon: const Icon(Icons.add),
                              ),
                            ],
                          ),
    
                          if (_manualRoommates.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'Added manually',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Wrap(
                              spacing: AppSpacing.sm,
                              runSpacing: AppSpacing.xs,
                              children: [
                                for (final roommate in _manualRoommates)
                                  InputChip(
                                    label: Text(roommate.name),
                                    onDeleted: () =>
                                        _removeManualRoommate(roommate),
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
    
                    const SizedBox(height: AppSpacing.md),
                    _LabeledField(
                      label: 'contact with ',
                      child: TextFormField(
                        controller: _hostNameController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          hintText: 'Your profile name',
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _LabeledField(
                      label: 'Host response note',
                      child: TextFormField(
                        controller: _hostNoteController,
                        decoration: const InputDecoration(
                          hintText: 'Usually responds within an hour',
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    FilledButton(
                      onPressed: isLoading ? null : _submit,
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _isEditing ? 'Save changes' : 'Publish listing',
                            ),
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

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child, this.helper});

  final String label;
  final Widget child;
  final String? helper;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: theme.textTheme.labelLarge),
            if (helper != null) ...[
              const Spacer(),
              Text(helper!, style: theme.textTheme.bodySmall),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        child,
      ],
    );
  }
}
