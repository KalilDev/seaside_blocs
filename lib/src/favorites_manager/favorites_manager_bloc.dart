import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';
import './bloc.dart';

class FavoritesManagerBloc
    extends Bloc<FavoritesManagerEvent, FavoritesManagerState> {
  FavoritesManagerBloc([this.prefs]);
  SharedPreferences prefs;

  Tuple2<List<String>, List<String>> _getPrefs() {
    final List<String> authors = getStringList('favoriteAuthors');
    final List<String> contents = getStringList('favoriteContents');
    return Tuple2(authors ?? [], contents ?? []);
  }

  LoadedFavoritesManagerState _addToFavorite(String s, bool isAuthor) {
    try {
      final result = _getPrefs();
      List<String> authors = result.item1;
      List<String> contents = result.item2;
      if (isAuthor) {
        if (!authors.contains(s))
          authors.add(s);
        else
          authors.remove(s);
      } else {
        if (!contents.contains(s))
          contents.add(s);
        else
          contents.remove(s);
      }
      isAuthor
          ? prefs?.setStringList('favoriteAuthors', authors)
          : prefs?.setStringList('favoriteContents', contents);
      return LoadedFavoritesManagerState(authors, contents);
    } catch (e) {
      return LoadedFavoritesManagerState([], []);
    }
  }

  void _initialize() async {
    prefs = await SharedPreferences.getInstance();
    final result = _getPrefs();
    add(LoadedFavoritesManagerEvent(result.item1, result.item2));
  }

  @override
  FavoritesManagerState get initialState {
    _initialize();
    return LoadingFavoritesManagerState();
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
