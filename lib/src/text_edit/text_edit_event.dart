import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:seaside_blocs/model/content.dart';

@immutable
abstract class TextEditEvent {}

class TagToggledEvent extends TextEditEvent {
  TagToggledEvent(this.tag);
  final String tag;
}

class TextChangedEvent extends TextEditEvent {
  TextChangedEvent(this.text);
  final String text;
}

class TitleChangedEvent extends TextEditEvent {
  TitleChangedEvent(this.title);
  final String title;
}

class DateChangedEvent extends TextEditEvent {
  DateChangedEvent(this.date);
  final DateTime date;
}

class TypeChangedEvent extends TextEditEvent {
  TypeChangedEvent(this.type);
  final ContentType type;
}

class PhotoUploadEvent extends TextEditEvent {
  PhotoUploadEvent(this.bytes, this.name);
  final Uint8List bytes;
  final String name;
}

class PhotoAddedEvent extends TextEditEvent {
  PhotoAddedEvent(this.url);
  final String url;
}

class PhotoDeletedEvent extends TextEditEvent {
  PhotoDeletedEvent(this.index);
  final int index;
}

class PhotoUploadFractionEvent extends TextEditEvent {
  PhotoUploadFractionEvent(this.fraction);
  final double fraction;
}

class PhotoUploadCanceledEvent extends TextEditEvent {}

class MusicUploadEvent extends TextEditEvent {
  MusicUploadEvent(this.bytes, this.name);
  final Uint8List bytes;
  final String name;
}

class MusicAddedEvent extends TextEditEvent {
  MusicAddedEvent(this.url);
  final String url;
}

class MusicDeletedEvent extends TextEditEvent {}

class MusicUploadFractionEvent extends TextEditEvent {
  MusicUploadFractionEvent(this.fraction);
  final double fraction;
}

class MusicUploadCanceledEvent extends TextEditEvent {}

class CommitEvent extends TextEditEvent {}

class DeleteEvent extends TextEditEvent {}

class TagAddedEvent extends TextEditEvent {}

class TagRemovedEvent extends TextEditEvent {
  TagRemovedEvent(this.index);
  final int index;
}

class TagEditedEvent extends TextEditEvent {
  TagEditedEvent(this.index, this.tag);
  final int index;
  final String tag;
}

class VisibilityChangedEvent extends TextEditEvent {
  VisibilityChangedEvent(this.visibility);
  final bool visibility;
}
