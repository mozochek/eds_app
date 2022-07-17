import 'package:eds_app/modules/albums/data/data_source/albums_local_data_source.dart';
import 'package:eds_app/modules/albums/data/data_source/albums_remote_data_source.dart';
import 'package:eds_app/modules/albums/data/repository/albums_repository.dart';
import 'package:eds_app/modules/albums/modules/album_info/presentation/bloc/album_info_loading_bloc.dart';
import 'package:eds_app/modules/core/domain/entity/album.dart';
import 'package:eds_app/modules/core/presentation/dependencies_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AlbumInfoScreenScope extends StatelessWidget {
  final Album album;
  final Widget child;

  const AlbumInfoScreenScope({
    required this.album,
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final store = DependenciesScope.of(context);

        return AlbumInfoLoadingBloc(
          initData: album,
          albumsRepository: AlbumsRepository(
            userId: album.userId,
            albumsRemoteDs: AlbumsRemoteDataSource(
              dio: store.dio,
            ),
            albumsLocalDs: AlbumsLocalDataSource(
              albumsDao: store.database.albumsDao,
            ),
          ),
        )..add(const AlbumInfoLoadingEvent.load());
      },
      child: child,
    );
  }
}
