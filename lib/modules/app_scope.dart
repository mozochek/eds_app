import 'package:eds_app/modules/core/data/dao/albums_dao.dart';
import 'package:eds_app/modules/core/data/dao/users_dao.dart';
import 'package:eds_app/modules/core/data/database/database.dart';
import 'package:eds_app/modules/dependencies_scope.dart';
import 'package:eds_app/modules/user/data/data_source/user_local_data_source.dart';
import 'package:eds_app/modules/user/data/data_source/user_remote_data_source.dart';
import 'package:eds_app/modules/user/data/repository/user_repository.dart';
import 'package:eds_app/modules/user/domain/repository/i_user_repository.dart';
import 'package:flutter/material.dart';

@immutable
class AppStore {
  final AppDatabase database;
  final IUsersDao usersDao;
  final IAlbumsDao albumsDao;

  // TODO: убрать репозитории и датасоурсы из AppStore
  final IUserLocalDataSource userLocalDataSource;
  final IUserRemoteDataSource userRemoteDataSource;
  final IUserRepository userRepository;

  const AppStore({
    required this.database,
    required this.usersDao,
    required this.albumsDao,
    required this.userLocalDataSource,
    required this.userRemoteDataSource,
    required this.userRepository,
  });
}

class AppScope extends StatefulWidget {
  final Widget child;

  const AppScope({
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  State<AppScope> createState() => _AppScopeState();

  static AppStore of(BuildContext context) {
    final inhWidget = context.findAncestorWidgetOfExactType<_AppInhScope>();

    if (inhWidget is! _AppInhScope) {
      throw Exception('_AppInhScope was not found above \'${context.widget}\' widget.');
    }

    return inhWidget.store;
  }
}

class _AppScopeState extends State<AppScope> {
  late final AppStore _store;

  @override
  void initState() {
    super.initState();

    final db = AppDatabase();
    final userLocalDs = UserLocalDataSource(dao: db.usersDao);
    final userRemoteDs = UserRemoteDataSource(dio: DependenciesScope.of(context).dio);

    _store = AppStore(
      database: db,
      usersDao: db.usersDao,
      albumsDao: db.albumsDao,
      userLocalDataSource: userLocalDs,
      userRemoteDataSource: userRemoteDs,
      userRepository: UserRepository(
        localDs: userLocalDs,
        remoteDs: userRemoteDs,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _AppInhScope(
      store: _store,
      child: widget.child,
    );
  }
}

class _AppInhScope extends InheritedWidget {
  final AppStore store;

  const _AppInhScope({
    required this.store,
    required super.child,
    super.key,
  });

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => oldWidget is _AppInhScope && store != oldWidget.store;
}
