import 'package:meta/meta.dart';
import 'package:seaside_blocs/model/content.dart';

@immutable
abstract class TextEditState {
  TextEditState(
      {this.title,
      this.text,
      this.photoUrls,
      this.tags = const [],
      this.newTags = const [],
      this.type,
      this.date,
      this.isVisible});
  final String title;
  final String text;
  final List<String> photoUrls;
  final List<String> tags;
  final List<String> newTags;
  final ContentType type;
  final DateTime date;
  final bool isVisible;
  @override
  String toString() {
    return 'TextEditingState:\n'
        '${title}\n'
        '${text}\n'
        '${photoUrls}\n'
        '${tags}\n'
        '${newTags}\n'
        '${type}\n'
        '${date}\n'
        '${isVisible}';
  }
}

class TextEditingState extends TextEditState {
  TextEditingState(
      {String title,
      String text,
      List<String> photoUrls,
      List<String> tags,
      List<String> newTags,
      ContentType type,
      DateTime date,
      bool isVisible})
      : super(
            title: title,
            text: text,
            photoUrls: photoUrls,
            tags: tags ?? [],
            newTags: newTags ?? [],
            type: type,
            date: date,
            isVisible: isVisible);
  factory TextEditingState.fromContent(Content c) {
    List<String> photoUrls = c.imageUrl is String ? [c.imageUrl] : c.imageUrl;
    return TextEditingState(
        title: c.title,
        text: c.text,
        photoUrls: photoUrls,
        tags: c.tags,
        type: c.type,
        date: c.date == null ? null : DateTime.parse(c.date),
        isVisible: c.isVisible);
  }
}

abstract class TextEditingUploadingState extends TextEditState {
  TextEditingUploadingState(
      {String title,
      String text,
      List<String> photoUrls,
      List<String> tags,
      List<String> newTags,
      ContentType type,
      DateTime date,
      bool isVisible,
      this.fraction})
      : super(
            title: title,
            text: text,
            photoUrls: photoUrls,
            tags: tags ?? [],
            newTags: newTags ?? [],
            type: type,
            date: date,
            isVisible: isVisible);
  final double fraction;
}

class TextEditingUploadingMusicState extends TextEditingUploadingState {
  TextEditingUploadingMusicState(
      {String title,
      String text,
      List<String> photoUrls,
      List<String> tags,
      List<String> newTags,
      ContentType type,
      DateTime date,
      bool isVisible,
      double fraction})
      : super(
            title: title,
            text: text,
            photoUrls: photoUrls,
            tags: tags,
            newTags: newTags,
            type: type,
            date: date,
            isVisible: isVisible,
            fraction: fraction);
}

class TextEditingUploadingPhotoState extends TextEditingUploadingState {
  TextEditingUploadingPhotoState(
      {String title,
      String text,
      List<String> photoUrls,
      List<String> tags,
      List<String> newTags,
      ContentType type,
      DateTime date,
      bool isVisible,
      double fraction})
      : super(
            title: title,
            text: text,
            photoUrls: photoUrls,
            tags: tags,
            newTags: newTags,
            type: type,
            date: date,
            isVisible: isVisible,
            fraction: fraction);
}
