import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:eds_app/modules/core/data/dao/albums_dao.dart';
import 'package:eds_app/modules/core/data/dao/users_dao.dart';
import 'package:eds_app/modules/core/data/database/tables.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

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
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase()
      : super(
          LazyDatabase(
            () async {
              final dir = await getApplicationDocumentsDirectory();
              final dbFile = File(p.join(dir.path, 'db.sqlite'));
              return NativeDatabase(dbFile, logStatements: true);
            },
          ),
        );

  @override
  int get schemaVersion => 1;
}
