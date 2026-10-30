import 'package:dartz/dartz.dart';

import '../../../../core/domain/entities/listing_entity.dart';
import '../../../../core/errors/failure.dart';


abstract class HomeRepository {
  Future<Either<Failure, List<ListingEntity>>> getListings();
}