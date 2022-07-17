import 'package:freezed_annotation/freezed_annotation.dart';

part 'album.freezed.dart';

@freezed
class Album with _$Album {
  const Album._();

  const factory Album({
    required int id,
    required int userId,
    required String title,
  }) = _Album;

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      id: json['id'] as int,
      userId: json['userId'] as int,
      title: json['title'] as String,
    );
  }
}

@freezed
class AlbumImages with _$AlbumImages {
  const AlbumImages._();

  const factory AlbumImages({
    required int id,
    required String description,
    required String url,
    required String thumbnailUrl,
  }) = _AlbumImages;

  factory AlbumImages.fromJson(Map<String, dynamic> json) {
    return AlbumImages(
      id: json['id'] as int,
      description: json['title'] as String,
      url: json['url'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
    );
  }
}

@freezed
class AlbumFullData with _$AlbumFullData {
  const AlbumFullData._();

  const factory AlbumFullData({
    required Album album,
    required List<AlbumImages> images,
  }) = _AlbumFullData;
}
