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
      _bio = initialAuthor.bio;
      _name = initialAuthor.name;
      _photoUrl = initialAuthor.imgUrl;
      _isVisible = initialAuthor.isVisible;
      return AuthorEditingState(_name, _bio, _photoUrl, _isVisible);
    }
  }

  _grabUserPic() async {
    AuthUser user = await app.auth().currentUser;
    dispatch(PhotoChangeEvent(user.photoURL));
  }

  String _bio;
  String _name;
  String _photoUrl;
  bool _isVisible;

  _commit() async {
    final AuthUser user = await app.auth().currentUser;
    final FirestoreDocumentReference ref =
        app.firestore().doc('/texts/' + user.uid);
    AuthUserProfile info = AuthUserProfile();
    if (_name != null) info.displayName = _name;
    if (_photoUrl != null) info.photoUrl = _photoUrl;
    Map<String, dynamic> toChange = {};
    if (_bio != null) toChange['bio'] = _bio;
    if (_name != null) toChange['authorName'] = _name;
    if (_photoUrl != null) toChange['imgUrl'] = _photoUrl;
    if (_isVisible != null) toChange['isVisible'] = _isVisible;
    try {
      if (info.photoUrl != null || info.displayName != null)
        await user.updateProfile(info);
      if (toChange.isNotEmpty) await ref.set(toChange);
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

  _changeVisibility(bool visibility) {
    _isVisible = visibility;
  }

  @override
  Stream<AuthorEditState> mapEventToState(
    AuthorEditEvent event,
  ) async* {
    if (event is PhotoUploadEvent) {
      uploadFile(event.bytes, event.name);
    }
    if (event is PhotoChangeEvent) {
      _photoUrl = event.url;
    }
    if (event is BioChangedEvent) {
      _bio = event.bio;
    }
    if (event is NameChangedEvent) {
      _name = event.name;
    }
    if (event is CommitEvent) {
      _commit();
    }
    if (event is PhotoUploadCancelEvent) {
      cancelUpload();
    }

    if (event is AuthorDeleteEvent) {
      cancelUpload();
      _delete();
    }

    if (event is VisibilityChangedEvent) {
      _changeVisibility(event.visibility);
    }

    if (event is PhotoUploadFractionEvent) {
      yield AuthorEditingUploadingState(
          _name, _bio, _photoUrl, _isVisible, event.fraction);
    } else {
      yield AuthorEditingState(_name, _bio, _photoUrl, _isVisible);
    }
  }
}
