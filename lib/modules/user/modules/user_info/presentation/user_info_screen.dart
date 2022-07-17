import 'package:eds_app/modules/albums/modules/album_info/presentation/album_info_screen.dart';
import 'package:eds_app/modules/albums/modules/user_albums/presentation/user_albums_screen.dart';
import 'package:eds_app/modules/app_scope.dart';
import 'package:eds_app/modules/core/domain/entity/user_full_data.dart';
import 'package:eds_app/modules/posts/user_posts_screen.dart';
import 'package:eds_app/modules/user/domain/entity/user_preview_data.dart';
import 'package:eds_app/modules/user/modules/user_info/presentation/bloc/user_info_loading_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserInfoScreen extends StatelessWidget {
  final UserPreviewData userPreviewData;

  const UserInfoScreen({
    required this.userPreviewData,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserInfoLoadingBloc(
        previewData: userPreviewData,
        userRepository: AppScope.of(context).userRepository,
      )..add(const UserInfoLoadingEvent.load()),
      child: Scaffold(
        appBar: AppBar(
          title: BlocBuilder<UserInfoLoadingBloc, UserInfoLoadingState>(
            buildWhen: (prev, curr) => prev.username != curr.username,
            builder: (context, state) {
              return Text(state.username);
            },
          ),
        ),
        body: SafeArea(
          child: Center(
            child: BlocBuilder<UserInfoLoadingBloc, UserInfoLoadingState>(
              builder: (context, state) {
                return state.maybeMap<Widget>(
                  orElse: () {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                  failed: (_) {
                    return const Center(
                      child: Text('Не удалось загрузить информацию о пользователе'),
                    );
                  },
                  completed: (state) {
                    return _UserDataDisplay(userData: state.loadedData);
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

class _UserDataDisplay extends StatelessWidget {
  final UserFullData userData;

  const _UserDataDisplay({
    required this.userData,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = userData.user;
    final company = userData.company;
    final address = userData.address;
    final albumsData = userData.albums;

    // TODO: l10n
    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Имя: ${user.fullName}'),
                const SizedBox(height: 16.0),
                Text('Email: ${user.email}'),
                const SizedBox(height: 16.0),
                Text('Номер телефона: ${user.phone}'),
                const SizedBox(height: 16.0),
                Text('Адрес: ${address.zipCode}, ${address.city}, ${address.street}, ${address.suite}'),
                const SizedBox(height: 16.0),
                Text('Сайт: ${user.site}'),
                const SizedBox(height: 16.0),
                const Text('Компания:'),
                const SizedBox(height: 16.0),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text('Название: ${company.name}'),
                ),
                const SizedBox(height: 16.0),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text('Bs: ${company.bs}'),
                ),
                const SizedBox(height: 16.0),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: RichText(
                    text: TextSpan(
                      text: 'Крылатая фраза: ',
                      children: <InlineSpan>[
                        TextSpan(
                          text: company.catchPhrase,
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
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: <Widget>[
                    const Text('Альбомы'),
                    const Expanded(
                      child: SizedBox(width: 8.0),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => UserAlbumsScreen(userId: userData.user.id)),
                        );
                      },
                      child: const Text('Посмотреть все'),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                SizedBox(
                  height: 64.0,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: albumsData.take(3).map((albumData) {
                      final album = albumData.album;

                      return Expanded(
                        child: SizedBox(
                          height: 64.0,
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => AlbumInfoScreen(album: album)),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2.0),
                              child: Text(
                                '${album.id}. ${album.title}',
                                overflow: TextOverflow.fade,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const UserPostsScreen()),
                    );
                  },
                  child: const Text('Все посты'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
