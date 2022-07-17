import 'package:drift/drift.dart';
import 'package:eds_app/modules/core/data/dao/users_dao.dart';
import 'package:eds_app/modules/core/data/database/database.dart';
import 'package:eds_app/modules/core/data/database/tables.dart';
import 'package:eds_app/modules/core/domain/entity/paginated_result.dart';
import 'package:eds_app/modules/user/domain/entity/album.dart';

part 'albums_dao.g.dart';

abstract class IAlbumsDao {
  Future<void> saveAllAlbums(List<Album> albums);

  Future<PaginatedResult<Album>> getAlbumsPage(int userId, int page, int limit);

  Future<AlbumFullData?> getAlbumFullData(int albumId);

  Future<void> saveAlbumFullData(AlbumFullData data);
}

@DriftAccessor(
  tables: <Type>[
    UserAlbumsTable,
    AlbumImagesTable,
  ],
)
class AlbumsDao extends DatabaseAccessor<AppDatabase>
    with _$AlbumsDaoMixin, CoreEntitiesAndCompanionsMapperMixin
    implements IAlbumsDao {
  AlbumsDao(super.attachedDatabase);

  @override
  Future<void> saveAllAlbums(List<Album> albums) async => batch((batch) async {
        for (final album in albums) {
          final row = albumToCompanion(album);

          batch.insert(
            userAlbumsTable,
            row,
            onConflict: DoUpdate(
              (old) => row,
              target: [userAlbumsTable.serverId],
            ),
          );
        }
      });

  @override
  Future<PaginatedResult<Album>> getAlbumsPage(int userId, int page, int limit) async {
    final albumDtos = await (select(userAlbumsTable)
          ..limit(limit)
          ..where((tbl) => tbl.userId.equals(userId)))
        .get();

    final count = await customSelect(
      'SELECT COUNT(server_id) as count FROM ${userAlbumsTable.actualTableName} WHERE user_id == ?',
      variables: [
        Variable(userId),
      ],
    ).getSingle();

    return PaginatedResult(
      total: count.data['count'] as int,
      result: albumDtos.map((dto) => dtoToAlbum(dto)).toList(),
    );
  }

  @override
  Future<AlbumFullData?> getAlbumFullData(int albumId) async => transaction(() async {
        final albumDto =
            await (select(userAlbumsTable)..where((tbl) => tbl.serverId.equals(albumId))).getSingleOrNull();

        if (albumDto == null) return null;

        final albumImagesDtos =
            await (select(albumImagesTable)..where((tbl) => tbl.albumId.equals(albumDto.serverId))).get();

        if (albumImagesDtos.isEmpty) return null;

        return AlbumFullData(
          album: dtoToAlbum(albumDto),
          images: albumImagesDtos.map((dto) => dtoToAlbumImages(dto)).toList(),
        );
      });

  @override
  Future<void> saveAlbumFullData(AlbumFullData data) => batch((batch) async {
        final albumRow = albumToCompanion(data.album);
        batch.insert(
          userAlbumsTable,
          albumRow,
          onConflict: DoUpdate(
            (_) => albumRow,
            target: <Column>[userAlbumsTable.serverId],
          ),
        );

        final albumImagesRows = data.images.map((i) => albumImagesToCompanion(data.album.id, i));

        for (final albumImagesRow in albumImagesRows) {
          batch.insert(
            albumImagesTable,
            albumImagesRow,
            onConflict: DoUpdate(
              (_) => albumImagesRow,
              target: <Column>[albumImagesTable.serverId],
            ),
          );
        }
      });
}
