import 'package:eds_app/modules/core/data/repository/i_pagination_repository.dart';
import 'package:eds_app/modules/core/domain/entity/user.dart';
import 'package:eds_app/modules/core/domain/entity/user_full_data.dart';

abstract class IUserRepository extends IPaginationRepository<User> {
  Future<UserFullData?> getUserFullData(int userId);
}
