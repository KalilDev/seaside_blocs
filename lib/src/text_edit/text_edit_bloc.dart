import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_abstraction/firebase.dart';
import 'package:seaside_blocs/src/mixins/file_uploader_mixin.dart';
import 'package:seaside_blocs/model/content.dart';
import 'package:tuple/tuple.dart';
import 'package:seaside_blocs/src/singletons.dart';

import './bloc.dart';

class TextEditBloc extends Bloc<TextEditEvent, TextEditState>
    with FileUploaderMixin<TextEditEvent, TextEditState> {
  TextEditBloc({this.initialContent, FirebaseApp app})
      : this.app = app ?? firebaseApp;
  final Content initialContent;
  final FirebaseApp app;

  String title;
  String text;
  List<String> photoUrls;
  List<String> tags = [];
  List<String> newTags = [];
  ContentType type = ContentType.text;
  DateTime date = DateTime.now();
  bool isVisible = false;
  String music;
  Tuple2<double, bool> uploadStatus;

  @override
  TextEditState get initialState {
    setupFileUploader(
        app: app,
        onUploadProgress: (double progress) =>
            dispatch(PhotoUploadFractionEvent(progress)),
        onStartUpload: null,
        onUploaded: (String s) => dispatch(PhotoAddedEvent(s)));
    if (initialContent == null) {
      return TextEditingState(
          type: ContentType.text, date: date, isVisible: false);
    } else {
      title = initialContent.title;
      text = initialContent.text?.replaceAll('^NL', '\n');
      photoUrls = initialContent.imageUrl is String
          ? [initialContent.imageUrl]
          : initialContent.imageUrl;
      tags = initialContent.tags ?? [];
      type = initialContent.type;
      date = initialContent.date == null
          ? DateTime.now()
          : DateTime.parse(initialContent.date);
      music = initialContent.music;
      isVisible = initialContent.isVisible ?? false;
      return TextEditingState.fromContent(initialContent);
    }
  }

  _deletePhoto(int i) {
    photoUrls.removeAt(i);
  }

  _addPhoto(String url) {
    if (photoUrls == null) photoUrls = List();
    photoUrls.add(url);
  }

  _addMusic(String url) {
    music = url;
  }

  _toggleTag(String tag) {
    if (tags.contains(tag)) {
      tags.remove(tag);
    } else {
      tags.add(tag);
    }
  }

  _changeText(String text) {
    this.text = text;
  }

  _changeTitle(String title) {
    this.title = title;
  }

  _changeDate(DateTime date) {
    if (date != null) this.date = date;
  }

  _changeType(ContentType type) {
    this.type = type;
  }

  _addTag() {
    newTags.add(null);
  }

  _editTag(int i, String tag) {
    newTags[i] = tag;
  }

  _removeTag(int i) {
    newTags.removeAt(i);
  }

  _changeVisibility(bool visibility) {
    isVisible = visibility;
  }

  dynamic _getImgUrl() {
    if (photoUrls == null) return null;
    if (photoUrls.isEmpty) return null;
    if (photoUrls.length == 1) return photoUrls[0];
    return photoUrls;
  }

  List<String> _normalizeTags(Iterable<String> tags) {
    final Set<String> tagSet = tags.toSet();
    tagSet.removeWhere((String tag) => tag == null || tag.isEmpty);
    return tagSet.toList();
  }

  Content get content => Content(
      title: title,
      text: text,
      tags: _normalizeTags(tags.followedBy(newTags ?? [])),
      type: type,
      date: normalizeDate(date),
      imageUrl: _getImgUrl(),
      music: music,
      isVisible: isVisible);

  _commit() async {
    final AuthUser user = await app.auth().currentUser;
    final FirestoreDocumentReference ref = app
        .firestore()
        .doc('/texts/' + user.uid)
        .collection('documents')
        .doc(initialContent != null ? initialContent.contentID : null);
    Map<String, dynamic> toChange = {};
    if (initialContent != null) {
      toChange = content.toData();
    } else {
      if (content.isEmpty) return;
      toChange = content.toData();
    }

    /// JS undefined
    if (!(_getImgUrl() is String || _getImgUrl() is Iterable))
      toChange.remove('img');
    try {
      if (toChange.isNotEmpty) await ref.set(toChange);
    } catch (e) {
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

  @override
  Stream<TextEditState> mapEventToState(
    TextEditEvent event,
  ) async* {
    print(event);
    bool reload = false;
    if (event is TagToggledEvent) {
      _toggleTag(event.tag);
      reload = true;
    }
    if (event is TextChangedEvent) {
      _changeText(event.text);
    }
    if (event is TitleChangedEvent) {
      _changeTitle(event.title);
    }
    if (event is DateChangedEvent) {
      _changeDate(event.date);
    }
    if (event is TypeChangedEvent) {
      _changeType(event.type);
      reload = true;
    }
    if (event is PhotoUploadEvent) {
      uploadFile(event.bytes, event.name);
    }
    if (event is PhotoDeletedEvent) {
      _deletePhoto(event.index);
      reload = true;
    }
    if (event is MusicUploadEvent) {
      uploadFile(event.bytes, event.name,
          onUploaded: (String url) => dispatch(MusicAddedEvent(url)),
          onUploadProgress: (double f) =>
              dispatch(MusicUploadFractionEvent(f)));
    }
    if (event is MusicDeletedEvent) {
      music = null;
      reload = true;
    }
    if (event is PhotoAddedEvent) {
      _addPhoto(event.url);
      uploadStatus = null;
      reload = true;
    }
    if (event is PhotoUploadCanceledEvent) {
      cancelUpload();
      uploadStatus = null;
      reload = true;
    }
    if (event is MusicAddedEvent) {
      _addMusic(event.url);
      uploadStatus = null;
      reload = true;
    }
    if (event is MusicUploadCanceledEvent) {
      cancelUpload();
      uploadStatus = null;
      reload = true;
    }
    if (event is CommitEvent) {
      _commit();
    }
    if (event is DeleteEvent) {
      _delete();
    }
    if (event is TagAddedEvent) {
      _addTag();
      reload = true;
    }
    if (event is TagRemovedEvent) {
      _removeTag(event.index);
      reload = true;
    }
    if (event is TagEditedEvent) {
      _editTag(event.index, event.tag);
    }
    if (event is VisibilityChangedEvent) {
      _changeVisibility(event.visibility);
      reload = true;
    }
    if (event is PhotoUploadFractionEvent ||
        event is MusicUploadFractionEvent ||
        (uploadStatus != null && reload)) {
      double f;
      if (event is PhotoUploadFractionEvent) {
        f = event.fraction;
        uploadStatus = Tuple2(event.fraction, false);
      }

      if (event is MusicUploadFractionEvent) {
        f = event.fraction;
        uploadStatus = Tuple2(event.fraction, true);
      }

      f ??= uploadStatus.item1;

      print(uploadStatus.toList());

      if (uploadStatus.item2) {
        yield TextEditingUploadingMusicState(
            title: title,
            text: text,
            photoUrls: photoUrls,
            tags: tags,
            newTags: newTags,
            type: type,
            date: date,
            isVisible: isVisible,
            fraction: f);
      } else {
        yield TextEditingUploadingPhotoState(
            title: title,
            text: text,
            photoUrls: photoUrls,
            tags: tags,
            newTags: newTags,
            type: type,
            date: date,
            isVisible: isVisible,
            fraction: f);
      }
    }
    if (reload && uploadStatus == null)
      yield TextEditingState(
          title: title,
          text: text,
          photoUrls: photoUrls,
          tags: tags,
          newTags: newTags,
          type: type,
          date: date,
          isVisible: isVisible);
  }
}
