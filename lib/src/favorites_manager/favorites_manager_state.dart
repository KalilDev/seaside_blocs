import 'package:meta/meta.dart';

@immutable
abstract class FavoritesManagerState {
  FavoritesManagerState([this.a, this.c]);
  final List<String> a;
  final List<String> c;
}

class LoadingFavoritesManagerState extends FavoritesManagerState {}

class LoadedFavoritesManagerState extends FavoritesManagerState {
  LoadedFavoritesManagerState(List<String> authors, List<String> contents)
      : super(authors, contents);
  List<String> get authors => a ?? List<String>();
  List<String> get favoriteContent => c ?? List<String>();
}
