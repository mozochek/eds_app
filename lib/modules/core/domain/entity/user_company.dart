import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_company.freezed.dart';

@freezed
class UserCompany with _$UserCompany {
  const UserCompany._();

  const factory UserCompany({
    required String name,
    required String catchPhrase,
    required String bs,
  }) = _UserCompany;

  factory UserCompany.fromJson(Map<String, dynamic> json) {
    return UserCompany(
      name: json['name'] as String,
      catchPhrase: json['catchPhrase'] as String,
      bs: json['bs'] as String,
    );
  }
}
