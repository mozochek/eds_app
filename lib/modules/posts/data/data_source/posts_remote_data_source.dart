import 'package:dio/dio.dart';
import 'package:eds_app/modules/core/domain/entity/paginated_result.dart';
import 'package:eds_app/modules/core/domain/entity/post.dart';
import 'package:eds_app/modules/posts/data/data_source/i_posts_data_source.dart';

abstract class IPostsRemoteDataSource implements IPostsDataSource {}

class PostsRemoteDataSource implements IPostsRemoteDataSource {
  final Dio _dio;

  PostsRemoteDataSource({
    required Dio dio,
  }) : _dio = dio;

  @override
  Future<PaginatedResult<Post>> getPostsPage(int userId, int page, int limit) async {
    final response = await _dio.get<List>(
      'user/$userId/posts',
      queryParameters: <String, dynamic>{
        '_page': page,
        '_limit': limit,
      },
    );

    final data = response.data;

    if (data == null) return PaginatedResult.empty();

    final totalCount = int.parse(response.headers.map['x-total-count']?.first ?? '${data.length}');

    return PaginatedResult(
      total: totalCount,
      result: data.map((json) => Post.fromJson(json as Map<String, dynamic>)).toList(),
    );
  }
}
