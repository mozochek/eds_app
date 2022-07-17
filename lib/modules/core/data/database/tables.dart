import 'package:drift/drift.dart';

@DataClassName('UserDto')
class UsersTable extends Table {
  IntColumn get localId => integer().autoIncrement()();

  IntColumn get serverId => integer().unique()();

  TextColumn get fullName => text()();

  TextColumn get username => text()();

  TextColumn get email => text()();

  TextColumn get phone => text()();

  TextColumn get site => text()();
}

@DataClassName('UserAddressDto')
class UserAddressTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get userId => integer().unique().references(UsersTable, #serverId)();

  TextColumn get street => text()();

  TextColumn get suite => text()();

  TextColumn get city => text()();

  TextColumn get zipCode => text()();

  RealColumn get latitude => real()();

  RealColumn get longitude => real()();
}

@DataClassName('UserCompanyDto')
class UserCompanyTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get userId => integer().unique().references(UsersTable, #serverId)();

  TextColumn get name => text()();

  TextColumn get catchPhrase => text()();

  TextColumn get bs => text()();
}

@DataClassName('UsersPostsDto')
class UserPostsTable extends Table {
  IntColumn get localId => integer().autoIncrement()();

  IntColumn get serverId => integer().unique()();

  IntColumn get userId => integer().references(UsersTable, #serverId)();

  TextColumn get title => text()();

  TextColumn get body => text()();
}

@DataClassName('UsersAlbumsDto')
class UserAlbumsTable extends Table {
  IntColumn get localId => integer().autoIncrement()();

  IntColumn get serverId => integer().unique()();

  IntColumn get userId => integer().references(UsersTable, #serverId)();

  TextColumn get title => text()();
}

@DataClassName('AlbumImagesDto')
class AlbumImagesTable extends Table {
  IntColumn get localId => integer().autoIncrement()();

  IntColumn get serverId => integer().unique()();

  IntColumn get albumId => integer().references(UserAlbumsTable, #serverId)();

  TextColumn get description => text()();

  TextColumn get url => text()();

  TextColumn get thumbnailUrl => text()();
}

@DataClassName('PostCommentsDto')
class PostCommentsTable extends Table {
  IntColumn get localId => integer().autoIncrement()();

  IntColumn get serverId => integer().unique()();

  IntColumn get postId => integer().references(UserPostsTable, #serverId)();

  TextColumn get username => text()();

  TextColumn get userEmail => text()();

  TextColumn get body => text()();
}
