// lib/features/applications/presentation/bloc/application_state.dart


import '../../../../core/domain/entities/listing_entity.dart';
import '../../domain/entities/application_entity.dart';


abstract class ApplicationState {
  const ApplicationState();


}

class ApplicationInitial extends ApplicationState {
  const ApplicationInitial();
}

class ApplicationLoading extends ApplicationState {
  const ApplicationLoading();
}

class ApplicationLoaded extends ApplicationState {
  final List<ApplicationEntity> applications;

  const ApplicationLoaded(this.applications);


}

class ApplicationOperationSuccess extends ApplicationState {
  const ApplicationOperationSuccess();
}

class ApplicationFailure extends ApplicationState {
  final String message;
  const ApplicationFailure(this.message);


}
class ApplicationListingLoaded extends ApplicationState {
  final ListingEntity listing;

  const ApplicationListingLoaded(this.listing);

}
