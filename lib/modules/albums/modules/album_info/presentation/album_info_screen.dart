import 'package:cached_network_image/cached_network_image.dart';
import 'package:eds_app/modules/albums/data/data_source/albums_local_data_source.dart';
import 'package:eds_app/modules/albums/data/data_source/albums_remote_data_source.dart';
import 'package:eds_app/modules/albums/data/repository/albums_repository.dart';
import 'package:eds_app/modules/albums/modules/album_info/presentation/bloc/album_info_loading_bloc.dart';
import 'package:eds_app/modules/app_scope.dart';
import 'package:eds_app/modules/core/domain/entity/album.dart';
import 'package:eds_app/modules/dependencies_scope.dart';
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
          userId: album.userId,
          albumsRemoteDs: AlbumsRemoteDataSource(
            dio: DependenciesScope.of(context).dio,
          ),
          albumsLocalDs: AlbumsLocalDataSource(
            albumsDao: AppScope.of(context).albumsDao,
          ),
        ),
      )..add(const AlbumInfoLoadingEvent.load()),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Альбом: ${album.title}'),
        ),
        body: SafeArea(
          child: BlocBuilder<AlbumInfoLoadingBloc, AlbumInfoLoadingState>(
            builder: (context, state) {
              return state.maybeMap<Widget>(
                orElse: () {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
                failed: (_) {
                  return const Center(
                    child: Text('Не удалось загрузить информацию альбома'),
                  );
                },
                completed: (state) {
                  return _AlbumDataWidget(data: state.loadedData);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AlbumDataWidget extends StatelessWidget {
  final AlbumFullData data;

  const _AlbumDataWidget({
    required this.data,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageSide = MediaQuery.of(context).size.shortestSide;

    return Column(
      children: <Widget>[
        Expanded(
          child: PageView.builder(
            itemCount: data.images.length,
            itemBuilder: (context, index) {
              final imageData = data.images[index];

              return Column(
                children: <Widget>[
                  SizedBox(
                    width: imageSide,
                    height: imageSide,
                    child: CachedNetworkImage(
                      imageUrl: imageData.url,
                      fit: BoxFit.fill,
                      errorWidget: (context, _, __) {
                        return const Center(
                          child: Text('Не удалось получить изображение'),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: <Widget>[
                        Text('Изображение №${imageData.id}'),
                        const SizedBox(height: 8.0),
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text: 'Описание: ',
                            children: <InlineSpan>[
                              TextSpan(
                                text: imageData.description,
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
