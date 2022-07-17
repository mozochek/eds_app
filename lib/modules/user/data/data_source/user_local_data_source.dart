import 'package:eds_app/modules/core/data/dao/users_dao.dart';
import 'package:eds_app/modules/core/domain/entity/user.dart';
import 'package:eds_app/modules/core/domain/entity/user_full_data.dart';
import 'package:eds_app/modules/user/data/data_source/i_user_data_source.dart';

abstract class IUserLocalDataSource implements IUserDataSource {
  Future<void> saveAllUsers(List<User> users);

  Future<void> saveUserFullData(UserFullData data);
}

class UserLocalDataSource implements IUserLocalDataSource {
  final IUsersDao _dao;

  UserLocalDataSource({
    required IUsersDao dao,
  }) : _dao = dao;

  @override
  Future<List<User>?> getUsers() async {
    final users = await _dao.getUsers();

    return users.isEmpty ? null : users;
  }

  @override
  Future<void> saveAllUsers(List<User> users) => _dao.saveAll(users);

  @override
  Future<UserFullData?> getUserFullData(int userId) => _dao.getUserFullData(userId);

  @override
  Future<void> saveUserFullData(UserFullData data) => _dao.saveUserFullData(data);
}
