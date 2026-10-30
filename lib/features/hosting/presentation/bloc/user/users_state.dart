import '../../../../../core/domain/entities/user_entity.dart';


abstract class UsersState {
  const UsersState();
}

class UsersInitial extends UsersState {
  const UsersInitial();
}

class UsersLoading extends UsersState {
  const UsersLoading();
}

class UsersLoaded extends UsersState {
  final List<UserEntity> users;

  const UsersLoaded(this.users);
}

class UsersFailure extends UsersState {
  final String message;

  const UsersFailure(this.message);
}