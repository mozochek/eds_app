import 'package:dio/dio.dart';
import 'package:eds_app/modules/core/domain/entity/album.dart';
import 'package:eds_app/modules/core/domain/entity/paginated_result.dart';
import 'package:eds_app/modules/core/domain/entity/post.dart';
import 'package:eds_app/modules/core/domain/entity/user.dart';
import 'package:eds_app/modules/core/domain/entity/user_address.dart';
import 'package:eds_app/modules/core/domain/entity/user_company.dart';
import 'package:eds_app/modules/core/domain/entity/user_full_data.dart';
import 'package:eds_app/modules/user/data/data_source/i_user_data_source.dart';

abstract class IUserRemoteDataSource implements IUserDataSource {}

class UserRemoteDataSource implements IUserRemoteDataSource {
  final Dio _dio;

  UserRemoteDataSource({
    required Dio dio,
  }) : _dio = dio;

  @override
  Future<PaginatedResult<User>> getUsersPage(int page, int limit) async {
    final response = await _dio.get<List>(
      'users',
      queryParameters: <String, dynamic>{
        '_page': page,
        '_limit': limit,
      },
    );

    final data = response.data;

    if (data == null) return PaginatedResult.empty();

    final totalCount = int.parse(response.headers.map['x-total-count']?.first ?? '${data.length}');

    return PaginatedResult<User>(
      total: totalCount,
      result: data.map((json) => User.fromJson(json as Map<String, dynamic>)).toList(),
    );
  }

  @override
  Future<UserFullData?> getUserFullData(int userId) async {
    final userData = (await _dio.get<Map<String, dynamic>>('users/$userId')).data;

    if (userData == null) return null;

    final user = User.fromJson(userData);

    final userAlbums = await _getThreeAlbumsPreviewsForUser(userId);

    if (userAlbums == null) return null;

    final userPosts = await _getThreePostsPreviewsForUser(userId);

    if (userPosts == null) return null;

    return UserFullData(
      user: user,
      company: UserCompany.fromJson(userData['company'] as Map<String, dynamic>),
      address: UserAddress.fromJson(userData['address'] as Map<String, dynamic>),
      albums: userAlbums,
      posts: userPosts,
    );
  }

  Future<List<AlbumFullData>?> _getThreeAlbumsPreviewsForUser(int userId) async {
    final albumsData = (await _dio.get<List>(
      'users/$userId/albums',
      queryParameters: <String, dynamic>{
        '_page': 1,
        '_limit': 3,
        '_embed': 'photos',
      },
    ))
        .data;

    if (albumsData == null) return null;

    final result = <AlbumFullData>[];

    for (final albumJson in albumsData) {
      final album = Album.fromJson(albumJson as Map<String, dynamic>);
      final images = (albumJson['photos'] as List).map((imgJson) => AlbumImages.fromJson(imgJson)).toList();
      result.add(AlbumFullData(album: album, images: images));
    }

    return result;
  }

  Future<List<Post>?> _getThreePostsPreviewsForUser(int userId) async {
    final postsData = (await _dio.get<List>(
      'users/$userId/posts',
      queryParameters: <String, dynamic>{
        '_page': 1,
        '_limit': 3,
      },
    ))
        .data;

    if (postsData == null) return null;

    final result = <Post>[];

    for (final postJson in postsData) {
      result.add(Post.fromJson(postJson as Map<String, dynamic>));
    }

    return result;
  }
}
