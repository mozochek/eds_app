import 'package:freezed_annotation/freezed_annotation.dart';

part 'paginated_result.freezed.dart';

@freezed
class PaginatedResult<T> with _$PaginatedResult<T> {
  const PaginatedResult._();

  const factory PaginatedResult({
    required List<T> result,
    required int total,
  }) = _PaginatedResult<T>;


  factory PaginatedResult.empty() => const PaginatedResult(result: [], total: 0);
}
