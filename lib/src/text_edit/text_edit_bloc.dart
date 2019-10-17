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
    final List<String> photoUrls = state.photoUrls;
    photoUrls.removeAt(i);
    return photoUrls;
  }

  List<String> _addPhoto(String url) {
    final List<String> photoUrls = state.photoUrls ?? [];
    photoUrls.add(url);
    return photoUrls;
  }

  List<String> _toggleTag(String tag) {
    final List<String> tags = state.tags;
    if (tags.contains(tag)) {
      tags.remove(tag);
    } else {
      tags.add(tag);
    }
    return tags;
  }

  List<String>_addTag() {
    final List<String> newTags = state.newTags ?? [];
    newTags.add(null);
    return newTags;
  }

  List<String> _editTag(int i, String tag) {
    List<String> newTags = state.newTags ?? [];
    newTags[i] = tag;
    return newTags;
  }

  List<String> _removeTag(int i) {
    List<String> newTags = state.newTags;
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
    final Content content = state.content;
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
    print(event.toString());
    if (event is TagToggledEvent) {
      yield state.copyWith(tags: _toggleTag(event.tag));
    }
    if (event is TextChangedEvent) {
      yield state.copyWith(text: event.text);
    }
    if (event is TitleChangedEvent) {
      yield state.copyWith(title: event.title);
    }
    if (event is DateChangedEvent) {
      yield state.copyWith(date: event.date);
    }
    if (event is TypeChangedEvent) {
      yield state.copyWith(type: event.type);
    }
    if (event is PhotoUploadEvent) {
      _uploadPhoto(event.bytes, event.name);
    }
    if (event is PhotoDeletedEvent) {
      yield state.copyWith(photoUrls: _deletePhoto(event.index));
    }
    if (event is MusicUploadEvent) {
      _uploadMusic(event.bytes, event.name);
    }
    if (event is MusicDeletedEvent) {
      yield state.copyWithNoMusic();
    }
    if (event is PhotoAddedEvent) {
      yield state.getPureState().copyWith(photoUrls: _addPhoto(event.url));
    }
    if (event is UploadCanceledEvent) {
      cancelUpload();
      yield state.getPureState();
    }
    if (event is MusicAddedEvent) {
      yield state.getPureState().copyWith(musicUrl: event.url);
    }
    if (event is CommitEvent) {
      _commit();
    }
    if (event is DeleteEvent) {
      _delete();
    }
    if (event is TagAddedEvent) {
      yield state.copyWith(newTags: _addTag());
    }
    if (event is TagRemovedEvent) {
      yield state.copyWith(newTags: _removeTag(event.index));
    }
    if (event is TagEditedEvent) {
      yield state.copyWith(newTags: _editTag(event.index, event.tag));
    }
    if (event is VisibilityChangedEvent) {
      yield state.copyWith(isVisible: event.visibility);
    }
    if (event is MusicUploadStartEvent) {
      yield TextEditingUploadingMusicState.fromPure(state);
    }
    if (event is PhotoUploadStartEvent) {
      yield TextEditingUploadingPhotoState.fromPure(state);
    }

    if (event is UploadFractionEvent) {
      final TextEditState currentState = state;
      if (currentState is TextEditingUploadingState) {
        yield currentState.copyWith(fraction: event.fraction);
      } else {
        if (event is MusicUploadFractionEvent) {
          yield TextEditingUploadingMusicState.fromPure(currentState).copyWith(fraction: event.fraction);
        }
        if (event is PhotoUploadFractionEvent) {
          yield TextEditingUploadingPhotoState.fromPure(currentState).copyWith(fraction: event.fraction);
        }
      }
    }
  }
}
