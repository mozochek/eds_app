import 'package:drift/drift.dart';
import 'package:eds_app/modules/core/data/database/database.dart';
import 'package:eds_app/modules/core/data/database/tables.dart';
import 'package:eds_app/modules/core/domain/entity/lat_long.dart';
import 'package:eds_app/modules/core/domain/entity/user.dart';
import 'package:eds_app/modules/core/domain/entity/user_address.dart';
import 'package:eds_app/modules/core/domain/entity/user_company.dart';
import 'package:eds_app/modules/core/domain/entity/user_full_data.dart';
import 'package:eds_app/modules/user/domain/entity/album.dart';

part 'users_dao.g.dart';

abstract class IUsersDao {
  Future<List<User>> getUsers();

  Future<void> saveAll(List<User> users);

  Future<UserFullData?> getUserFullData(int userId);

  Future<void> saveUserFullData(UserFullData data);
}

@DriftAccessor(
  tables: <Type>[
    UsersTable,
    UserAddressTable,
    UserCompanyTable,
    UserAlbumsTable,
    AlbumImagesTable,
  ],
)
class UsersDao extends DatabaseAccessor<AppDatabase>
    with _$UsersDaoMixin, CoreEntitiesAndCompanionsMapperMixin
    implements IUsersDao {
  UsersDao(super.attachedDatabase);

  @override
  Future<List<User>> getUsers() async => (await usersTable.select().get())
      .map(
        (dto) => dtoToUser(dto),
      )
      .toList();

  @override
  Future<void> saveAll(List<User> users) => batch((batch) {
        for (final user in users) {
          final row = userToCompanion(user);

          batch.insert(
            usersTable,
            row,
            onConflict: DoUpdate(
              (old) => row,
              target: [usersTable.serverId],
            ),
          );
        }
      });

  @override
  Future<UserFullData?> getUserFullData(int userId) async => transaction(() async {
        // TODO: сделать через joins
        final userDto = await (select(usersTable)..where((tbl) => tbl.serverId.equals(userId))).getSingleOrNull();

        if (userDto == null) return null;

        final companyDto =
            await (select(userCompanyTable)..where((tbl) => tbl.userId.equals(userId))).getSingleOrNull();

        if (companyDto == null) return null;

        final addressDto =
            await (select(userAddressTable)..where((tbl) => tbl.userId.equals(userId))).getSingleOrNull();

        if (addressDto == null) return null;

        final albumDtos = await (select(userAlbumsTable)..where((tbl) => tbl.userId.equals(userId))).get();

        if (albumDtos.isEmpty) return null;

        final albums = await _getUserAlbumPreviews(userId);

        if (albums == null) return null;

        return UserFullData(
          user: dtoToUser(userDto),
          company: dtoToCompany(companyDto),
          address: dtoToAddress(addressDto),
          albums: albums,
        );
      });

  Future<List<AlbumFullData>?> _getUserAlbumPreviews(int userId) async {
    final albumsTableName = userAlbumsTable.actualTableName;
    const albumsTableAlias = 'a';
    final albumsImagesTableName = albumImagesTable.actualTableName;
    const albumsImagesTableAlias = 'a_i';

    final rawFullAlbumsData = await customSelect(
      'SELECT $albumsTableAlias.server_id as album_id, $albumsTableAlias.user_id as user_id, $albumsTableAlias.title as title, $albumsImagesTableAlias.server_id as image_id, $albumsImagesTableAlias.description as image_description, $albumsImagesTableAlias.url as url, $albumsImagesTableAlias.thumbnail_url as thumbnail_url FROM $albumsTableName as a LEFT JOIN $albumsImagesTableName as $albumsImagesTableAlias ON $albumsTableAlias.server_id == $albumsImagesTableAlias.album_id WHERE a.user_id == $userId GROUP BY album_id LIMIT 3',
    ).get();

    if (rawFullAlbumsData.isEmpty) return null;

    final result = <AlbumFullData>[];
    for (final raw in rawFullAlbumsData) {
      final data = raw.data;

      result.add(
        AlbumFullData(
          album: Album(
            id: data['album_id'] as int,
            userId: data['user_id'] as int,
            title: data['title'] as String,
          ),
          images: <AlbumImages>[
            AlbumImages(
              id: (data['image_id'] as int?) ?? -1,
              description: (data['image_description'] as String?) ?? '<?>',
              url: (data['url'] as String?) ?? '<?>',
              thumbnailUrl: (data['thumbnail_url'] as String?) ?? '<?>',
            ),
          ],
        ),
      );
    }

    return result;
  }

  @override
  Future<void> saveUserFullData(UserFullData data) async {
    await transaction(() async {
      final user = data.user;
      final userRow = userToCompanion(user);
      await usersTable.insertOne(
        userRow,
        onConflict: DoUpdate(
          (_) => userRow,
          target: [usersTable.serverId],
        ),
      );

      final address = data.address;
      final addressRow = addressToCompanion(user.id, address);
      await userAddressTable.insertOne(
        addressRow,
        onConflict: DoUpdate((old) => addressRow, target: [userAddressTable.userId]),
      );

      final company = data.company;
      final companyRow = companyToCompanion(user.id, company);
      await userCompanyTable.insertOne(
        companyRow,
        onConflict: DoUpdate((old) => companyRow, target: [userCompanyTable.userId]),
      );
    });

    await batch((batch) async {
      final albums = data.albums;
      final albumRows = <UserAlbumsTableCompanion>[];
      final albumImagesRows = <AlbumImagesTableCompanion>[];

      for (final albumData in albums) {
        albumRows.add(albumToCompanion(albumData.album));

        albumImagesRows.addAll(
          albumData.images.map((imgData) => albumImagesToCompanion(albumData.album.id, imgData)),
        );
      }

      batch.insertAll(userAlbumsTable, albumRows);
      batch.insertAll(albumImagesTable, albumImagesRows);
    });
  }
}

mixin CoreEntitiesAndCompanionsMapperMixin {
  UsersTableCompanion userToCompanion(User user) => UsersTableCompanion.insert(
        serverId: user.id,
        fullName: user.fullName,
        username: user.username,
        email: user.email,
        phone: user.phone,
        site: user.site,
      );

  UserAddressTableCompanion addressToCompanion(int userId, UserAddress address) => UserAddressTableCompanion.insert(
        userId: userId,
        street: address.street,
        suite: address.suite,
        city: address.city,
        zipCode: address.zipCode,
        latitude: address.coords.lat,
        longitude: address.coords.lng,
      );

  UserCompanyTableCompanion companyToCompanion(int userId, UserCompany company) => UserCompanyTableCompanion.insert(
        userId: userId,
        name: company.name,
        catchPhrase: company.catchPhrase,
        bs: company.bs,
      );

  UserAlbumsTableCompanion albumToCompanion(Album album) => UserAlbumsTableCompanion.insert(
        serverId: album.id,
        userId: album.userId,
        title: album.title,
      );

  AlbumImagesTableCompanion albumImagesToCompanion(int albumId, AlbumImages images) =>
      AlbumImagesTableCompanion.insert(
        serverId: images.id,
        albumId: albumId,
        description: images.description,
        url: images.url,
        thumbnailUrl: images.thumbnailUrl,
      );

  User dtoToUser(UserDto dto) => User(
        id: dto.serverId,
        fullName: dto.fullName,
        username: dto.username,
        email: dto.email,
        phone: dto.phone,
        site: dto.site,
      );

  UserCompany dtoToCompany(UserCompanyDto dto) => UserCompany(
        name: dto.name,
        catchPhrase: dto.catchPhrase,
        bs: dto.bs,
      );

  UserAddress dtoToAddress(UserAddressDto dto) => UserAddress(
        street: dto.street,
        suite: dto.suite,
        city: dto.city,
        zipCode: dto.zipCode,
        coords: LatLong(
          lat: dto.latitude,
          lng: dto.longitude,
        ),
      );

  Album dtoToAlbum(UsersAlbumsDto dto) => Album(
        id: dto.serverId,
        userId: dto.userId,
        title: dto.title,
      );

  AlbumImages dtoToAlbumImages(AlbumImagesDto dto) => AlbumImages(
        id: dto.serverId,
        description: dto.description,
        url: dto.url,
        thumbnailUrl: dto.thumbnailUrl,
      );
}
