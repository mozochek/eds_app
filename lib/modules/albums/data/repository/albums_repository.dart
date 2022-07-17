import 'dart:async';

import 'package:eds_app/modules/albums/data/data_source/albums_local_data_source.dart';
import 'package:eds_app/modules/albums/data/data_source/albums_remote_data_source.dart';
import 'package:eds_app/modules/albums/domain/repository/i_albums_repository.dart';
import 'package:eds_app/modules/core/domain/entity/paginated_result.dart';
import 'package:eds_app/modules/core/domain/entity/album.dart';

class AlbumsRepository extends IAlbumsRepository {
  final IAlbumsRemoteDataSource _albumsRemoteDs;
  final IAlbumsLocalDataSource _albumsLocalDs;

  AlbumsRepository({
    required IAlbumsRemoteDataSource albumsRemoteDs,
    required IAlbumsLocalDataSource albumsLocalDs,
    required super.userId,
  })  : _albumsRemoteDs = albumsRemoteDs,
        _albumsLocalDs = albumsLocalDs,
        super(pageSize: 20);

  @override
  Future<PaginatedResult<Album>> getPageFromLocal(int page) => _albumsLocalDs.getAlbumsPage(userId, page, pageSize);

  @override
  Future<PaginatedResult<Album>> getPageFromRemote(int page) => _albumsRemoteDs.getAlbumsPage(userId, page, pageSize);

  @override
  FutureOr<void> onPageLoadedFromRemote(PaginatedResult<Album> page) async => _albumsLocalDs.saveAllAlbums(page.result);

  @override
  Future<AlbumFullData?> getAlbumFullData(int albumId) async {
    final fromCache = await _albumsLocalDs.getAlbumFullData(albumId);

    if (fromCache != null) return fromCache;

    final fromRemote = await _albumsRemoteDs.getAlbumFullData(albumId);

    if (fromRemote != null) {
      await _albumsLocalDs.saveAlbumFullData(fromRemote);
    }

    return fromRemote;
  }
}
