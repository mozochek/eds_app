import 'package:eds_app/modules/albums/modules/album_info/presentation/album_info_screen.dart';
import 'package:eds_app/modules/albums/modules/user_albums/presentation/bloc/user_albums_bloc.dart';
import 'package:eds_app/modules/albums/modules/user_albums/presentation/bloc/user_albums_loading_bloc.dart';
import 'package:eds_app/modules/albums/modules/user_albums/presentation/user_albums_screen_scope.dart';
import 'package:eds_app/modules/core/domain/entity/album.dart';
import 'package:eds_app/modules/core/presentation/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);

    return UserAlbumsScreenScope(
      userId: userId,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.albumsList),
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
                  return Center(
                    child: Text(l10n.albumsListError),
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
    );
  }
}

class _AlbumsList extends StatefulWidget {
  final List<Album> albums;

  const _AlbumsList({
    required this.albums,
    Key? key,
  }) : super(key: key);

  @override
  State<_AlbumsList> createState() => _AlbumsListState();
}

class _AlbumsListState extends State<_AlbumsList> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
  }

  @override
  void didUpdateWidget(covariant _AlbumsList oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.albums != widget.albums) {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
        context.read<UserAlbumsLoadingBloc>().add(const UserAlbumsLoadingEvent.loadNextPage());
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
            context.read<UserAlbumsLoadingBloc>().add(const UserAlbumsLoadingEvent.loadNextPage());
          }
        }
        return false;
      },
      child: ListView.builder(
        controller: _scrollController,
        itemCount: widget.albums.length,
        itemBuilder: (context, index) {
          final album = widget.albums[index];

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

          final isLast = index == widget.albums.length - 1;

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
