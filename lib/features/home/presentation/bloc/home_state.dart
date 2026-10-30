import 'package:flutter/foundation.dart';

import '../../../../core/domain/entities/listing_entity.dart';

/// States emitted by the Home bloc.
@immutable
sealed class HomeState {
  const HomeState();
}

/// Nothing has been requested yet.
final class HomeInitial extends HomeState {
  const HomeInitial();
}

/// The listings are being requested.
final class HomeLoading extends HomeState {
  const HomeLoading();
}

/// The listings were loaded successfully.
final class HomeLoaded extends HomeState {
  /// The listings that are available for the Home screen.
  final List<ListingEntity> listings;

  const HomeLoaded(this.listings);
}

/// The request succeeded but there are no listings to show.
final class HomeEmpty extends HomeState {
  const HomeEmpty();
}

/// The listings could not be loaded.
final class HomeFailure extends HomeState {
  /// Message that describes why the request failed.
  final String message;

  const HomeFailure(this.message);
}
