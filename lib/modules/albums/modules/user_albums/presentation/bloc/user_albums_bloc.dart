import 'package:eds_app/modules/user/domain/entity/album.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_albums_bloc.freezed.dart';

class UserAlbumsBloc extends Bloc<UserAlbumsEvent, UserAlbumsState> {
  UserAlbumsBloc() : super(const UserAlbumsState.notInitialized()) {
    on<UserAlbumsEvent>((event, emit) {
      event.when(
        addData: (albums) {
          final previousAlbums = state.maybeMap<Set<Album>>(
            data: (state) => state.albums.toSet(),
            orElse: () => <Album>{},
          );

          emit(UserAlbumsState.data(<Album>{...previousAlbums, ...albums}.toList()));
        },
        setError: () {
          state.whenOrNull(
            notInitialized: () {
              emit(const UserAlbumsState.error());
            },
          );
        },
      );
    });
  }
}

@freezed
class UserAlbumsEvent with _$UserAlbumsEvent {
  const UserAlbumsEvent._();

  const factory UserAlbumsEvent.addData(List<Album> albums) = _UserAlbumsEventAddData;

  const factory UserAlbumsEvent.setError() = _UserAlbumsEventSetError;
}

@freezed
class UserAlbumsState with _$UserAlbumsState {
  const UserAlbumsState._();

  const factory UserAlbumsState.notInitialized() = _UserAlbumsStateNotInitialized;

  const factory UserAlbumsState.data(List<Album> albums,
  ) = _UserAlbumsStateData;

  const factory UserAlbumsState.error() = _UserAlbumsStateError;
}
