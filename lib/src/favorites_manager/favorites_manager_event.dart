import 'package:meta/meta.dart';

@immutable
abstract class FavoritesManagerEvent {}

class LoadedFavoritesManagerEvent extends FavoritesManagerEvent {
  LoadedFavoritesManagerEvent(this.favoriteAuthors, this.favoriteContent);
  final List<String> favoriteAuthors;
  final List<String> favoriteContent;
}

class AuthorToFavoritesEvent extends FavoritesManagerEvent {
  AuthorToFavoritesEvent(this.author);
  final String author;
}

class ContentToFavoritesEvent extends FavoritesManagerEvent {
  ContentToFavoritesEvent(this.content);
  final String content;
}
