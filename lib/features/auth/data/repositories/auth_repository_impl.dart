
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';


import '../../../../core/errors/failure.dart';
import '../../../../core/domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource dataSource;

  AuthRepositoryImpl({
    required this.dataSource,
  });

  @override
  Future<Either<Failure, UserEntity>> register({
    required String fullName,
    required String email,
    required String password,
    required String city,
    required String bio,
  }) async {
    try {
      final user = await dataSource.register(
        fullName: fullName,
        email: email,
        password: password,
        city: city,
        bio: bio,
      );

      return Right(user);
    } on FirebaseAuthException catch (e) {
      return Left(
        AuthFailure(message: _getAuthErrorMessage(e.code)),
      );
    } on FirebaseException {
      return const Left(
        ServerFailure(
          message: 'Unable to save or retrieve user data.',
        ),
      );
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await dataSource.login(
        email: email,
        password: password,
      );

      return Right(user);
    } on FirebaseAuthException catch (e) {
      return Left(
        AuthFailure(message: _getAuthErrorMessage(e.code)),
      );
    } on FirebaseException {
      return const Left(
        ServerFailure(
          message: 'Unable to retrieve user data.',
        ),
      );
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await dataSource.logout();
      return const Right(null);
    } on FirebaseAuthException {
      return const Left(
        AuthFailure(
          message: 'Unable to sign out. Please try again.',
        ),
      );
    } catch (_) {
      return const Left(
        ServerFailure(
          message: 'An unexpected error occurred during logout.',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final user = await dataSource.getCurrentUser();
      return Right(user);
    } on FirebaseAuthException catch (e) {
      return Left(
        AuthFailure(message: _getAuthErrorMessage(e.code)),
      );
    } on FirebaseException {
      return const Left(
        ServerFailure(
          message: 'Unable to retrieve current user data.',
        ),
      );
    } catch (_) {
      return const Left(
        ServerFailure(
          message: 'Unable to load the current user.',
        ),
      );
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges async* {
    try {
      await for (final user in dataSource.authStateChanges) {
        yield user;
      }
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(
        message: _getAuthErrorMessage(e.code),
      );
    } on FirebaseException {
      throw const ServerFailure(
        message: 'Unable to retrieve user data.',
      );
    } catch (_) {
      throw const ServerFailure(
        message: 'Unable to monitor the authentication session.',
      );
    }
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email address is already registered.';

      case 'invalid-email':
        return 'Please enter a valid email address.';

      case 'weak-password':
        return 'The password is too weak.';

      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'The email or password is incorrect.';

      case 'user-disabled':
        return 'This account has been disabled.';

      case 'network-request-failed':
        return 'Please check your internet connection.';

      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';

      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
