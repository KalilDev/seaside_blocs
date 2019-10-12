export 'music_player_bloc.dart';
export 'music_player_event.dart';
export 'music_player_state.dart';

/// Self explanatory. Indicates the state of the audio player.
enum NativePlayerState {
  stopped,
  playing,
  paused,
  completed,
}
