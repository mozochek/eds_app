import 'package:eds_app/modules/albums/data/data_source/albums_local_data_source.dart';
import 'package:eds_app/modules/albums/data/data_source/albums_remote_data_source.dart';
import 'package:eds_app/modules/albums/data/repository/albums_repository.dart';
import 'package:eds_app/modules/albums/modules/album_info/presentation/album_info_screen.dart';
import 'package:eds_app/modules/albums/modules/user_albums/presentation/bloc/user_albums_bloc.dart';
import 'package:eds_app/modules/albums/modules/user_albums/presentation/bloc/user_albums_loading_bloc.dart';
import 'package:eds_app/modules/app_scope.dart';
import 'package:eds_app/modules/dependencies_scope.dart';
import 'package:eds_app/modules/core/domain/entity/album.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserAlbumsScreen extends StatelessWidget {
  final int userId;

  const UserAlbumsScreen({
    required this.userId,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => UserAlbumsLoadingBloc(
            albumsRepository: AlbumsRepository(
              albumsRemoteDs: AlbumsRemoteDataSource(
                dio: DependenciesScope.of(context).dio,
              ),
              albumsLocalDs: AlbumsLocalDataSource(
                albumsDao: AppScope.of(context).albumsDao,
              ),
              userId: userId,
            ),
          )..add(const UserAlbumsLoadingEvent.loadNextPage()),
        ),
        BlocProvider(create: (_) => UserAlbumsBloc()),
      ],
      child: BlocListener<UserAlbumsLoadingBloc, UserAlbumsLoadingState>(
        listener: (context, state) {
          state.mapOrNull(
            completed: (state) => context.read<UserAlbumsBloc>().add(UserAlbumsEvent.addData(state.loadedAlbums)),
            failed: (_) => context.read<UserAlbumsBloc>().add(const UserAlbumsEvent.setError()),
          );
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Список альбомов'),
          ),
          body: SafeArea(
            child: BlocBuilder<UserAlbumsBloc, UserAlbumsState>(
              builder: (context, state) {
                return state.map<Widget>(
                  notInitialized: (_) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                  error: (_) {
                    return const Center(
                      child: Text('Произошла ошибка загрузки альбомов'),
                    );
                  },
                  data: (state) {
                    return _AlbumsList(albums: state.albums);
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

class _AlbumsList extends StatelessWidget {
  final List<Album> albums;

  const _AlbumsList({
    required this.albums,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NotificationListener(
      onNotification: (n) {
        // TODO: возможно вместе с ScrollMetricsNotification нужно слушать и другие уведомления, например о соверашющемся скролле
        if (n is ScrollMetricsNotification) {
          if (n.metrics.pixels >= n.metrics.maxScrollExtent * 0.8) {
            context.read<UserAlbumsLoadingBloc>().add(const UserAlbumsLoadingEvent.loadNextPage());
          }
        }
        return false;
      },
      child: ListView.builder(
        itemCount: albums.length,
        itemBuilder: (context, index) {
          final album = albums[index];

          Widget child = ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AlbumInfoScreen(album: album)),
              );
            },
            leading: Text('${album.id}'),
            title: Text(album.title),
          );

          final isLast = index == albums.length - 1;

          if (isLast == false) return child;

          return Column(
            children: <Widget>[
              child,
              BlocBuilder<UserAlbumsLoadingBloc, UserAlbumsLoadingState>(
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
