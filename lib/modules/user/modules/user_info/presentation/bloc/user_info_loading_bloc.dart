import 'package:bloc_concurrency/bloc_concurrency.dart' as bloc_concurrency;
import 'package:eds_app/modules/core/domain/entity/user_full_data.dart';
import 'package:eds_app/modules/user/domain/entity/user_preview_data.dart';
import 'package:eds_app/modules/user/domain/repository/i_user_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_info_loading_bloc.freezed.dart';

class UserInfoLoadingBloc extends Bloc<UserInfoLoadingEvent, UserInfoLoadingState> {
  final IUserRepository _userRepository;

  UserInfoLoadingBloc({
    required UserPreviewData previewData,
    required IUserRepository userRepository,
  })  : _userRepository = userRepository,
        super(UserInfoLoadingState.notInitialized(previewData)) {
    on<UserInfoLoadingEvent>((event, emit) async {
      await event.when(
        load: () async {
          try {
            final initData = state.initData;
            emit(UserInfoLoadingState.inProgress(initData));

            final loadedData = await _userRepository.getUserFullData(initData.id);
            if (loadedData != null) {
              emit(UserInfoLoadingState.completed(initData, loadedData));
              return;
            }

            emit(UserInfoLoadingState.failed(initData));
          } on Object {
            emit(UserInfoLoadingState.failed(state.initData));
            rethrow;
          }
        },
      );
    }, transformer: bloc_concurrency.droppable());
  }
}

@freezed
class UserInfoLoadingEvent with _$UserInfoLoadingEvent {
  const UserInfoLoadingEvent._();

  const factory UserInfoLoadingEvent.load() = _UserInfoLoadingEventLoad;
}

@freezed
class UserInfoLoadingState with _$UserInfoLoadingState {
  const UserInfoLoadingState._();

  const factory UserInfoLoadingState.notInitialized(UserPreviewData initData) = _UserInfoLoadingStateNotInitialized;

  const factory UserInfoLoadingState.inProgress(UserPreviewData initData) = _UserInfoLoadingStateInProgress;

  const factory UserInfoLoadingState.completed(
    UserPreviewData initData,
    UserFullData loadedData,
  ) = _UserInfoLoadingStateCompleted;

  const factory UserInfoLoadingState.failed(UserPreviewData initData) = _UserInfoLoadingStateFailed;

  String get username => maybeMap(
        orElse: () => initData.username,
        completed: (state) => state.loadedData.user.username,
      );
}
