import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/listing_entity.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/usecases/get_home_listings_usecase.dart';
import 'home_event.dart';
import 'home_state.dart';

/// Home bloc.
///
/// Loads the listings for the Home screen through [GetHomeListingsUseCase].
/// The bloc never talks to the data layer directly.
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetHomeListingsUseCase getHomeListingsUseCase;

  HomeBloc({required this.getHomeListingsUseCase})
    : super(const HomeInitial()) {
    on<GetHomeListingsEvent>(_onGetHomeListings);
  }

  Future<void> _onGetHomeListings(
    GetHomeListingsEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());

    try {
      final result = await getHomeListingsUseCase();

      result.fold((Failure failure) => emit(HomeFailure(failure.message)), (
        List<ListingEntity> listings,
      ) {
        if (listings.isEmpty) {
          emit(const HomeEmpty());
        } else {
          emit(HomeLoaded(listings));
        }
      });
    } catch (_) {
      // The repository turns the known errors into failures. This guards
      // against anything unexpected escaping the use case.
      emit(
        const HomeFailure(
          'An unexpected error occurred while loading listings.',
        ),
      );
    }
  }
}
