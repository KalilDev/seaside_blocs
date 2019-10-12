import 'dart:typed_data';

import 'package:meta/meta.dart';

@immutable
abstract class AuthorEditEvent {}

class NameChangedEvent extends AuthorEditEvent {
  NameChangedEvent(this.name);
  final String name;
}

class BioChangedEvent extends AuthorEditEvent {
  BioChangedEvent(this.bio);
  final String bio;
}

class PhotoUploadEvent extends AuthorEditEvent {
  PhotoUploadEvent(this.bytes, this.name);
  final Uint8List bytes;
  final String name;
}

class PhotoChangeEvent extends AuthorEditEvent {
  PhotoChangeEvent([this.url]);
  final String url;
}

class PhotoUploadFractionEvent extends AuthorEditEvent {
  PhotoUploadFractionEvent(this.fraction);
  final double fraction;
}

class PhotoUploadCancelEvent extends AuthorEditEvent {}

class AuthorDeleteEvent extends AuthorEditEvent {}

class CommitEvent extends AuthorEditEvent {}

class VisibilityChangedEvent extends AuthorEditEvent {
  VisibilityChangedEvent(this.visibility);
  final bool visibility;
}
