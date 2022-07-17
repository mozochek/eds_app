import 'package:eds_app/modules/core/domain/entity/paginated_result.dart';
import 'package:eds_app/modules/core/domain/entity/user.dart';
import 'package:eds_app/modules/core/domain/entity/user_full_data.dart';
import 'package:eds_app/modules/user/data/data_source/user_local_data_source.dart';
import 'package:eds_app/modules/user/data/data_source/user_remote_data_source.dart';
import 'package:eds_app/modules/user/domain/repository/i_user_repository.dart';

class UserRepository extends IUserRepository {
  final IUserLocalDataSource _userLocalDs;
  final IUserRemoteDataSource _userRemoteDs;

  UserRepository({
    required IUserLocalDataSource userLocalDs,
    required IUserRemoteDataSource userRemoteDs,
  })  : _userLocalDs = userLocalDs,
        _userRemoteDs = userRemoteDs;

  // TODO: вынести дублирующуюся структуру
  @override
  Future<UserFullData?> getUserFullData(int userId) async {
    final fromCache = await _userLocalDs.getUserFullData(userId);

    if (fromCache != null) return fromCache;

    final fromRemote = await _userRemoteDs.getUserFullData(userId);

    if (fromRemote != null) {
      await _userLocalDs.saveUserFullData(fromRemote);
    }

    return fromRemote;
  }

  @override
  Future<PaginatedResult<User>> getPageFromLocal(int page) => _userLocalDs.getUsersPage(page, pageSize);

  @override
  Future<PaginatedResult<User>> getPageFromRemote(int page) => _userRemoteDs.getUsersPage(page, pageSize);

  @override
  Future<void> onPageLoadedFromRemote(PaginatedResult<User> page) => _userLocalDs.saveAllUsers(page.result);
}
