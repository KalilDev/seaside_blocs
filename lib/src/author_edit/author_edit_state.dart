import 'package:meta/meta.dart';
import 'package:seaside_blocs/model/author.dart';

@immutable
abstract class AuthorEditState {
  AuthorEditState(this.name, this.bio, this.photoUrl, this.isVisible);
  final String name;
  final String bio;
  final String photoUrl;
  final bool isVisible;
  Author get author =>
      Author(name: name, bio: bio, imgUrl: photoUrl, isVisible: isVisible);
}

class AuthorEditingState extends AuthorEditState {
  AuthorEditingState([String name, String bio, String photoUrl, bool isVisible])
      : super(name, bio, photoUrl, isVisible);
}

class AuthorEditingUploadingState extends AuthorEditState {
  AuthorEditingUploadingState(
      [String name, String bio, String photoUrl, bool isVisible, this.fraction])
      : super(name, bio, photoUrl, isVisible);
  final double fraction;
}
