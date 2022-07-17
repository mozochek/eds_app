import 'package:eds_app/modules/core/presentation/dependencies_scope.dart';
import 'package:eds_app/modules/posts/data/data_source/posts_local_data_source.dart';
import 'package:eds_app/modules/posts/data/data_source/posts_remote_data_source.dart';
import 'package:eds_app/modules/posts/data/repository/posts_repository.dart';
import 'package:eds_app/modules/posts/modules/user_posts/presentation/bloc/user_posts_bloc.dart';
import 'package:eds_app/modules/posts/modules/user_posts/presentation/bloc/user_posts_loading_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserPostsScreenScope extends StatelessWidget {
  final int userId;
  final Widget child;

  const UserPostsScreenScope({
    required this.userId,
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) {
            final store = DependenciesScope.of(context);

            return UserPostsLoadingBloc(
              postsRepository: PostsRepository(
                userId: userId,
                postsRemoteDs: PostsRemoteDataSource(
                  dio: store.dio,
                ),
                postsLocalDs: PostsLocalDataSource(
                  postsDao: store.database.postsDao,
                ),
              ),
            )..add(const UserPostsLoadingEvent.loadNextPage());
          },
        ),
        BlocProvider(create: (_) => UserPostsBloc()),
      ],
      child: BlocListener<UserPostsLoadingBloc, UserPostsLoadingState>(
        listener: (context, state) {
          state.mapOrNull(
            completed: (state) => context.read<UserPostsBloc>().add(UserPostsEvent.addData(state.posts)),
            failed: (_) => context.read<UserPostsBloc>().add(const UserPostsEvent.setError()),
          );
        },
        child: child,
      ),
    );
  }
}
