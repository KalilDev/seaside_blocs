import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './bloc.dart';

const Map<Type, String> _kTypeKeyMap = {
  PreferredBrightness: 'themeOptions',
  PreferredTextAlign: 'textAlign',
  FontSize: 'fontSize',
  AbstractTargetPlatform: 'targetPlatform',
  DemoModeState: 'demoState'
};
const Map<Type, int> _kTypeDefaultMap = {
  PreferredBrightness: 0,
  PreferredTextAlign: 0,
  FontSize: 2,
  AbstractTargetPlatform: 0,
  DemoModeState: 0
};

class SettingsManagerBloc extends Bloc<SettingsManagerEvent, SettingsManagerState> {
  SettingsManagerBloc([this.prefs]);
  SharedPreferences prefs;

  void _initialize() async {
    prefs = await SharedPreferences.getInstance();
    add(LoadedSettingsEvent(
        themeOptions: PreferredBrightness.values[getInt<PreferredBrightness>()],
        textAlign: PreferredTextAlign.values[getInt<PreferredTextAlign>()],
        fontSize: FontSize.values[getInt<FontSize>()],
        targetPlatform: AbstractTargetPlatform.values[getInt<AbstractTargetPlatform>()],
        demoState: DemoModeState.fromInt(getInt<DemoModeState>())
    ));
  }

  @override
  SettingsManagerState get initialState {
    _initialize();
    return LoadedSettingsManagerState(
      themeOptions: PreferredBrightness.values[_kTypeDefaultMap[PreferredBrightness]],
      textAlign: PreferredTextAlign.values[_kTypeDefaultMap[PreferredTextAlign]],
      fontSize: FontSize.values[_kTypeDefaultMap[FontSize]],
      targetPlatform: AbstractTargetPlatform.values[_kTypeDefaultMap[AbstractTargetPlatform]],
      demoState: DemoModeState.fromInt(_kTypeDefaultMap[DemoModeState])
    );
  }

  int getInt<T>() {
    int i;
    try {
      i = prefs?.getInt(_kTypeKeyMap[T]);
    } catch (e) {}
    return i ?? _kTypeDefaultMap[T];
  }

  void setInt<T>(int i) {
    try {
      prefs.setInt(_kTypeKeyMap[T], i);
    } catch (e) {}
  }

  _updateTheme(PreferredBrightness brightness) {
    setInt<PreferredBrightness>(PreferredBrightness.values.indexOf(brightness));
  }

  _updateAlignment(PreferredTextAlign textAlign) {
    setInt<PreferredTextAlign>(PreferredTextAlign.values.indexOf(textAlign));
  }

  _updateFontSize(FontSize fontSize) {
    setInt<FontSize>(FontSize.values.indexOf(fontSize));
  }

  _updatePlatform(AbstractTargetPlatform targetPlatform) {
    setInt<AbstractTargetPlatform>(AbstractTargetPlatform.values.indexOf(targetPlatform));
  }

  _updateDemoState(DemoModeState state) {
    setInt<DemoModeState>(state.toInt());
  }

  @override
  Stream<SettingsManagerState> mapEventToState(
    SettingsManagerEvent event,
  ) async* {
    if (event is LoadedSettingsEvent) {
      yield LoadedSettingsManagerState(
          themeOptions: event.themeOptions,
          textAlign: event.textAlign,
          fontSize: event.fontSize,
          targetPlatform: event.targetPlatform,
          demoState: event.demoState);
    }
    if (event is UpdateThemeEvent) {
      _updateTheme(event.themeOptions);
      yield state.copyWith(themeOptions: event.themeOptions);
    }
    if (event is UpdateAlignmentEvent) {
      _updateAlignment(event.textAlign);
      yield state.copyWith(textAlign: event.textAlign);
    }
    if (event is UpdateFontSizeEvent) {
      _updateFontSize(event.fontSize);
      yield state.copyWith(fontSize: event.fontSize);
    }
    if (event is UpdatePlatformEvent) {
      _updatePlatform(event.targetPlatform);
      yield state.copyWith(targetPlatform: event.targetPlatform);
    }
    if (event is ShowedInitialTutorialEvent) {
      final DemoModeState newState = state.demoState.copyWith(didShowInitialTutorial: true);
      _updateDemoState(newState);
      yield state.copyWith(demoState: newState);
    }
    if (event is ResetTutorialEvent) {
      yield state.copyWith(demoState: DemoModeState.fromInt(0));
    }
  }
}
