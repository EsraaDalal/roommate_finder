import 'package:flutter/foundation.dart';

/// Events handled by the Home bloc.
@immutable
sealed class HomeEvent {
  const HomeEvent();
}

/// Requests the listings that are shown on the Home screen.
final class GetHomeListingsEvent extends HomeEvent {
  const GetHomeListingsEvent();
}
