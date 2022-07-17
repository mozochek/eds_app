import 'package:dio/dio.dart';
import 'package:eds_app/modules/albums/data/data_source/i_albums_data_source.dart';
import 'package:eds_app/modules/core/domain/entity/paginated_result.dart';
import 'package:eds_app/modules/user/domain/entity/album.dart';

// TODO: возможно избавиться от такого прокси наследования
abstract class IAlbumsRemoteDataSource implements IAlbumsDataSource {}

class AlbumsRemoteDataSource extends IAlbumsRemoteDataSource {
  final Dio _dio;

  AlbumsRemoteDataSource({
    required Dio dio,
  }) : _dio = dio;

  @override
  Future<PaginatedResult<Album>> getAlbumsPage(int userId, int page, int limit) async {
    final response = await _dio.get<List>(
      'user/$userId/albums',
      queryParameters: <String, dynamic>{
        '_page': page,
        '_limit': limit,
      },
    );

    final data = response.data;

    if (data == null) return PaginatedResult.empty();

    // TODO: вынести парсинг хэдеров в миксин
    final totalCount = int.parse(response.headers.map['x-total-count']?.first ?? '${data.length}');

    return PaginatedResult<Album>(
      total: totalCount,
      result: data.map((json) => Album.fromJson(json as Map<String, dynamic>)).toList(),
    );
  }

  @override
  Future<AlbumFullData?> getAlbumFullData(int albumId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      'albums/$albumId',
      queryParameters: <String, dynamic>{
        '_embed': 'photos',
      },
    );

    final data = response.data;

    if (data == null) return null;

    return AlbumFullData(
      album: Album.fromJson(data),
      images: (data['photos'] as List).map((json) => AlbumImages.fromJson(json as Map<String, dynamic>)).toList(),
    );
  }
}
