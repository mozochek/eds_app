import 'package:eds_app/modules/core/data/repository/i_pagination_repository.dart';
import 'package:eds_app/modules/core/domain/entity/album.dart';

abstract class IAlbumsRepository extends IPaginationRepository<Album> {
  final int userId;

  IAlbumsRepository({
    required this.userId,
    super.pageSize,
  });

  Future<AlbumFullData?> getAlbumFullData(int albumId);
}
