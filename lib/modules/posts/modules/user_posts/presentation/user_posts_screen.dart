import 'package:eds_app/modules/app_scope.dart';
import 'package:eds_app/modules/core/domain/entity/post.dart';
import 'package:eds_app/modules/dependencies_scope.dart';
import 'package:eds_app/modules/posts/data/data_source/posts_local_data_source.dart';
import 'package:eds_app/modules/posts/data/data_source/posts_remote_data_source.dart';
import 'package:eds_app/modules/posts/data/repository/posts_repository.dart';
import 'package:eds_app/modules/posts/modules/user_posts/presentation/bloc/user_posts_bloc.dart';
import 'package:eds_app/modules/posts/modules/user_posts/presentation/bloc/user_posts_loading_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserPostsScreen extends StatelessWidget {
  final int userId;

  const UserPostsScreen({
    required this.userId,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => UserPostsLoadingBloc(
            postsRepository: PostsRepository(
              userId: userId,
              postsRemoteDs: PostsRemoteDataSource(
                dio: DependenciesScope.of(context).dio,
              ),
              postsLocalDs: PostsLocalDataSource(
                postsDao: AppScope.of(context).postsDao,
              ),
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
          appBar: AppBar(
            title: const Text('Список постов'),
          ),
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

class _PostsList extends StatefulWidget {
  final List<Post> posts;

  const _PostsList({
    required this.posts,
    Key? key,
  }) : super(key: key);

  @override
  State<_PostsList> createState() => _PostsListState();
}

class _PostsListState extends State<_PostsList> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
  }

  @override
  void didUpdateWidget(covariant _PostsList oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.posts != widget.posts) {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
        context.read<UserPostsLoadingBloc>().add(const UserPostsLoadingEvent.loadNextPage());
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener(
      onNotification: (n) {
        if (n is ScrollMetricsNotification) {
          if (n.metrics.pixels >= n.metrics.maxScrollExtent * 0.8) {
            context.read<UserPostsLoadingBloc>().add(const UserPostsLoadingEvent.loadNextPage());
          }
        }

        return false;
      },
      child: ListView.builder(
        controller: _scrollController,
        itemCount: widget.posts.length,
        itemBuilder: (context, index) {
          final post = widget.posts[index];

          Widget child = ListTile(
            onTap: () {},
            leading: Text('${post.id}'),
            title: Text(post.title),
            subtitle: Text(
              post.body,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          );

          final isLast = index == widget.posts.length - 1;

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
