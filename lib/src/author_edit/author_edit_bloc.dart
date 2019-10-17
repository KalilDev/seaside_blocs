import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_abstraction/firebase.dart';
import 'package:seaside_blocs/src/mixins/file_uploader_mixin.dart';
import 'package:seaside_blocs/model/author.dart';
import 'package:seaside_blocs/src/singletons.dart';

import './bloc.dart';

class AuthorEditBloc extends Bloc<AuthorEditEvent, AuthorEditState>
    with FileUploaderMixin<AuthorEditEvent, AuthorEditState> {
  AuthorEditBloc({this.initialAuthor, FirebaseApp app})
      : this.app = app ?? firebaseApp;
  final Author initialAuthor;
  final FirebaseApp app;
  @override
  AuthorEditState get initialState {
    setupFileUploader(
        app: app,
        onUploadProgress: (double progress) =>
            dispatch(PhotoUploadFractionEvent(progress)),
        onStartUpload: () => dispatch(PhotoChangeEvent()),
        onUploaded: (String s) => dispatch(PhotoChangeEvent(s)));
    if (initialAuthor == null) {
      _grabUserPic();
      return AuthorEditingState();
    } else {
      return AuthorEditingState(name: initialAuthor.name, bio: initialAuthor.bio, photoUrl: initialAuthor.imgUrl, isVisible: initialAuthor.isVisible);
    }
  }

  _grabUserPic() async {
    AuthUser user = await app.auth().currentUser;
    dispatch(PhotoChangeEvent(user.photoURL));
  }

  _commit() async {
    final AuthUser user = await app.auth().currentUser;
    final FirestoreDocumentReference ref =
        app.firestore().doc('/texts/' + user.uid);
    AuthUserProfile info = AuthUserProfile();
    Map<String, dynamic> toChange;
    if (initialAuthor == null) {
      toChange = state.author.toData();
    } else {
      toChange = Author.getDelta(initialAuthor, state.author);
    }
    if (toChange['authorName'] != null) info.displayName = toChange['authorName'];
    if (toChange['imgUrl'] != null) info.photoUrl = toChange['imgUrl'];

    try {
      if (toChange['authorName'] != null || toChange['imgUrl'] != null)
        await user.updateProfile(info);
      if (toChange.isNotEmpty) {
        if (initialAuthor != null) {
          await ref.update(toChange);
        } else {
          await ref.set(toChange);
        }
      }
    } catch (e) {
      print(e ?? 'EXCEPTION ON EDIT');
    }
  }

  _delete() async {
    final AuthUser user = await app.auth().currentUser;
    final FirestoreDocumentReference ref =
        app.firestore().doc('/texts/' + user.uid);
    try {
      ref.delete();
    } catch (e) {
      throw e;
    }
  }

  @override
  Stream<AuthorEditState> mapEventToState(
    AuthorEditEvent event,
  ) async* {
    if (event is PhotoUploadEvent) {
      uploadFile(event.bytes, event.name);
    }
    if (event is PhotoChangeEvent) {
      yield state.copyWith(photoUrl: event.url);
    }
    if (event is BioChangedEvent) {
      yield state.copyWith(bio: event.bio);
    }
    if (event is NameChangedEvent) {
      yield state.copyWith(name: event.name);
    }
    if (event is CommitEvent) {
      _commit();
    }
    if (event is PhotoUploadCancelEvent) {
      cancelUpload();
      yield state.getPureState();
    }

    if (event is AuthorDeleteEvent) {
      cancelUpload();
      _delete();
    }

    if (event is VisibilityChangedEvent) {
      yield state.copyWith(isVisible: event.visibility);
    }

    if (event is PhotoUploadFractionEvent) {
      final AuthorEditState currentState = state;
      if (currentState is AuthorEditingUploadingState) {
        yield currentState.copyWith(fraction: event.fraction);
      } else {
        yield AuthorEditingUploadingState.fromPure(currentState).copyWith(fraction: event.fraction);
      }
    }
  }
}
