import 'package:freezed_annotation/freezed_annotation.dart';

part 'lat_long.freezed.dart';

@freezed
class LatLong with _$LatLong {
  const LatLong._();

  const factory LatLong({
    required double lat,
    required double lng,
  }) = _LatLong;
}
