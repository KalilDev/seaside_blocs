import 'package:meta/meta.dart';
import 'package:seaside_blocs/model/author.dart';
import 'package:seaside_blocs/model/content.dart';

@immutable
abstract class FirebaseStreamManagerEvent {}

class StreamUpdatedEvent extends FirebaseStreamManagerEvent {
  StreamUpdatedEvent(this.contents, this.authors);
  final Iterable<Content> contents;
  final Iterable<Author> authors;
}
