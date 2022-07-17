import 'dart:async';

import 'package:eds_app/modules/core/domain/entity/paginated_result.dart';
import 'package:flutter/foundation.dart';

abstract class IPaginationRepository<T> {
  final int pageSize;

  IPaginationRepository({
    this.pageSize = 30,
  });

  int _currentPage = 1;
  int _returnedFromCache = 0;
  int _returnedFromRemote = 0;
  int? _cacheTotal;
  int? _remoteTotal;

  Future<PaginatedResult<T>> getNextPage() async {
    if (_cacheTotal == null || _cacheTotal! > _returnedFromCache) {
      final fromCache = await getPageFromLocal(_currentPage);

      _cacheTotal = fromCache.total;
      _returnedFromCache += fromCache.result.length;

      if (fromCache.result.length == pageSize) {
        _currentPage++;
      }

      await onPageLoadedFromLocal(fromCache);

      return fromCache;
    }

    if (_remoteTotal == null || _remoteTotal! > _returnedFromCache + _returnedFromRemote) {
      final fromRemote = await getPageFromRemote(_currentPage);

      _remoteTotal = fromRemote.total;
      _returnedFromRemote += fromRemote.result.length;

      await onPageLoadedFromRemote(fromRemote);

      _currentPage++;

      return fromRemote;
    }

    return PaginatedResult.empty();
  }

  @protected
  Future<PaginatedResult<T>> getPageFromRemote(int page);

  @protected
  Future<PaginatedResult<T>> getPageFromLocal(int page);

  @protected
  FutureOr<void> onPageLoadedFromLocal(PaginatedResult<T> page) => SynchronousFuture(null);

  @protected
  FutureOr<void> onPageLoadedFromRemote(PaginatedResult<T> page) => SynchronousFuture(null);
}
