import 'dart:async';

import 'package:bloc/bloc.dart';

import './bloc.dart';

abstract class MusicPlayerBloc extends Bloc<MusicPlayerEvent, MusicPlayerState> {
  MusicPlayerBloc(this.musicUrl);
  String musicUrl;

  void play();
  void pause();
  void stop();
  void resume();
  void seek(double val);
  MusicPlayerState onLoaded(LoadedEvent event);

  @override
  Stream<MusicPlayerState> mapEventToState(
    MusicPlayerEvent event,
  ) async* {
    if (event is MusicPlayEvent) {
      play();
    }
    if (event is MusicProgressEvent) {
      yield PlayingMusicState(currentState.duration, event.progress);
    }
    if (event is MusicPauseEvent) {
      pause();
    }
    if (event is MusicStopEvent) {
      stop();
    }
    if (event is MusicResumeEvent) {
      resume();
    }
    if (event is MusicSeekEvent) {
      seek(event.seek);
    }
    if (event is LoadedEvent) {
      final state = onLoaded(event);
      if (state != null)
        yield state;
    }
    _yieldPaused(MusicPlayerState currentState) {
      if (currentState is ValuedMusicState)
        return PausedMusicState(currentState.duration, currentState.value);
      return null;
    }

    if (event is NativeStateChangedEvent) {
      switch (event.state) {
        case NativePlayerState.stopped:
          yield StoppedMusicState(currentState.duration);
          break;
        case NativePlayerState.playing:
          yield PlayingMusicState(
              currentState.duration ?? Duration(seconds: 10), Duration.zero);
          break;
        case NativePlayerState.paused:
          yield _yieldPaused(currentState);
          break;
        case NativePlayerState.completed:
          yield IdleMusicState(currentState.duration ?? Duration.zero);
          break;
      }
    }
  }
}
