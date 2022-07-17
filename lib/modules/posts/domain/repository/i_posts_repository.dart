import 'package:eds_app/modules/core/data/repository/i_pagination_repository.dart';
import 'package:eds_app/modules/core/domain/entity/post.dart';

abstract class IPostsRepository extends IPaginationRepository<Post> {
  final int userId;

  IPostsRepository({
    required this.userId,
    super.pageSize,
  });
}
