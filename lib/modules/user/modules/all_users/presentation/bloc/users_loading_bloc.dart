import 'package:bloc_concurrency/bloc_concurrency.dart' as bloc_concurrency;
import 'package:eds_app/modules/user/domain/entity/user_preview_data.dart';
import 'package:eds_app/modules/user/domain/repository/i_user_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'users_loading_bloc.freezed.dart';

class UsersLoadingBloc extends Bloc<UsersLoadingEvent, UsersLoadingState> {
  final IUserRepository _userRepo;

  UsersLoadingBloc({
    required IUserRepository userRepository,
  })  : _userRepo = userRepository,
        super(const UsersLoadingState.notInitialized()) {
    on<UsersLoadingEvent>((event, emit) async {
      try {
        emit(const UsersLoadingState.inProgress());

        final users = await _userRepo.getUsers();
        if (users != null) {
          final result = users
              .map((u) => UserPreviewData(
                    id: u.id,
                    username: u.username,
                    fullName: u.fullName,
                  ))
              .toList();
          emit(UsersLoadingState.completed(result));
          return;
        }

        emit(const UsersLoadingState.failed());
      } on Object {
        emit(const UsersLoadingState.failed());
        rethrow;
      }
    }, transformer: bloc_concurrency.droppable());
  }
}

@freezed
class UsersLoadingEvent with _$UsersLoadingEvent {
  const UsersLoadingEvent._();

  const factory UsersLoadingEvent.load() = _UsersLoadingEventLoad;
}

@freezed
class UsersLoadingState with _$UsersLoadingState {
  const UsersLoadingState._();

  const factory UsersLoadingState.notInitialized() = _UsersLoadingStateNotInitialized;

  const factory UsersLoadingState.inProgress() = _UsersLoadingStateInProgress;

  const factory UsersLoadingState.completed(
    List<UserPreviewData> users,
  ) = _UsersLoadingStateCompleted;

  const factory UsersLoadingState.failed() = _UsersLoadingStateFailed;
}
