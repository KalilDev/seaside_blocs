import 'package:meta/meta.dart';
import 'package:seaside_blocs/model/author.dart';
import 'package:seaside_blocs/model/content.dart';

class FirebaseStreamState extends BaseFirebaseStreamState {
  FirebaseStreamState(Iterable<Content> contents, Iterable<Author> authors,
      {Map<ContentType, Iterable<Content>> typeContentMap,
      Map<String, List<String>> authorIDTagsMap,
      Map<String, Iterable<Content>> tagContentMap,
      Map<String, Content> idContentMap,
      Map<String, Map<ContentType, Iterable<Content>>> authorIDContentMap,
      Map<String, Author> idAuthorMap})
      : super(contents, authors, typeContentMap, authorIDTagsMap, tagContentMap,
            idContentMap, authorIDContentMap, idAuthorMap);
}

@immutable
abstract class BaseFirebaseStreamState {
  BaseFirebaseStreamState(
      [this._contents,
      this._authors,
      this._typeContentMap,
      this._authorIDTagsMap,
      this._tagContentMap,
      this._idContentMap,
      this._authorIDContentMap,
      this._idAuthorMap]);
  final Iterable<Content> _contents;
  final Iterable<Author> _authors;
  final Map<ContentType, Iterable<Content>> _typeContentMap;
  final Map<String, List<String>> _authorIDTagsMap;
  final Map<String, Iterable<Content>> _tagContentMap;
  final Map<String, Content> _idContentMap;
  final Map<String, Map<ContentType, Iterable<Content>>> _authorIDContentMap;
  final Map<String, Author> _idAuthorMap;

  Iterable<Content> get contents => _contents ?? Iterable<Content>.empty();
  Iterable<Author> get authors => _authors ?? Iterable<Author>.empty();
  Map<ContentType, Iterable<Content>> get typeContentMap =>
      _typeContentMap ?? {};
  Map<String, List<String>> get authorIDTagsMap => _authorIDTagsMap;
  Map<String, Iterable<Content>> get tagContentMap => _tagContentMap ?? {};
  Map<String, Content> get idContentMap => _idContentMap ?? {};
  Map<String, Map<ContentType, Iterable<Content>>> get authorIDContentMap =>
      _authorIDContentMap ?? {};
  Map<String, Author> get idAuthorMap => _idAuthorMap ?? {};
}

class LoadingFirebaseStreamState extends BaseFirebaseStreamState {}
