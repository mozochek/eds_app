import 'package:eds_app/modules/core/presentation/dependencies_scope.dart';
import 'package:eds_app/modules/user/data/data_source/user_local_data_source.dart';
import 'package:eds_app/modules/user/data/data_source/user_remote_data_source.dart';
import 'package:eds_app/modules/user/data/repository/user_repository.dart';
import 'package:eds_app/modules/user/modules/all_users/presentation/bloc/users_bloc.dart';
import 'package:eds_app/modules/user/modules/all_users/presentation/bloc/users_loading_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AllUsersScreenScope extends StatelessWidget {
  final Widget child;

  const AllUsersScreenScope({
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

            return UsersLoadingBloc(
              userRepository: UserRepository(
                userLocalDs: UserLocalDataSource(
                  dao: store.database.usersDao,
                ),
                userRemoteDs: UserRemoteDataSource(
                  dio: store.dio,
                ),
              ),
            )..add(const UsersLoadingEvent.loadNextPage());
          },
        ),
        BlocProvider(create: (_) => UsersBloc()),
      ],
      child: BlocListener<UsersLoadingBloc, UsersLoadingState>(
        listener: (context, state) => state.mapOrNull(
          completed: (state) => context.read<UsersBloc>().add(UsersEvent.addData(state.loadedUsers)),
          failed: (_) => context.read<UsersBloc>().add(const UsersEvent.setError()),
        ),
        child: child,
      ),
    );
  }
}
