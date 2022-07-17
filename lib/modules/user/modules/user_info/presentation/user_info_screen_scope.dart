import 'package:eds_app/modules/core/presentation/dependencies_scope.dart';
import 'package:eds_app/modules/user/data/data_source/user_local_data_source.dart';
import 'package:eds_app/modules/user/data/data_source/user_remote_data_source.dart';
import 'package:eds_app/modules/user/data/repository/user_repository.dart';
import 'package:eds_app/modules/user/domain/entity/user_preview_data.dart';
import 'package:eds_app/modules/user/modules/user_info/presentation/bloc/user_info_loading_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserInfoScreenScope extends StatelessWidget {
  final UserPreviewData userPreviewData;
  final Widget child;

  const UserInfoScreenScope({
    required this.userPreviewData,
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final store = DependenciesScope.of(context);

        return UserInfoLoadingBloc(
          previewData: userPreviewData,
          userRepository: UserRepository(
            userLocalDs: UserLocalDataSource(
              dao: store.database.usersDao,
            ),
            userRemoteDs: UserRemoteDataSource(
              dio: store.dio,
            ),
          ),
        )..add(const UserInfoLoadingEvent.load());
      },
      child: child,
    );
  }
}
