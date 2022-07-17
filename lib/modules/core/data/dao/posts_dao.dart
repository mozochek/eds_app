import 'package:drift/drift.dart';
import 'package:eds_app/modules/core/data/dao/users_dao.dart';
import 'package:eds_app/modules/core/data/database/database.dart';
import 'package:eds_app/modules/core/data/database/tables.dart';
import 'package:eds_app/modules/core/domain/entity/paginated_result.dart';
import 'package:eds_app/modules/core/domain/entity/post.dart';

part 'posts_dao.g.dart';

abstract class IPostsDao {
  Future<PaginatedResult<Post>> getPostsPage(int userId, int page, int limit);

  Future<void> saveAllPosts(List<Post> posts);
}

@DriftAccessor(
  tables: <Type>[
    UserPostsTable,
    PostCommentsTable,
  ],
)
class PostsDao extends DatabaseAccessor<AppDatabase>
    with _$PostsDaoMixin, CoreEntitiesAndCompanionsMapperMixin
    implements IPostsDao {
  PostsDao(super.attachedDatabase);

  @override
  Future<PaginatedResult<Post>> getPostsPage(int userId, int page, int limit) => transaction(() async {
        final postRows = await customSelect(
          'SELECT * FROM (SELECT ROW_NUMBER() OVER (ORDER BY server_id) as num, * FROM ${userPostsTable.actualTableName} WHERE user_id = ?) WHERE num <= ? AND num > ?',
          variables: <Variable>[
            Variable(userId),
            Variable(page * limit),
            Variable((page - 1) * limit),
          ],
        ).get();

        final count = await customSelect(
          'SELECT COUNT(server_id) as count FROM ${userPostsTable.actualTableName} WHERE user_id = ?',
          variables: <Variable>[Variable(userId)],
        ).getSingle();

        return PaginatedResult(
          total: count.data['count'] as int,
          result: postRows.map((row) {
            final data = row.data;

            return Post(
              id: data['server_id'] as int,
              userId: data['user_id'] as int,
              title: data['title'] as String,
              body: data['body'] as String,
            );
          }).toList(),
        );
      });

  @override
  Future<void> saveAllPosts(List<Post> posts) => batch((batch) {
        for (final post in posts) {
          final row = postToCompanion(post);

          batch.insert(
            userPostsTable,
            row,
            onConflict: DoUpdate(
              (_) => row,
              target: [userPostsTable.serverId],
            ),
          );
        }
      });
}
