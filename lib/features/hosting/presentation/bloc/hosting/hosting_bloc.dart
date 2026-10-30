import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/errors/failure.dart';
import '../../../../../core/domain/entities/listing_entity.dart';
import '../../../domain/entities/listing_image_upload_result.dart';
import '../../../domain/usecases/create_listing_usecase.dart';
import '../../../domain/usecases/delete_listing_usecase.dart';
import '../../../domain/usecases/get_my_listings_usecase.dart';
import '../../../domain/usecases/update_listing_usecase.dart';
import '../../../domain/usecases/upload_listing_images_usecase.dart';
import 'hosting_event.dart';
import 'hosting_state.dart';

class HostingBloc extends Bloc<HostingEvent, HostingState> {
  final CreateListingUseCase createListingUseCase;
  final GetMyListingsUseCase getMyListingsUseCase;
  final UpdateListingUseCase updateListingUseCase;
  final DeleteListingUseCase deleteListingUseCase;
  final UploadListingImagesUseCase uploadListingImagesUseCase;

  HostingBloc({
    required this.createListingUseCase,
    required this.getMyListingsUseCase,
    required this.updateListingUseCase,
    required this.deleteListingUseCase,
    required this.uploadListingImagesUseCase,
  }) : super(const HostingState()) {
    on<CreateListingEvent>(_onCreateListing);
    on<GetMyListingsEvent>(_onGetMyListings);
    on<UpdateListingEvent>(_onUpdateListing);
    on<DeleteListingEvent>(_onDeleteListing);
  }

  Future<void> _onCreateListing(
    CreateListingEvent event,
    Emitter<HostingState> emit,
  ) async {
    emit(
      state.copyWith(
        status: HostingStatus.loading,
        clearErrorMessage: true,
        clearSuccessMessage: true,
      ),
    );

    ListingEntity listing = event.listing;

    if (event.imageFilePaths.isNotEmpty) {
      // The photos are uploaded first. The upload service assigns the
      // storage folder identifier, which becomes the listing document id, so
      // the folder and the document always share the same id.
      final uploadResult = await uploadListingImagesUseCase(
        filePaths: event.imageFilePaths,
      );

      String? failureMessage;
      final ListingImageUploadResult? upload = uploadResult.fold((
        Failure failure,
      ) {
        failureMessage = failure.message;
        return null;
      }, (ListingImageUploadResult result) => result);

      if (upload == null) {
        // No listing is created when the upload fails, so the user can retry
        // without leaving a half created listing behind.
        emit(
          state.copyWith(
            status: HostingStatus.failure,
            errorMessage: failureMessage ?? 'The photos could not be uploaded.',
            clearSuccessMessage: true,
          ),
        );
        return;
      }

      listing = listing.copyWith(
        id: upload.listingId,
        photoPaths: upload.photoPaths,
        photoUrls: upload.photoUrls,
        photoCount: upload.photoPaths.length,
      );
    }

    final result = await createListingUseCase(listing: listing);

    result.fold(
      (failure) {
        // Note: when the upload succeeded but saving the listing failed, the
        // uploaded files remain in the storage bucket. Cleaning them up is
        // deferred, because no delete endpoint is available yet.
        emit(
          state.copyWith(
            status: HostingStatus.failure,
            errorMessage: failure.message,
            clearSuccessMessage: true,
          ),
        );
      },
      (listing) {
        emit(
          state.copyWith(
            status: HostingStatus.success,
            listings: [
              listing,
              ...state.listings.where((item) => item.id != listing.id),
            ],
            selectedListing: listing,
            successMessage: 'Listing created successfully.',
            clearErrorMessage: true,
          ),
        );
      },
    );
  }

  Future<void> _onGetMyListings(
    GetMyListingsEvent event,
    Emitter<HostingState> emit,
  ) async {
    emit(
      state.copyWith(
        status: HostingStatus.loading,
        clearErrorMessage: true,
        clearSuccessMessage: true,
      ),
    );

    final result = await getMyListingsUseCase(ownerId: event.ownerId);

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: HostingStatus.failure,
            errorMessage: failure.message,
            clearSuccessMessage: true,
          ),
        );
      },
      (listings) {
        emit(
          state.copyWith(
            status: HostingStatus.success,
            listings: listings,
            clearSelectedListing: true,
            clearErrorMessage: true,
          ),
        );
      },
    );
  }

  Future<void> _onUpdateListing(
    UpdateListingEvent event,
    Emitter<HostingState> emit,
  ) async {
    emit(
      state.copyWith(
        status: HostingStatus.loading,
        clearErrorMessage: true,
        clearSuccessMessage: true,
      ),
    );

    final result = await updateListingUseCase(listing: event.listing);

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: HostingStatus.failure,
            errorMessage: failure.message,
            clearSuccessMessage: true,
          ),
        );
      },
      (updatedListing) {
        final updatedListings = state.listings.map((listing) {
          return listing.id == updatedListing.id ? updatedListing : listing;
        }).toList();

        emit(
          state.copyWith(
            status: HostingStatus.success,
            listings: updatedListings,
            selectedListing: updatedListing,
            successMessage: 'Listing updated successfully.',
            clearErrorMessage: true,
          ),
        );
      },
    );
  }

  Future<void> _onDeleteListing(
    DeleteListingEvent event,
    Emitter<HostingState> emit,
  ) async {
    emit(
      state.copyWith(
        status: HostingStatus.loading,
        clearErrorMessage: true,
        clearSuccessMessage: true,
      ),
    );

    final result = await deleteListingUseCase(
      listingId: event.listingId,
      ownerId: event.ownerId,
    );

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: HostingStatus.failure,
            errorMessage: failure.message,
            clearSuccessMessage: true,
          ),
        );
      },
      (_) {
        final updatedListings = state.listings
            .where((listing) => listing.id != event.listingId)
            .toList();

        emit(
          state.copyWith(
            status: HostingStatus.success,
            listings: updatedListings,
            clearSelectedListing: true,
            successMessage: 'Listing deleted successfully.',
            clearErrorMessage: true,
          ),
        );
      },
    );
  }
}
