class Content {
  Content(
      {this.title,
      this.text,
      this.imageUrl,
      this.tags,
      this.type,
      this.authorID,
      this.contentID,
      this.date,
      this.music,
      this.isVisible});
  final String title;
  final String text;
  final dynamic imageUrl;
  final List<String> tags;
  final ContentType type;
  final String authorID;
  final String contentID;
  final String date;
  final String music;
  final bool isVisible;

  String get backgroundImage {
    if (imageUrl is String) return imageUrl;
    if (imageUrl is Iterable) return imageUrl.first;
    return null;
  }

  factory Content.fromFirestore(
      Map<String, dynamic> data, String path, String id) {
    dynamic img;
    try {
      img = data['img'] as String ?? null;
    } catch (e) {
      img = List<String>.from(data['img'] ?? Iterable.empty());
    }
    return Content(
        authorID: path.split('/')[1],
        text: data['text'] as String,
        tags: List<String>.from(data['tags'] ?? Iterable.empty()),
        title: data['title'] as String,
        imageUrl: img,
        type: ContentType.values[data['type'] as int ?? 0],
        contentID: id,
        date: data['date'] as String,
        music: data['music'] as String,
        isVisible: data['isVisible']);
  }
  Map<String, dynamic> toData() => <String, dynamic>{
        'date': date,
        'title': title,
        'text': text == null ? null : text.replaceAll('\n', '^NL'),
        'tags': tags,
        'img': imageUrl,
        'type': ContentType.values.indexOf(type),
        'music': music,
        'isVisible': isVisible
      };
  @override
  bool operator ==(other) {
    if (other is Content) {
      print(getDelta(this, other));
      return getDelta(this, other).isEmpty;
    }
    return false;
  }

  @override
  int get hashCode {
    return tags.hashCode +
        title.hashCode +
        type.hashCode +
        text.hashCode +
        imageUrl.hashCode +
        date.hashCode +
        music.hashCode +
        isVisible.hashCode;
  }

  bool get isEmpty =>
      (title == null || title.isEmpty) &&
      (text == null || text.isEmpty) &&
      (imageUrl == null ||
          (imageUrl is Iterable && imageUrl.isEmpty) ||
          (imageUrl is String && imageUrl.isEmpty)) &&
      (tags == null || tags.isEmpty) &&
      (type == null || type == ContentType.text) &&
      (music == null || music.isEmpty) &&
          (isVisible == null);
  String get textPath => '/texts/' + authorID + '/documents/' + contentID;

  static Map<String,dynamic> getDelta(Content c1, Content c2) {
    Map<String, dynamic> secondData = c2.toData();
    Map<String, dynamic> delta = Map<String, dynamic>();
    c1.toData().forEach((String key, dynamic val) {
      if (val is List) {
        final secondVal = secondData[key];
        if (secondVal is List) {
          if (secondVal.length != val.length)
            delta[key] = secondVal;

          val.sort();
          secondVal.sort();
          for (int i = 0; i<val.length;i++) {
            if (val[i] != secondVal[i]) {
              delta[key] = secondVal;
              break;
            }
          }
        } else {
          delta[key] = secondVal;
        }
      } else {
        if (val != secondData[key])
          delta[key] = secondData[key];
      }
    });
    return delta;
  }
}

String normalizeDate(DateTime time) =>
    time.year.toString() + _normalize(time.month) + _normalize(time.day);

String _normalize(int date) {
  if (date < 10) return '0' + date.toString();
  return date.toString();
}

enum ContentType { text, painting, drawing, picture, music, poem, lithium }
