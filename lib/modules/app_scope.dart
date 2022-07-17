import 'package:eds_app/modules/core/data/dao/albums_dao.dart';
import 'package:eds_app/modules/core/data/dao/posts_dao.dart';
import 'package:eds_app/modules/core/data/dao/users_dao.dart';
import 'package:eds_app/modules/core/data/database/database.dart';
import 'package:flutter/material.dart';

@immutable
class AppStore {
  final AppDatabase database;
  final IUsersDao usersDao;
  final IAlbumsDao albumsDao;
  final IPostsDao postsDao;

  const AppStore({
    required this.database,
    required this.usersDao,
    required this.albumsDao,
    required this.postsDao,
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

    _store = AppStore(
      database: db,
      usersDao: db.usersDao,
      albumsDao: db.albumsDao,
      postsDao: db.postsDao,
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
