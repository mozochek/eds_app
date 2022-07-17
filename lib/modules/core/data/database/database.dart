import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:eds_app/modules/core/data/dao/albums_dao.dart';
import 'package:eds_app/modules/core/data/dao/posts_dao.dart';
import 'package:eds_app/modules/core/data/dao/users_dao.dart';
import 'package:eds_app/modules/core/data/database/tables.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

abstract class IAppDatabase {
  IUsersDao get usersDao;

  IAlbumsDao get albumsDao;

  IPostsDao get postsDao;

  Future<void> close();
}

@DriftDatabase(
  tables: <Type>[
    UsersTable,
    UserAddressTable,
    UserCompanyTable,
    UserPostsTable,
    UserAlbumsTable,
    AlbumImagesTable,
    PostCommentsTable,
  ],
  daos: <Type>[
    UsersDao,
    AlbumsDao,
    PostsDao,
  ],
)
class AppDatabase extends _$AppDatabase implements IAppDatabase {
  AppDatabase()
      : super(
          LazyDatabase(
            () async {
              final dir = await getApplicationDocumentsDirectory();
              final dbFile = File(p.join(dir.path, 'db.sqlite'));
              return NativeDatabase(dbFile, logStatements: kDebugMode);
            },
          ),
        );

  @override
  int get schemaVersion => 1;
}
