import 'package:eds_app/modules/core/domain/entity/lat_long.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_address.freezed.dart';

@freezed
class UserAddress with _$UserAddress {
  const UserAddress._();

  const factory UserAddress({
    required String street,
    required String suite,
    required String city,
    required String zipCode,
    required LatLong coords,
  }) = _UserAddress;

  factory UserAddress.fromJson(Map<String, dynamic> json) {
    return UserAddress(
      street: json['street'] as String,
      suite: json['suite'] as String,
      city: json['city'] as String,
      zipCode: json['zipcode'] as String,
      coords: LatLong(
        lat: double.parse(json['geo']['lat'] as String),
        lng: double.parse(json['geo']['lng'] as String),
      ),
    );
  }
}
