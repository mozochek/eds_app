import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_preview_data.freezed.dart';

@freezed
class UserPreviewData with _$UserPreviewData {
  const UserPreviewData._();

  const factory UserPreviewData({
    required int id,
    required String username,
    required String fullName,
  }) = _UserPreviewData;
}
