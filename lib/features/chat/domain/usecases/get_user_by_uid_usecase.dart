



import 'package:dartz/dartz.dart';

import '../../../../core/domain/entities/user_entity.dart';
import '../../../../core/errors/failure.dart';
import '../repositories/chat_repository.dart';

class GetUserByUidUseCase {
  final ChatRepository repository;

  GetUserByUidUseCase({required this.repository});

  Future<Either<Failure, UserEntity>> call(String uid) {
    return repository.getUserByUid(uid);
  }
}