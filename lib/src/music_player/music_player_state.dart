import 'package:meta/meta.dart';

@immutable
abstract class MusicPlayerState {
  MusicPlayerState([this.duration]);
  final Duration duration;
}

class LoadingMusicPlayerState extends MusicPlayerState {}

class IdleMusicState extends MusicPlayerState {
  IdleMusicState(Duration duration) : super(duration);
}

class StoppedMusicState extends MusicPlayerState {
  StoppedMusicState(Duration duration) : super(duration);
}

abstract class ValuedMusicState extends MusicPlayerState {
  ValuedMusicState(Duration duration, this.value) : super(duration);
  final Duration value;
}

class PlayingMusicState extends ValuedMusicState {
  PlayingMusicState(Duration duration, Duration value) : super(duration, value);
}

class PausedMusicState extends ValuedMusicState {
  PausedMusicState(Duration duration, Duration value) : super(duration, value);
}
