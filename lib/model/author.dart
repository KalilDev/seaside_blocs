import 'package:meta/meta.dart';

@immutable
class Author {
  const Author({this.name, this.imgUrl, this.bio, this.id, this.isVisible});
  final String name;
  final String imgUrl;
  final String bio;
  final String id;
  final bool isVisible;

  factory Author.fromFirestore(Map<String, dynamic> data, String id) {
    return Author(
        name: data['authorName'] as String,
        imgUrl: data['imgUrl'] as String,
        bio: data['bio'] as String,
        id: id,
        isVisible: data['isVisible']);
  }

  Map<String, dynamic> toData() => {
        'authorName': name,
        'imgUrl': imgUrl,
        'bio': bio,
        'isVisible': isVisible
      };

  static getDelta(Author a1, Author a2) {
    Map<String, dynamic> secondData = a2.toData();
    Map<String, dynamic> delta = Map<String, dynamic>();
    a1.toData().forEach((String key, dynamic val) {
      if (val != secondData[key])
        delta[key] = secondData[key];
    });
    return delta;
  }
}
