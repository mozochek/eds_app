import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

@freezed
class User with _$User {
  const User._();

  const factory User({
    required int id,
    required String fullName,
    required String username,
    required String email,
    required String phone,
    required String site,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      fullName: json['name'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      site: json['website'] as String,
    );
  }
}
