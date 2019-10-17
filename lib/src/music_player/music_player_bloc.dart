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
      yield PlayingMusicState(state.duration, event.progress);
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
    _yieldPaused(MusicPlayerState state) {
      if (state is ValuedMusicState)
        return PausedMusicState(state.duration, state.value);
      return null;
    }

    if (event is NativeStateChangedEvent) {
      switch (event.state) {
        case NativePlayerState.stopped:
          yield StoppedMusicState(state.duration);
          break;
        case NativePlayerState.playing:
          yield PlayingMusicState(
              state.duration ?? Duration(seconds: 10), Duration.zero);
          break;
        case NativePlayerState.paused:
          yield _yieldPaused(state);
          break;
        case NativePlayerState.completed:
          yield IdleMusicState(state.duration ?? Duration.zero);
          break;
      }
    }
  }
}
