import 'package:cached_network_image/cached_network_image.dart';
import 'package:eds_app/modules/albums/modules/album_info/presentation/album_info_screen.dart';
import 'package:eds_app/modules/albums/modules/user_albums/presentation/user_albums_screen.dart';
import 'package:eds_app/modules/core/domain/entity/user_full_data.dart';
import 'package:eds_app/modules/core/presentation/l10n/app_localizations.dart';
import 'package:eds_app/modules/posts/modules/user_posts/presentation/user_posts_screen.dart';
import 'package:eds_app/modules/user/domain/entity/user_preview_data.dart';
import 'package:eds_app/modules/user/modules/user_info/presentation/bloc/user_info_loading_bloc.dart';
import 'package:eds_app/modules/user/modules/user_info/presentation/user_info_screen_scope.dart';
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
    return UserInfoScreenScope(
      userPreviewData: userPreviewData,
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
                    return Center(
                      child: Text(AppLocalizations.of(context).userInfoError),
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
    final l10n = AppLocalizations.of(context);
    final user = userData.user;
    final company = userData.company;
    final address = userData.address;
    final albumsData = userData.albums;
    final posts = userData.posts;

    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('${l10n.fullName}: ${user.fullName}'),
                    const SizedBox(height: 16.0),
                    Text('${l10n.email}: ${user.email}'),
                    const SizedBox(height: 16.0),
                    Text('${l10n.phoneNumber}: ${user.phone}'),
                    const SizedBox(height: 16.0),
                    Text('${l10n.address}: ${address.zipCode}, ${address.city}, ${address.street}, ${address.suite}'),
                    const SizedBox(height: 16.0),
                    Text('${l10n.site}: ${user.site}'),
                    const SizedBox(height: 16.0),
                    Text('${l10n.company}:'),
                    const SizedBox(height: 16.0),
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Text('${l10n.companyName}: ${company.name}'),
                    ),
                    const SizedBox(height: 16.0),
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Text('${l10n.bs}: ${company.bs}'),
                    ),
                    const SizedBox(height: 16.0),
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: RichText(
                        text: TextSpan(
                          text: '${l10n.catchPhrase}: ',
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
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: <Widget>[
                    Text(l10n.albums),
                    const Expanded(
                      child: SizedBox(width: 8.0),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => UserAlbumsScreen(userId: userData.user.id)),
                        );
                      },
                      child: Text(
                        l10n.viewAll,
                        style: const TextStyle(
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8.0),
              ...albumsData.take(3).map((data) {
                final album = data.album;

                return ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AlbumInfoScreen(album: album)),
                    );
                  },
                  leading: SizedBox(
                    width: 64.0,
                    height: 64.0,
                    child: CachedNetworkImage(
                      imageUrl: data.images.first.thumbnailUrl,
                      fit: BoxFit.fill,
                    ),
                  ),
                  title: Text(album.title),
                  trailing: Text('${album.id}'),
                );
              }),
              const SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: <Widget>[
                    Text(l10n.posts),
                    const Expanded(
                      child: SizedBox(width: 8.0),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => UserPostsScreen(userId: userData.user.id)),
                        );
                      },
                      child: Text(
                        l10n.viewAll,
                        style: const TextStyle(
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8.0),
              ...posts.take(3).map((post) {
                return ListTile(
                  onTap: () {},
                  leading: Text('${post.id}'),
                  title: Text(post.title),
                  subtitle: Text(
                    post.body,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ],
    );
  }
}
