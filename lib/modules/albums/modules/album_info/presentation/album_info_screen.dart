import 'package:eds_app/modules/albums/data/data_source/albums_local_data_source.dart';
import 'package:eds_app/modules/albums/data/data_source/albums_remote_data_source.dart';
import 'package:eds_app/modules/albums/data/repository/albums_repository.dart';
import 'package:eds_app/modules/albums/modules/album_info/presentation/bloc/album_info_loading_bloc.dart';
import 'package:eds_app/modules/app_scope.dart';
import 'package:eds_app/modules/dependencies_scope.dart';
import 'package:eds_app/modules/user/domain/entity/album.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AlbumInfoScreen extends StatelessWidget {
  final Album album;

  const AlbumInfoScreen({
    required this.album,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AlbumInfoLoadingBloc(
        initData: album,
        albumsRepository: AlbumsRepository(
          albumsRemoteDs: AlbumsRemoteDataSource(
            dio: DependenciesScope.of(context).dio,
          ),
          albumsLocalDs: AlbumsLocalDataSource(
            albumsDao: AppScope.of(context).albumsDao,
          ),
          userId: album.userId,
        ),
      )..add(const AlbumInfoLoadingEvent.load()),
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<AlbumInfoLoadingBloc, AlbumInfoLoadingState>(
            builder: (context, state) {
              return Center(
                child: Text('$state'),
              );
            },
          ),
        ),
      ),
    );
  }
}
