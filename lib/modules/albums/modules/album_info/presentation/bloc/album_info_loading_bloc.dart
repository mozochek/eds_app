import 'package:eds_app/modules/albums/domain/repository/i_albums_repository.dart';
import 'package:eds_app/modules/user/domain/entity/album.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'album_info_loading_bloc.freezed.dart';

class AlbumInfoLoadingBloc extends Bloc<AlbumInfoLoadingEvent, AlbumInfoLoadingState> {
  final IAlbumsRepository _albumsRepository;

  AlbumInfoLoadingBloc({
    required Album initData,
    required IAlbumsRepository albumsRepository,
  })  : _albumsRepository = albumsRepository,
        super(AlbumInfoLoadingState.notInitialized(initData)) {
    on<AlbumInfoLoadingEvent>((event, emit) async {
      await event.when(
        load: () async {
          try {
            emit(AlbumInfoLoadingState.inProgress(initData));
            final loadedData = await _albumsRepository.getAlbumFullData(state.initData.id);

            if (loadedData != null) {
              emit(AlbumInfoLoadingState.completed(initData, loadedData));
              return;
            }

            emit(AlbumInfoLoadingState.failed(initData));
          } on Object {
            emit(AlbumInfoLoadingState.failed(initData));
            rethrow;
          }
        },
      );
    });
  }
}

@freezed
class AlbumInfoLoadingEvent with _$AlbumInfoLoadingEvent {
  const AlbumInfoLoadingEvent._();

  const factory AlbumInfoLoadingEvent.load() = _AlbumInfoLoadingEventLoad;
}

@freezed
class AlbumInfoLoadingState with _$AlbumInfoLoadingState {
  const AlbumInfoLoadingState._();

  const factory AlbumInfoLoadingState.notInitialized(Album initData) = _AlbumInfoLoadingStateNotInitialized;

  const factory AlbumInfoLoadingState.inProgress(Album initData) = _AlbumInfoLoadingStateInProgress;

  const factory AlbumInfoLoadingState.completed(
    Album initData,
    AlbumFullData loadedData,
  ) = _AlbumInfoLoadingStateCompleted;

  const factory AlbumInfoLoadingState.failed(Album initData) = _AlbumInfoLoadingStateFailed;
}
