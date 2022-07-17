import 'package:eds_app/modules/core/domain/entity/paginated_result.dart';
import 'package:eds_app/modules/core/domain/entity/post.dart';

abstract class IPostsDataSource {
  Future<PaginatedResult<Post>> getPostsPage(int userId, int page, int limit);
}