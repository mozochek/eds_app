import 'package:bloc_concurrency/bloc_concurrency.dart' as bloc_concurrency;
import 'package:eds_app/modules/core/domain/entity/post.dart';
import 'package:eds_app/modules/posts/domain/repository/i_posts_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_posts_loading_bloc.freezed.dart';

class UserPostsLoadingBloc extends Bloc<UserPostsLoadingEvent, UserPostsLoadingState> {
  final IPostsRepository _postsRepository;

  UserPostsLoadingBloc({
    required IPostsRepository postsRepository,
  })  : _postsRepository = postsRepository,
        super(const UserPostsLoadingState.notInitialized()) {
    on<UserPostsLoadingEvent>((event, emit) async {
      await event.when(
        loadNextPage: () async {
          try {
            emit(const UserPostsLoadingState.inProgress());
            final posts = await _postsRepository.getNextPage();
            emit(UserPostsLoadingState.completed(posts.result));
          } on Object {
            emit(const UserPostsLoadingState.failed());
            rethrow;
          }
        },
      );
    }, transformer: bloc_concurrency.droppable());
  }
}

@freezed
class UserPostsLoadingEvent with _$UserPostsLoadingEvent {
  const UserPostsLoadingEvent._();

  const factory UserPostsLoadingEvent.loadNextPage() = _UserPostsLoadingEventLoadNextPage;
}

@freezed
class UserPostsLoadingState with _$UserPostsLoadingState {
  const UserPostsLoadingState._();

  const factory UserPostsLoadingState.notInitialized() = _UserPostsLoadingStateNotInitialized;

  const factory UserPostsLoadingState.inProgress() = _UserPostsLoadingStateInProgress;

  const factory UserPostsLoadingState.completed(List<Post> posts) = _UserPostsLoadingStateCompleted;

  const factory UserPostsLoadingState.failed() = _UserPostsLoadingStateFailed;

  bool get isLoading => maybeMap(
        inProgress: (_) => true,
        orElse: () => false,
      );
}
