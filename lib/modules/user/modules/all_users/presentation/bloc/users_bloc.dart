import 'package:eds_app/modules/user/domain/entity/user_preview_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'users_bloc.freezed.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  UsersBloc() : super(const UsersState.notInitialized()) {
    on<UsersEvent>((event, emit) {
      event.when(
        addData: (users) {
          final previousUsers = state.maybeMap<Set<UserPreviewData>>(
            data: (state) => state.users.toSet(),
            orElse: () => <UserPreviewData>{},
          );

          emit(UsersState.data(<UserPreviewData>{...previousUsers, ...users}.toList()));
        },
        setError: () {
          state.whenOrNull(
            notInitialized: () {
              emit(const UsersState.error());
            },
          );
        },
      );
    });
  }
}

@freezed
class UsersEvent with _$UsersEvent {
  const UsersEvent._();

  const factory UsersEvent.addData(List<UserPreviewData> users) = _UsersEventAddData;

  const factory UsersEvent.setError() = _UsersEventSetError;
}

@freezed
class UsersState with _$UsersState {
  const UsersState._();

  const factory UsersState.notInitialized() = _UsersStateNotInitialized;

  const factory UsersState.data(List<UserPreviewData> users) = _UsersStateData;

  const factory UsersState.error() = _UsersStateError;
}
