import 'package:eds_app/modules/core/domain/entity/post.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_posts_bloc.freezed.dart';

class UserPostsBloc extends Bloc<UserPostsEvent, UserPostsState> {
  UserPostsBloc() : super(const UserPostsState.notInitialized()) {
    on<UserPostsEvent>((event, emit) {
      event.when(
        addData: (posts) {
          final previousPosts = state.maybeMap<Set<Post>>(
            data: (state) => state.posts.toSet(),
            orElse: () => <Post>{},
          );

          emit(UserPostsState.data({...previousPosts, ...posts}.toList()));
        },
        setError: () {
          state.whenOrNull(
            notInitialized: () {
              emit(const UserPostsState.error());
            },
          );
        },
      );
    });
  }
}

@freezed
class UserPostsEvent with _$UserPostsEvent {
  const UserPostsEvent._();

  const factory UserPostsEvent.addData(List<Post> posts) = _UserPostsEventAddData;

  const factory UserPostsEvent.setError() = _UserPostsEventSetError;
}

@freezed
class UserPostsState with _$UserPostsState {
  const UserPostsState._();

  const factory UserPostsState.notInitialized() = _UserPostsStateNotInitialized;

  const factory UserPostsState.data(List<Post> posts) = _UserPostsStateData;

  const factory UserPostsState.error() = _UserPostsStateError;
}
