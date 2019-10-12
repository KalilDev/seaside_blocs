import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:key_value_store/key_value_store.dart';
import 'package:seaside_blocs/src/singletons.dart';
import 'package:tuple/tuple.dart';
import './bloc.dart';

abstract class FavoritesManagerBloc
    extends Bloc<FavoritesManagerEvent, FavoritesManagerState> {}

class FavoritesLocalOnlyManagerBloc extends FavoritesManagerBloc {
  FavoritesLocalOnlyManagerBloc([this.prefs]);
  KeyValueStore prefs;

  Tuple2<List<String>, List<String>> _getPrefs() {
    final List<String> authors = getStringList('favoriteAuthors');
    final List<String> contents = getStringList('favoriteContents');
    return Tuple2(authors ?? [],contents ?? []);
  }

  LoadedFavoritesManagerState _addToFavorite(String s, bool isAuthor) {
    try {
      final result = _getPrefs();
      List<String> authors = result.item1;
      List<String> contents = result.item2;
      if (isAuthor) {
        if (!authors.contains(s))
          authors.add(s);
        else authors.remove(s);
      } else {
        if (!contents.contains(s))
          contents.add(s);
        else contents.remove(s);
      }
      isAuthor
          ? prefs?.setStringList('favoriteAuthors', authors)
          : prefs?.setStringList('favoriteContents', contents);
      return LoadedFavoritesManagerState(authors, contents);
    } catch (e) {
      return LoadedFavoritesManagerState([], []);
    }
  }

  LoadedFavoritesManagerState _initialize() {
    prefs ??= keyValueStore;
    final result = _getPrefs();
    return LoadedFavoritesManagerState(result.item1, result.item2);
  }

  @override
  FavoritesManagerState get initialState {
    return _initialize();
  }

  List<String> getStringList(String key) {
    List<String> l;
    try {
      l = prefs?.getStringList(key);
    } catch (e) {}
    return l;
  }

  @override
  Stream<FavoritesManagerState> mapEventToState(
    FavoritesManagerEvent event,
  ) async* {
    if (event is LoadedFavoritesManagerEvent) {
      yield LoadedFavoritesManagerState(
          event.favoriteAuthors, event.favoriteContent);
    }
    if (event is AuthorToFavoritesEvent) {
      yield _addToFavorite(event.author, true);
    }
    if (event is ContentToFavoritesEvent) {
      yield _addToFavorite(event.content, false);
    }
  }
}
