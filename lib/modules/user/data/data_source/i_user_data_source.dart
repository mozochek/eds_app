import 'package:eds_app/modules/core/domain/entity/paginated_result.dart';
import 'package:eds_app/modules/core/domain/entity/user.dart';
import 'package:eds_app/modules/core/domain/entity/user_full_data.dart';

abstract class IUserDataSource {
  Future<PaginatedResult<User>> getUsersPage(int page, int limit);

  Future<UserFullData?> getUserFullData(int userId);
}
