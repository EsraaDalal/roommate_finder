
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/domain/entities/user_entity.dart';
import '../../../../core/errors/failure.dart';

import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserEntity>> getProfile({
    required String uid,
  }) async {
    try {
      final profile = await remoteDataSource.getProfile(uid: uid);
      return Right(profile);
    } on ProfileNotFoundException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on FirebaseException catch (e) {
      return Left(ServerFailure(message: e.message ?? e.toString()));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile({
    required String uid,
    required String fullName,
    required String city,
    required String bio,
  }) async {
    try {
      final profile = await remoteDataSource.updateProfile(
        uid: uid,
        fullName: fullName,
        city: city,
        bio: bio,
      );
      return Right(profile);
    } on ProfileAccessException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(message: e.message ?? e.toString()));
    } on ProfileNotFoundException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on FirebaseException catch (e) {
      return Left(ServerFailure(message: e.message ?? e.toString()));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
