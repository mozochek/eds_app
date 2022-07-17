import 'package:eds_app/modules/core/data/dao/posts_dao.dart';
import 'package:eds_app/modules/core/domain/entity/paginated_result.dart';
import 'package:eds_app/modules/core/domain/entity/post.dart';
import 'package:eds_app/modules/posts/data/data_source/i_posts_data_source.dart';

abstract class IPostsLocalDataSource implements IPostsDataSource {
  Future<void> saveAllPosts(List<Post> posts);
}

class PostsLocalDataSource implements IPostsLocalDataSource {
  final IPostsDao _dao;

  PostsLocalDataSource({
    required IPostsDao postsDao,
  }) : _dao = postsDao;

  @override
  Future<PaginatedResult<Post>> getPostsPage(int userId, int page, int limit) => _dao.getPostsPage(userId, page, limit);

  @override
  Future<void> saveAllPosts(List<Post> posts) => _dao.saveAllPosts(posts);
}
