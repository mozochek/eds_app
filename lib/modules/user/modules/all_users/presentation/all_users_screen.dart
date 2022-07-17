import 'package:eds_app/modules/app_scope.dart';
import 'package:eds_app/modules/dependencies_scope.dart';
import 'package:eds_app/modules/user/data/data_source/user_local_data_source.dart';
import 'package:eds_app/modules/user/data/data_source/user_remote_data_source.dart';
import 'package:eds_app/modules/user/data/repository/user_repository.dart';
import 'package:eds_app/modules/user/domain/entity/user_preview_data.dart';
import 'package:eds_app/modules/user/modules/all_users/presentation/bloc/users_bloc.dart';
import 'package:eds_app/modules/user/modules/all_users/presentation/bloc/users_loading_bloc.dart';
import 'package:eds_app/modules/user/modules/user_info/presentation/user_info_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AllUsersScreen extends StatelessWidget {
  const AllUsersScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => UsersLoadingBloc(
            userRepository: UserRepository(
              userLocalDs: UserLocalDataSource(
                dao: AppScope.of(context).usersDao,
              ),
              userRemoteDs: UserRemoteDataSource(
                dio: DependenciesScope.of(context).dio,
              ),
            ),
          )..add(const UsersLoadingEvent.loadNextPage()),
        ),
        BlocProvider(create: (_) => UsersBloc()),
      ],
      child: BlocListener<UsersLoadingBloc, UsersLoadingState>(
        listener: (context, state) => state.mapOrNull(
          completed: (state) => context.read<UsersBloc>().add(UsersEvent.addData(state.loadedUsers)),
          failed: (_) => context.read<UsersBloc>().add(const UsersEvent.setError()),
        ),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Список пользователей'),
          ),
          body: SafeArea(
            child: BlocBuilder<UsersBloc, UsersState>(
              builder: (context, state) {
                return state.map<Widget>(
                  notInitialized: (_) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                  error: (_) {
                    return const Center(
                      child: Text('Не удалось загрузить список пользователей'),
                    );
                  },
                  data: (state) {
                    return _UsersList(users: state.users);
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

class _UsersList extends StatefulWidget {
  final List<UserPreviewData> users;

  const _UsersList({
    required this.users,
    Key? key,
  }) : super(key: key);

  @override
  State<_UsersList> createState() => _UsersListState();
}

class _UsersListState extends State<_UsersList> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
  }

  @override
  void didUpdateWidget(covariant _UsersList oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.users != widget.users) {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
        context.read<UsersLoadingBloc>().add(const UsersLoadingEvent.loadNextPage());
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
            context.read<UsersLoadingBloc>().add(const UsersLoadingEvent.loadNextPage());
          }
        }
        return false;
      },
      child: ListView.builder(
        controller: _scrollController,
        itemCount: widget.users.length,
        itemBuilder: (context, index) {
          final user = widget.users[index];

          return ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => UserInfoScreen(userPreviewData: user)),
              );
            },
            leading: Text('${user.id}'),
            title: Text(user.fullName),
            subtitle: Text(user.username),
          );
        },
      ),
    );
  }
}
