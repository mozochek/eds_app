import 'package:eds_app/modules/app_scope.dart';
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
    return BlocProvider(
      create: (context) => UsersLoadingBloc(
        userRepository: AppScope.of(context).userRepository,
      )..add(const UsersLoadingEvent.load()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Список пользователей'),
        ),
        body: SafeArea(
          child: BlocBuilder<UsersLoadingBloc, UsersLoadingState>(
            builder: (context, state) {
              return state.maybeMap<Widget>(
                orElse: () {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
                failed: (_) {
                  return const Center(
                    child: Text('Не удалось загрузить список пользователей'),
                  );
                },
                completed: (state) {
                  final users = state.users;

                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];

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
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
