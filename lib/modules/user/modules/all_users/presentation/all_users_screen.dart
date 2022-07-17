import 'package:eds_app/modules/core/presentation/l10n/app_localizations.dart';
import 'package:eds_app/modules/user/domain/entity/user_preview_data.dart';
import 'package:eds_app/modules/user/modules/all_users/presentation/all_users_screen_scope.dart';
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
    final l10n = AppLocalizations.of(context);

    return AllUsersScreenScope(
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.listOfUsers),
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
                  return Center(
                    child: Text(l10n.listOfUsersError),
                  );
                },
                data: (state) {
                  final users = state.users;

                  return _UsersList(users: users);
                },
              );
            },
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

          Widget child = ListTile(
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

          final isLast = index == widget.users.length - 1;

          if (isLast == false) return child;

          return Column(
            children: <Widget>[
              child,
              BlocBuilder<UsersLoadingBloc, UsersLoadingState>(
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
