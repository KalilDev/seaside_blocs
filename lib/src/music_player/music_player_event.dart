import 'bloc.dart' show NativePlayerState;
import 'package:meta/meta.dart';

@immutable
abstract class MusicPlayerEvent {}

class MusicPlayEvent extends MusicPlayerEvent {}

class MusicPauseEvent extends MusicPlayerEvent {}

class MusicStopEvent extends MusicPlayerEvent {}

class MusicResumeEvent extends MusicPlayerEvent {}

class MusicSeekEvent extends MusicPlayerEvent {
  MusicSeekEvent(this.seek);
  final double seek;
}

class MusicProgressEvent extends MusicPlayerEvent {
  MusicProgressEvent(this.progress);
  final Duration progress;
}

class NativeStateChangedEvent extends MusicPlayerEvent {
  NativeStateChangedEvent(this.state);
  final NativePlayerState state;
}

class LoadedEvent extends MusicPlayerEvent {
  LoadedEvent(this.duration);
  final Duration duration;
}
