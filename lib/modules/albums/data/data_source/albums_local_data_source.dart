import 'package:eds_app/modules/albums/data/data_source/i_albums_data_source.dart';
import 'package:eds_app/modules/core/data/dao/albums_dao.dart';
import 'package:eds_app/modules/core/domain/entity/paginated_result.dart';
import 'package:eds_app/modules/user/domain/entity/album.dart';

abstract class IAlbumsLocalDataSource implements IAlbumsDataSource {
  Future<void> saveAllAlbums(List<Album> albums);

  Future<void> saveAlbumFullData(AlbumFullData data);
}

class AlbumsLocalDataSource implements IAlbumsLocalDataSource {
  final IAlbumsDao _dao;

  AlbumsLocalDataSource({
    required IAlbumsDao albumsDao,
  }) : _dao = albumsDao;

  @override
  Future<void> saveAllAlbums(List<Album> albums) => _dao.saveAllAlbums(albums);

  @override
  Future<PaginatedResult<Album>> getAlbumsPage(int userId, int page, int limit) =>
      _dao.getAlbumsPage(userId, page, limit);

  @override
  Future<AlbumFullData?> getAlbumFullData(int albumId) => _dao.getAlbumFullData(albumId);

  @override
  Future<void> saveAlbumFullData(AlbumFullData data) => _dao.saveAlbumFullData(data);
}
