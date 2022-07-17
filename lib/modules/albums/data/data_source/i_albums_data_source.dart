import 'package:eds_app/modules/core/domain/entity/paginated_result.dart';
import 'package:eds_app/modules/user/domain/entity/album.dart';

abstract class IAlbumsDataSource {
  Future<PaginatedResult<Album>> getAlbumsPage(int userId, int page, int limit);

  Future<AlbumFullData?> getAlbumFullData(int albumId);
}
