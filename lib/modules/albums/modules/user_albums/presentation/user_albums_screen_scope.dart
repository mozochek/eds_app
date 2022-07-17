import 'package:eds_app/modules/albums/data/data_source/albums_local_data_source.dart';
import 'package:eds_app/modules/albums/data/data_source/albums_remote_data_source.dart';
import 'package:eds_app/modules/albums/data/repository/albums_repository.dart';
import 'package:eds_app/modules/albums/modules/user_albums/presentation/bloc/user_albums_bloc.dart';
import 'package:eds_app/modules/albums/modules/user_albums/presentation/bloc/user_albums_loading_bloc.dart';
import 'package:eds_app/modules/core/presentation/dependencies_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserAlbumsScreenScope extends StatelessWidget {
  final int userId;
  final Widget child;

  const UserAlbumsScreenScope({
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

            return UserAlbumsLoadingBloc(
              albumsRepository: AlbumsRepository(
                userId: userId,
                albumsRemoteDs: AlbumsRemoteDataSource(
                  dio: store.dio,
                ),
                albumsLocalDs: AlbumsLocalDataSource(
                  albumsDao: store.database.albumsDao,
                ),
              ),
            )..add(const UserAlbumsLoadingEvent.loadNextPage());
          },
        ),
        BlocProvider(create: (_) => UserAlbumsBloc()),
      ],
      child: BlocListener<UserAlbumsLoadingBloc, UserAlbumsLoadingState>(
        listener: (context, state) => state.mapOrNull(
          completed: (state) => context.read<UserAlbumsBloc>().add(UserAlbumsEvent.addData(state.loadedAlbums)),
          failed: (_) => context.read<UserAlbumsBloc>().add(const UserAlbumsEvent.setError()),
        ),
        child: child,
      ),
    );
  }
}
