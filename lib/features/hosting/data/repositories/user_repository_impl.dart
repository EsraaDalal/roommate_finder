
import '../../../../core/domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_data_source.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this.remoteDataSource);

  final UserRemoteDataSource remoteDataSource;

  @override
  Future<List<UserEntity>> getUsers() {
    return remoteDataSource.getUsers();
  }
}