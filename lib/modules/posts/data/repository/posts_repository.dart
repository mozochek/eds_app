import 'package:eds_app/modules/core/domain/entity/paginated_result.dart';
import 'package:eds_app/modules/core/domain/entity/post.dart';
import 'package:eds_app/modules/posts/data/data_source/posts_local_data_source.dart';
import 'package:eds_app/modules/posts/data/data_source/posts_remote_data_source.dart';
import 'package:eds_app/modules/posts/domain/repository/i_posts_repository.dart';

class PostsRepository extends IPostsRepository {
  final IPostsRemoteDataSource _postsRemoteDs;
  final IPostsLocalDataSource _postsLocalDs;

  PostsRepository({
    required IPostsRemoteDataSource postsRemoteDs,
    required IPostsLocalDataSource postsLocalDs,
    required super.userId,
  })  : _postsRemoteDs = postsRemoteDs,
        _postsLocalDs = postsLocalDs;

  @override
  Future<PaginatedResult<Post>> getPageFromLocal(int page) => _postsLocalDs.getPostsPage(userId, page, pageSize);

  @override
  Future<PaginatedResult<Post>> getPageFromRemote(int page) => _postsRemoteDs.getPostsPage(userId, page, pageSize);

  @override
  Future<void> onPageLoadedFromRemote(PaginatedResult<Post> page) => _postsLocalDs.saveAllPosts(page.result);
}
