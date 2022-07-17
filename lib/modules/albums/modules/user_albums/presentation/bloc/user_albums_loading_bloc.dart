import 'package:bloc_concurrency/bloc_concurrency.dart' as bloc_concurrency;
import 'package:eds_app/modules/albums/domain/repository/i_albums_repository.dart';
import 'package:eds_app/modules/core/domain/entity/album.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_albums_loading_bloc.freezed.dart';

class UserAlbumsLoadingBloc extends Bloc<UserAlbumsLoadingEvent, UserAlbumsLoadingState> {
  final IAlbumsRepository _albumsRepository;

  UserAlbumsLoadingBloc({
    required IAlbumsRepository albumsRepository,
  })  : _albumsRepository = albumsRepository,
        super(const UserAlbumsLoadingState.notInitialized()) {
    on<UserAlbumsLoadingEvent>((event, emit) async {
      await event.when(
        loadNextPage: () async {
          try {
            emit(const UserAlbumsLoadingState.inProgress());
            final albums = await _albumsRepository.getNextPage();
            emit(UserAlbumsLoadingState.completed(albums.result));
          } on Object {
            emit(const UserAlbumsLoadingState.failed());
            rethrow;
          }
        },
      );
    }, transformer: bloc_concurrency.droppable());
  }
}

@freezed
class UserAlbumsLoadingEvent with _$UserAlbumsLoadingEvent {
  const UserAlbumsLoadingEvent._();

  const factory UserAlbumsLoadingEvent.loadNextPage() = _UserAlbumsLoadingEventLoadNextPage;
}

@freezed
class UserAlbumsLoadingState with _$UserAlbumsLoadingState {
  const UserAlbumsLoadingState._();

  const factory UserAlbumsLoadingState.notInitialized() = _UserAlbumsLoadingStateNotInitialized;

  const factory UserAlbumsLoadingState.inProgress() = _UserAlbumsLoadingStateInProgress;

  const factory UserAlbumsLoadingState.completed(List<Album> loadedAlbums) = _UserAlbumsLoadingStateCompleted;

  const factory UserAlbumsLoadingState.failed() = _UserAlbumsLoadingStateFailed;

  bool get isLoading => maybeMap(
        inProgress: (_) => true,
        orElse: () => false,
      );
}
