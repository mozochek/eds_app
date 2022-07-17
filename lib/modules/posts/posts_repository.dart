import 'package:dio/dio.dart';
import 'package:eds_app/modules/core/data/repository/i_pagination_repository.dart';
import 'package:eds_app/modules/core/domain/entity/paginated_result.dart';
import 'package:flutter/foundation.dart';

abstract class IPostsRepository extends IPaginationRepository<String> {
  IPostsRepository({
    required super.pageSize,
  });
}

class PostsRepository extends IPostsRepository {
  final Dio _dio;

  PostsRepository({
    required Dio dio,
  })  : _dio = dio,
        super(pageSize: 20);

  @override
  Future<PaginatedResult<String>> getPageFromLocal(int page) => SynchronousFuture(PaginatedResult.empty());

  @override
  Future<PaginatedResult<String>> getPageFromRemote(int page) async {
    final response = await _dio.get<List>(
      'posts',
      queryParameters: <String, dynamic>{
        '_page': page,
        '_limit': pageSize,
      },
    );

    final data = response.data;

    if (data == null) return PaginatedResult.empty();

    final totalCount = int.parse(response.headers.map['x-total-count']?.first ?? '${data.length}');

    return PaginatedResult(
      total: totalCount,
      result: data.map((json) => '${json['id'] as int}: ${json['title'] as String}').toList(),
    );
  }
}
