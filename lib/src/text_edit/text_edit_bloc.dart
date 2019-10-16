import 'dart:async';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:firebase_abstraction/firebase.dart';
import 'package:seaside_blocs/src/mixins/file_uploader_mixin.dart';
import 'package:seaside_blocs/model/content.dart';
import 'package:seaside_blocs/src/singletons.dart';

import './bloc.dart';

class TextEditBloc extends Bloc<TextEditEvent, TextEditState>
    with FileUploaderMixin<TextEditEvent, TextEditState> {
  TextEditBloc({this.initialContent, FirebaseApp app})
      : this.app = app ?? firebaseApp;
  final Content initialContent;
  final FirebaseApp app;

  @override
  TextEditState get initialState {
    setupFileUploader(
        app: app);
    if (initialContent == null) {
      return TextEditingState(
          type: ContentType.text, date: DateTime.now(), isVisible: false,tags: [],newTags: []);
    } else {
      return TextEditingState.fromContent(initialContent);
    }
  }

  List<String> _deletePhoto(int i) {
    final List<String> photoUrls = currentState.photoUrls;
    photoUrls.removeAt(i);
    return photoUrls;
  }

  List<String> _addPhoto(String url) {
    final List<String> photoUrls = currentState.photoUrls ?? [];
    photoUrls.add(url);
    return photoUrls;
  }

  List<String> _toggleTag(String tag) {
    final List<String> tags = currentState.tags;
    if (tags.contains(tag)) {
      tags.remove(tag);
    } else {
      tags.add(tag);
    }
    return tags;
  }

  List<String>_addTag() {
    final List<String> newTags = currentState.newTags ?? [];
    newTags.add(null);
    return newTags;
  }

  List<String> _editTag(int i, String tag) {
    List<String> newTags = currentState.newTags ?? [];
    newTags[i] = tag;
    return newTags;
  }

  List<String> _removeTag(int i) {
    List<String> newTags = currentState.newTags;
    newTags.removeAt(i);
    return newTags;
  }

  _commit() async {
    final AuthUser user = await app.auth().currentUser;
    final FirestoreDocumentReference ref = app
        .firestore()
        .doc('/texts/' + user.uid)
        .collection('documents')
        .doc(initialContent != null ? initialContent.contentID : null);
    final Content content = currentState.content;
    Map<String, dynamic> toChange = {};
    if (initialContent == null) {
      toChange = content.toData();
    } else {
      if (content.isEmpty) return;
      toChange = Content.getDelta(initialContent, content);
    }
    try {
      if (initialContent == null) {
        if (toChange.isNotEmpty) await ref.set(toChange);
      } else {
        if (toChange.isNotEmpty) await ref.update(toChange);
      }
    } catch (e) {
      print(e);
      throw e;
    }
  }

  _delete() async {
    if (initialContent?.contentID == null || initialContent?.authorID == null)
      return;
    final FirestoreDocumentReference ref = app
        .firestore()
        .doc('/texts/' + initialContent.authorID)
        .collection('documents')
        .doc(initialContent.contentID);
    ref.delete();
  }

  _uploadPhoto(Uint8List bytes, String name) {
    uploadFile(bytes, name,
        onStartUpload: ()=>dispatch(PhotoUploadStartEvent()),
        onUploaded: (String url) => dispatch(PhotoAddedEvent(url)),
        onUploadProgress: (double f) =>
            dispatch(PhotoUploadFractionEvent(f)));
  }

  _uploadMusic(Uint8List bytes, String name) {
    uploadFile(bytes, name,
        onStartUpload: ()=>dispatch(MusicUploadStartEvent()),
        onUploaded: (String url) => dispatch(MusicAddedEvent(url)),
        onUploadProgress: (double f) =>
            dispatch(MusicUploadFractionEvent(f)));
  }

  @override
  Stream<TextEditState> mapEventToState(
    TextEditEvent event,
  ) async* {
    if (event is TagToggledEvent) {
      yield currentState.copyWith(tags: _toggleTag(event.tag));
    }
    if (event is TextChangedEvent) {
      yield currentState.copyWith(text: event.text);
    }
    if (event is TitleChangedEvent) {
      yield currentState.copyWith(title: event.title);
    }
    if (event is DateChangedEvent) {
      yield currentState.copyWith(date: event.date);
    }
    if (event is TypeChangedEvent) {
      yield currentState.copyWith(type: event.type);
    }
    if (event is PhotoUploadEvent) {
      _uploadPhoto(event.bytes, event.name);
    }
    if (event is PhotoDeletedEvent) {
      yield currentState.copyWith(photoUrls: _deletePhoto(event.index));
    }
    if (event is MusicUploadEvent) {
      _uploadMusic(event.bytes, event.name);
    }
    if (event is MusicDeletedEvent) {
      yield currentState.copyWith(musicUrl: null);
    }
    if (event is PhotoAddedEvent) {
      yield currentState.getPureState().copyWith(photoUrls: _addPhoto(event.url));
    }
    if (event is UploadCanceledEvent) {
      cancelUpload();
      yield currentState.getPureState();
    }
    if (event is MusicAddedEvent) {
      yield currentState.getPureState().copyWith(musicUrl: event.url);
    }
    if (event is CommitEvent) {
      _commit();
    }
    if (event is DeleteEvent) {
      _delete();
    }
    if (event is TagAddedEvent) {
      yield currentState.copyWith(newTags: _addTag());
    }
    if (event is TagRemovedEvent) {
      yield currentState.copyWith(newTags: _removeTag(event.index));
    }
    if (event is TagEditedEvent) {
      yield currentState.copyWith(newTags: _editTag(event.index, event.tag));
    }
    if (event is VisibilityChangedEvent) {
      yield currentState.copyWith(isVisible: event.visibility);
    }
    if (event is MusicUploadStartEvent) {
      yield TextEditingUploadingMusicState.fromPure(currentState);
    }
    if (event is PhotoUploadStartEvent) {
      yield TextEditingUploadingPhotoState.fromPure(currentState);
    }

    if (event is UploadFractionEvent) {
      final TextEditState state = currentState;
      if (state is TextEditingUploadingState) {
        yield state.copyWith(fraction: event.fraction);
      } else {
        if (event is MusicUploadFractionEvent) {
          yield TextEditingUploadingMusicState.fromPure(state).copyWith(fraction: event.fraction);
        }
        if (event is PhotoUploadFractionEvent) {
          yield TextEditingUploadingPhotoState.fromPure(state).copyWith(fraction: event.fraction);
        }
      }
    }
  }
}
