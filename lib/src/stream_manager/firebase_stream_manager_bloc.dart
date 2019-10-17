import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_abstraction/firebase.dart';
import 'package:seaside_blocs/src/stream_manager/bloc.dart';
import 'package:seaside_blocs/model/author.dart';
import 'package:seaside_blocs/model/content.dart';
import 'package:seaside_blocs/src/singletons.dart';

abstract class FirebaseStreamManagerBloc
    extends Bloc<FirebaseStreamManagerEvent, BaseFirebaseStreamState> {
  /// Get most queries and cache them, so the view does not have to do any of
  /// this.
  static FirebaseStreamState eventToStateConverter(StreamUpdatedEvent event) {
    Map<String, Iterable<Content>> tagContentMap = {};
    Map<ContentType, Iterable<Content>> typeContentMap = {};
    Map<String, Content> idContentMap = {};
    Map<String, Map<ContentType, Iterable<Content>>> authorIDContentMap = {};
    Map<String, Author> idAuthorMap = {};
    Map<String, List<String>> authorIDTagsMap = {};
    for (Content c in event.contents.toList()..shuffle()) {
      final Iterable<Content> cWithType = typeContentMap.containsKey(c.type)
          ? typeContentMap[c.type].followedBy([c])
          : [c];
      typeContentMap[c.type] = cWithType;
      idContentMap[c.contentID] = c;
      final Iterable<String> currentAuthorTags =
          authorIDTagsMap.containsKey(c.authorID)
              ? authorIDTagsMap[c.authorID].followedBy(c?.tags ?? []).toSet()
              : c?.tags ?? [];
      authorIDTagsMap[c.authorID] = currentAuthorTags.toList();
      for (String t in c?.tags ?? []) {
        final Iterable<Content> cWithTag = tagContentMap.containsKey(t)
            ? tagContentMap[t].toSet().followedBy([c])
            : [c];
        tagContentMap[t] = cWithTag;
      }
    }
    for (Author a in event.authors.toList()..shuffle()) {
      idAuthorMap[a.id] = a;
      final Iterable<Content> contents =
          event.contents.where((Content c) => c.authorID == a.id);
      Map<ContentType, Iterable<Content>> _typeContentMap = {};
      for (Content c in contents) {
        final Iterable<Content> cWithType = _typeContentMap.containsKey(c.type)
            ? _typeContentMap[c.type].followedBy([c])
            : [c];
        _typeContentMap[c.type] = cWithType;
      }
      authorIDContentMap[a.id] = _typeContentMap;
    }
    return FirebaseStreamState(event.contents, event.authors,
        typeContentMap: typeContentMap,
        tagContentMap: tagContentMap,
        idContentMap: idContentMap,
        authorIDContentMap: authorIDContentMap,
        idAuthorMap: idAuthorMap,
        authorIDTagsMap: authorIDTagsMap);
  }

  static Iterable searchResults(String query, Iterable<Content> contents, Iterable<Author> authors) {
    if (query == null || query == '') return Iterable.empty();
      Iterable q = Iterable.empty();
      q = q.followedBy(contents.where((Content c) =>
          (c?.tags?.any((String tag) => containsIgnoreCase(tag, query)) ??
              false) ||
          containsIgnoreCase(c.title, query)));
      q = q.followedBy(
          authors.where((Author a) => containsIgnoreCase(a.name, query)));
      return q;
  }
}

class RealFirebaseManagerBloc extends FirebaseStreamManagerBloc {
  RealFirebaseManagerBloc([FirebaseApp app])
      : this.app = app ?? firebaseApp,
        this.db = (app ?? firebaseApp).firestore();
  final FirebaseApp app;
  final FirestoreInstance db;
  StreamSubscription<AuthUser> userSubscription;
  StreamSubscription<Iterable<FirestoreDocumentSnapshot>> authorsSubs;
  StreamSubscription<FirestoreDocumentSnapshot> currentAuthorSubs;
  Map<String, StreamSubscription<Iterable<Content>>> authorContentSubsMap = {};
  Map<String, Iterable<Content>> authorContentMap = {};
  bool allowDocChanges = false;
  Iterable<Author> authorIterable;

  _cleanUpState() {
    authorsSubs?.cancel();
    currentAuthorSubs?.cancel();
    for (StreamSubscription<Iterable<Content>> sub
        in authorContentSubsMap.values) {
      sub.cancel();
    }
    authorContentSubsMap = {};
  }

  _userStreamSetup() async {
    userSubscription = app.auth().userStream.listen((AuthUser user) async {
      if (user.uid == null) {
        _cleanUpState();
      } else {
        _streamSetup(user.uid);
      }
    });
  }

  _handleDoc(Iterable<Content> authorContents, String authorID) async {
    authorContentMap[authorID] = authorContents;
    if (allowDocChanges) {
      dispatch(StreamUpdatedEvent(
          await waitAllContents(authorIterable), authorIterable));
    }
  }

  Future<Iterable<Content>> waitAllContents(Iterable<Author> authors) async {
    authorIterable = authors;
    Iterable<String> authorIDs = authors.map((Author a) => a.id);
    bool _maybeDelete(String a, StreamSubscription s) {
      if (authorIDs.contains(a)) {
        return false;
      } else {
        s.cancel();
        authorContentMap.remove(a);
        return true;
      }
    }

    authorContentSubsMap.removeWhere(_maybeDelete);
    for (Author a in authors) {
      bool _condition() {
        return authorContentMap.containsKey(a.id);
      }

      while (_condition() == false) {
        await Future.delayed(Duration(milliseconds: 10));
      }
    }
    allowDocChanges = true;
    return authorContentMap.values
        .reduce((Iterable<Content> a, Iterable<Content> b) => a.followedBy(b));
  }

  Future<void> _streamSetup(String current) async {
    Iterable<Author> authors = Iterable.empty();

    _onAuthorsChanged() async {
      for (Author a in authors) {
        final String authorID = a.id;
        if (authorID == current) {
          authorContentSubsMap.putIfAbsent(
              authorID,
              () => db
                  .collection('/texts/' + authorID + '/documents')
                  .snapshots
                  .map<Iterable<Content>>((FirestoreQuerySnapshot snap) =>
                      snap.docs.map<Content>((FirestoreDocumentSnapshot doc) =>
                          Content.fromFirestore(
                              doc.data, doc.ref.path, doc.id)))
                  .listen(
                      (Iterable<Content> iter) => _handleDoc(iter, authorID)));
        } else {
          authorContentSubsMap.putIfAbsent(
              authorID,
              () => db
                  .collection('/texts/' + authorID + '/documents')
                  .where('isVisible', QueryOperation.equalTo, true)
                  .snapshots
                  .map<Iterable<Content>>((FirestoreQuerySnapshot snap) =>
                      snap.docs.map<Content>((FirestoreDocumentSnapshot doc) =>
                          Content.fromFirestore(
                              doc.data, doc.ref.path, doc.id)))
                  .listen(
                      (Iterable<Content> iter) => _handleDoc(iter, authorID)));
        }
      }
      Iterable<Content> contents = await waitAllContents(authors);
      dispatch(StreamUpdatedEvent(contents, authors));
    }

    _onCurrentAuthor(FirestoreDocumentSnapshot snap) async {
      final Iterable<Author> currentAuthors =
          authors.where((Author a) => a.id != current);
      if (!snap.exists) {
        authors = currentAuthors;
        _onAuthorsChanged();
      } else {
        final Author currentAuthor = Author.fromFirestore(snap.data, snap.id);
        authors = currentAuthors.followedBy([currentAuthor]);
        _onAuthorsChanged();
      }
    }

    _onAuthors(Iterable<FirestoreDocumentSnapshot> snaps) async {
      final Iterable<Author> newAuthors = snaps
          .map<Author>((FirestoreDocumentSnapshot s) =>
              Author.fromFirestore(s.data, s.id))
          .where((Author a) => a.id != current);
      authors =
          authors.where((Author a) => a.id == current).followedBy(newAuthors);
      _onAuthorsChanged();
    }

    currentAuthorSubs =
        db.doc('/texts/' + current).snapshots.listen(_onCurrentAuthor);
    authorsSubs = db
        .collection('/texts')
        .where('isVisible', QueryOperation.equalTo, true)
        .snapshots
        .map<Iterable<FirestoreDocumentSnapshot>>(
            (FirestoreQuerySnapshot snap) => snap.docs)
        .listen(_onAuthors);
  }

  @override
  BaseFirebaseStreamState get initialState {
    _userStreamSetup();
    return LoadingFirebaseStreamState();
  }

  @override
  void dispose() {
    userSubscription.cancel();
    _cleanUpState();
    super.dispose();
  }

  @override
  Stream<BaseFirebaseStreamState> mapEventToState(
    FirebaseStreamManagerEvent event,
  ) async* {
    if (event is StreamUpdatedEvent) {
      yield FirebaseStreamManagerBloc.eventToStateConverter(event);
    }
  }
}

bool containsIgnoreCase(String container, String contained) {
  return container?.toLowerCase()?.contains(contained?.toLowerCase());
}
