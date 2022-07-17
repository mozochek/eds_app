import 'package:eds_app/modules/core/domain/entity/user.dart';
import 'package:eds_app/modules/core/domain/entity/user_full_data.dart';
import 'package:eds_app/modules/user/data/data_source/user_local_data_source.dart';
import 'package:eds_app/modules/user/data/data_source/user_remote_data_source.dart';
import 'package:eds_app/modules/user/domain/repository/i_user_repository.dart';

class UserRepository implements IUserRepository {
  final IUserLocalDataSource _localDs;
  final IUserRemoteDataSource _remoteDs;

  UserRepository({
    required IUserLocalDataSource localDs,
    required IUserRemoteDataSource remoteDs,
  })  : _localDs = localDs,
        _remoteDs = remoteDs;

  @override
  Future<List<User>?> getUsers() async {
    final fromCache = await _localDs.getUsers();

    if (fromCache != null) return fromCache;

    final fromRemote = await _remoteDs.getUsers();

    if (fromRemote != null) {
      await _localDs.saveAllUsers(fromRemote);
    }

    return fromRemote;
  }

  // TODO: вынести дублирующуюся структуру
  @override
  Future<UserFullData?> getUserFullData(int userId) async {
    final fromCache = await _localDs.getUserFullData(userId);

    if (fromCache != null) return fromCache;

    final fromRemote = await _remoteDs.getUserFullData(userId);

    if (fromRemote != null) {
      await _localDs.saveUserFullData(fromRemote);
    }

    return fromRemote;
  }
}
