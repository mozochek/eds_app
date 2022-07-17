import 'package:eds_app/modules/core/domain/entity/post.dart';
import 'package:eds_app/modules/core/domain/entity/user.dart';
import 'package:eds_app/modules/core/domain/entity/user_address.dart';
import 'package:eds_app/modules/core/domain/entity/user_company.dart';
import 'package:eds_app/modules/core/domain/entity/album.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_full_data.freezed.dart';

@freezed
class UserFullData with _$UserFullData {
  const UserFullData._();

  const factory UserFullData({
    required User user,
    required UserCompany company,
    required UserAddress address,
    required List<AlbumFullData> albums,
    required List<Post> posts,
  }) = _UserFullData;
}
