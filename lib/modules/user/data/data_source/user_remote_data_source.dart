import 'package:dio/dio.dart';
import 'package:eds_app/modules/core/domain/entity/user.dart';
import 'package:eds_app/modules/core/domain/entity/user_address.dart';
import 'package:eds_app/modules/core/domain/entity/user_company.dart';
import 'package:eds_app/modules/core/domain/entity/user_full_data.dart';
import 'package:eds_app/modules/user/data/data_source/i_user_data_source.dart';
import 'package:eds_app/modules/user/domain/entity/album.dart';

abstract class IUserRemoteDataSource implements IUserDataSource {}

class UserRemoteDataSource implements IUserRemoteDataSource {
  final Dio _dio;

  UserRemoteDataSource({
    required Dio dio,
  }) : _dio = dio;

  @override
  Future<List<User>?> getUsers() async {
    final response = await _dio.get('users');

    final data = response.data;

    if (data == null || data is! List) return null;

    return data.map((e) => User.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<UserFullData?> getUserFullData(int userId) async {
    final userData = (await _dio.get<Map<String, dynamic>>('users/$userId')).data;

    if (userData == null) return null;

    final user = User.fromJson(userData);

    final userAlbums = await _getThreeAlbumsPreviewsForUser(userId);

    if (userAlbums == null) return null;

    return UserFullData(
      user: user,
      company: UserCompany.fromJson(userData['company'] as Map<String, dynamic>),
      address: UserAddress.fromJson(userData['address'] as Map<String, dynamic>),
      albums: userAlbums,
    );
  }

  Future<List<AlbumFullData>?> _getThreeAlbumsPreviewsForUser(int userId) async {
    final albumsData = (await _dio.get(
      'users/$userId/albums',
      queryParameters: <String, dynamic>{
        '_page': 1,
        '_limit': 3,
        '_embed': 'photos',
      },
    ))
        .data;

    if (albumsData == null || albumsData is! List) return null;

    final result = <AlbumFullData>[];

    for (final albumJson in albumsData) {
      final album = Album.fromJson(albumJson);
      final images = (albumJson['photos'] as List).map((imgJson) => AlbumImages.fromJson(imgJson)).toList();
      result.add(AlbumFullData(album: album, images: images));
    }

    return result;
  }
}
