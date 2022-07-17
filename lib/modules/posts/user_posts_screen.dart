import 'package:eds_app/modules/dependencies_scope.dart';
import 'package:eds_app/modules/posts/posts_repository.dart';
import 'package:eds_app/modules/posts/user_posts_bloc.dart';
import 'package:eds_app/modules/posts/user_posts_loading_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserPostsScreen extends StatelessWidget {
  const UserPostsScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => UserPostsLoadingBloc(
            postsRepository: PostsRepository(
              dio: DependenciesScope.of(context).dio,
            ),
          )..add(const UserPostsLoadingEvent.loadNextPage()),
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
        child: Scaffold(
          body: SafeArea(
            child: BlocBuilder<UserPostsBloc, UserPostsState>(
              builder: (context, state) {
                return state.map<Widget>(
                  notInitialized: (_) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                  error: (_) {
                    return const Center(
                      child: Text('Произошла ошибка загрузки постов'),
                    );
                  },
                  data: (state) {
                    return _PostsList(posts: state.posts);
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _PostsList extends StatelessWidget {
  final List<String> posts;

  const _PostsList({
    required this.posts,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NotificationListener(
      onNotification: (n) {
        // TODO: возможно вместе с ScrollMetricsNotification нужно слушать и другие уведомления, например о соверашющемся скролле
        if (n is ScrollMetricsNotification) {
          if (n.metrics.pixels >= n.metrics.maxScrollExtent * 0.8) {
            context.read<UserPostsLoadingBloc>().add(const UserPostsLoadingEvent.loadNextPage());
          }
        }
        return false;
      },
      child: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];

          Widget child = ListTile(
            title: Text(post),
          );

          final isLast = index == posts.length - 1;

          if (isLast == false) return child;

          return Column(
            children: <Widget>[
              child,
              BlocBuilder<UserPostsLoadingBloc, UserPostsLoadingState>(
                buildWhen: (prev, curr) => prev.isLoading != curr.isLoading,
                builder: (context, state) {
                  if (state.isLoading) {
                    return Column(
                      children: const <Widget>[
                        SizedBox(height: 8.0),
                        CircularProgressIndicator(),
                      ],
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
