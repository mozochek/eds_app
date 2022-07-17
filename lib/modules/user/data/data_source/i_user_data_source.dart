import 'package:eds_app/modules/core/domain/entity/user.dart';
import 'package:eds_app/modules/core/domain/entity/user_full_data.dart';

abstract class IUserDataSource {
  Future<List<User>?> getUsers();

  Future<UserFullData?> getUserFullData(int userId);
}
