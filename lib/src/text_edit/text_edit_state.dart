import 'package:meta/meta.dart';
import 'package:seaside_blocs/model/content.dart';

@immutable
abstract class TextEditState {
  TextEditState(
      {this.title,
      this.text,
      this.photoUrls,
      this.tags,
      this.newTags,
      this.type,
      this.date,
      this.isVisible,
      this.musicUrl});
  final String title;
  final String text;
  final List<String> photoUrls;
  final List<String> tags;
  final List<String> newTags;
  final ContentType type;
  final DateTime date;
  final bool isVisible;
  final String musicUrl;

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
        '${isVisible}\n'
        '${musicUrl}';
  }

  dynamic _getImgUrl() {
    if (photoUrls == null) return null;
    photoUrls.removeWhere((String s)=> s==null || s.isEmpty);
    if (photoUrls.isEmpty) return null;
    if (photoUrls.length == 1) return photoUrls[0];
    return photoUrls;
  }

  List<String> _normalizeTags(Iterable<String> tags) {
    final Set<String> tagSet = tags.toSet();
    tagSet.removeWhere((String tag) => tag == null || tag.isEmpty);
    return tagSet.toList();
  }

  Content get content => Content(
      title: title,
      text: text,
      tags: _normalizeTags(tags.followedBy(newTags ?? [])),
      type: type,
      date: normalizeDate(date),
      imageUrl: (_getImgUrl() is String || _getImgUrl() is Iterable) ? _getImgUrl() : null, // Protect against JS Undefined on web
      music: musicUrl,
      isVisible: isVisible);


  TextEditState copyWith({
    String title,
    String text,
    List<String> photoUrls,
    List<String> tags,
    List<String> newTags,
    ContentType type,
    DateTime date,
    bool isVisible,
    String musicUrl});

  TextEditState getPureState() {
    return TextEditingState(
        title: title,
        text: text,
        photoUrls: photoUrls,
        tags: tags,
        newTags: newTags,
        type: type,
        date: date,
        isVisible: isVisible,
        musicUrl:musicUrl);
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
      bool isVisible,
        String musicUrl})
      : super(
            title: title,
            text: text,
            photoUrls: photoUrls,
            tags: tags,
            newTags: newTags,
            type: type,
            date: date,
            isVisible: isVisible,
            musicUrl: musicUrl);
  factory TextEditingState.fromContent(Content c) {
    List<String> photoUrls = c.imageUrl is String ? [c.imageUrl] : c.imageUrl;
    return TextEditingState(
        title: c.title,
        text: c.text,
        photoUrls: photoUrls,
        tags: c.tags,
        type: c.type,
        date: c.date == null ? null : DateTime.parse(c.date),
        isVisible: c.isVisible,
        musicUrl: c.music,
        newTags: []);
  }

  @override
  TextEditingState copyWith({
    String title,
    String text,
    List<String> photoUrls,
    List<String> tags,
    List<String> newTags,
    ContentType type,
    DateTime date,
    bool isVisible,
    String musicUrl}) {
    return TextEditingState(
        title: title ?? this.title,
        text: text ?? this.text,
        photoUrls: photoUrls ?? this.photoUrls,
        tags: tags ?? this.tags,
        newTags: newTags ?? this.newTags,
        type: type ?? this.type,
        date: date ?? this.date,
        isVisible: isVisible ?? this.isVisible,
      musicUrl: musicUrl ?? this.musicUrl
    );
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
        String musicUrl,
      this.fraction})
      : super(
            title: title,
            text: text,
            photoUrls: photoUrls,
            tags: tags,
            newTags: newTags,
            type: type,
            date: date,
            isVisible: isVisible,
            musicUrl:musicUrl);
  final double fraction;

  @override
  TextEditingUploadingState copyWith({
    String title,
    String text,
    List<String> photoUrls,
    List<String> tags,
    List<String> newTags,
    ContentType type,
    DateTime date,
    bool isVisible,
    String musicUrl,
    double fraction});
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
        String musicUrl,
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
            musicUrl: musicUrl,
            fraction: fraction);

  factory TextEditingUploadingMusicState.fromPure(TextEditState pure) {
    return TextEditingUploadingMusicState(
        title: pure.title,
        text: pure.text,
        photoUrls: pure.photoUrls,
        tags: pure.tags,
        newTags: pure.newTags,
        type: pure.type,
        date: pure.date,
        isVisible: pure.isVisible,
        musicUrl: pure.musicUrl,
        fraction: 0.0
    );
  }

  @override
  TextEditingUploadingMusicState copyWith({
    String title,
    String text,
    List<String> photoUrls,
    List<String> tags,
    List<String> newTags,
    ContentType type,
    DateTime date,
    bool isVisible,
    String musicUrl,
    double fraction}) {
    return TextEditingUploadingMusicState(
        title: title ?? this.title,
        text: text ?? this.text,
        photoUrls: photoUrls ?? this.photoUrls,
        tags: tags ?? this.tags,
        newTags: newTags ?? this.newTags,
        type: type ?? this.type,
        date: date ?? this.date,
        isVisible: isVisible ?? this.isVisible,
        musicUrl: musicUrl ?? this.musicUrl,
        fraction: fraction ?? this.fraction
    );
  }
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
        String musicUrl,
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
            musicUrl: musicUrl,
            fraction: fraction);

  factory TextEditingUploadingPhotoState.fromPure(TextEditState pure) {
    return TextEditingUploadingPhotoState(
        title: pure.title,
        text: pure.text,
        photoUrls: pure.photoUrls,
        tags: pure.tags,
        newTags: pure.newTags,
        type: pure.type,
        date: pure.date,
        isVisible: pure.isVisible,
        musicUrl: pure.musicUrl,
        fraction: 0.0
    );
  }

  @override
  TextEditingUploadingPhotoState copyWith({
    String title,
    String text,
    List<String> photoUrls,
    List<String> tags,
    List<String> newTags,
    ContentType type,
    DateTime date,
    bool isVisible,
    String musicUrl,
    double fraction}) {
    return TextEditingUploadingPhotoState(
        title: title ?? this.title,
        text: text ?? this.text,
        photoUrls: photoUrls ?? this.photoUrls,
        tags: tags ?? this.tags,
        newTags: newTags ?? this.newTags,
        type: type ?? this.type,
        date: date ?? this.date,
        isVisible: isVisible ?? this.isVisible,
        musicUrl: musicUrl ?? this.musicUrl,
        fraction: fraction ?? this.fraction
    );
  }
}
