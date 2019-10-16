import 'package:meta/meta.dart';
import 'package:seaside_blocs/model/author.dart';

@immutable
abstract class AuthorEditState {
  AuthorEditState({this.name, this.bio, this.photoUrl, this.isVisible});
  final String name;
  final String bio;
  final String photoUrl;
  final bool isVisible;
  Author get author =>
      Author(name: name, bio: bio, imgUrl: photoUrl, isVisible: isVisible);
  AuthorEditState copyWith({String name,
  String bio,
  String photoUrl,
  isVisible});

  AuthorEditingState getPureState() {
    return AuthorEditingState(name: name, bio: bio, photoUrl: photoUrl, isVisible: isVisible);
  }
}

class AuthorEditingState extends AuthorEditState {
  AuthorEditingState({String name, String bio, String photoUrl, bool isVisible})
      : super(name: name, bio: bio, photoUrl: photoUrl, isVisible: isVisible);
  @override
  AuthorEditingState copyWith({String name,
    String bio,
    String photoUrl,
    isVisible}) {
    return AuthorEditingState(
        name: name ?? this.name,
        bio: bio ?? this.bio,
        photoUrl: photoUrl ?? this.photoUrl,
        isVisible: isVisible ?? this.isVisible
    );
  }
}

class AuthorEditingUploadingState extends AuthorEditState {
  AuthorEditingUploadingState({String name, String bio, String photoUrl, bool isVisible, this.fraction})
      : super(name: name, bio: bio, photoUrl: photoUrl, isVisible: isVisible);
  factory AuthorEditingUploadingState.fromPure(AuthorEditState pure) {
    return AuthorEditingUploadingState(name: pure.name, bio: pure.bio, photoUrl: pure.photoUrl, isVisible: pure.isVisible,fraction: 0.0);
  }

  final double fraction;

  @override
  AuthorEditingUploadingState copyWith({String name,
    String bio,
    String photoUrl,
    isVisible,
    double fraction}) {
    return AuthorEditingUploadingState(
        name: name ?? this.name,
        bio: bio ?? this.bio,
        photoUrl: photoUrl ?? this.photoUrl,
        isVisible: isVisible ?? this.isVisible,
        fraction: fraction ?? this.fraction
    );
  }
}
