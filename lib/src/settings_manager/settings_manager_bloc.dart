import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:key_value_store/key_value_store.dart';
import 'package:seaside_blocs/src/singletons.dart';

import './bloc.dart';

abstract class SettingsManagerBloc
    extends Bloc<SettingsManagerEvent, SettingsManagerState> {}

class LocalSettingsManagerBloc extends SettingsManagerBloc {
  LocalSettingsManagerBloc([this.prefs]);
  KeyValueStore prefs;
  LoadedSettingsManagerState _updateSettings(UpdateSettingsEvent event) {
      final PreferredBrightness options = event.themeOptions ?? currentState.themeOptions;
      final PreferredTextAlign align = event.textAlign ?? currentState.textAlign;
      final FontSize size = event.fontSize ?? currentState.fontSize;
      final AbstractTargetPlatform platform = event.targetPlatform ?? currentState.targetPlatform;
      if (event.themeOptions != null)
        prefs.setInt('themeOptions', PreferredBrightness.values.indexOf(options));
      if (event.textAlign != null)
        prefs.setInt('textAlign', PreferredTextAlign.values.indexOf(align));
      if (event.fontSize != null)
        prefs.setInt('fontSize', FontSize.values.indexOf(size));
      if (event.targetPlatform != null)
        prefs.setInt('targetPlatform', AbstractTargetPlatform.values.indexOf(platform));

      return LoadedSettingsManagerState(
          themeOptions: options, textAlign: align, fontSize: size,targetPlatform: platform);
  }

  SettingsManagerState _initialize() {
    prefs ??= keyValueStore;
    final int themeOptions = getInt('themeOptions');
    final PreferredBrightness options =
        themeOptions == null ? null : PreferredBrightness.values.elementAt(themeOptions);
    final int textAlign = getInt('textAlign');
    final PreferredTextAlign align =
        textAlign == null ? null : PreferredTextAlign.values.elementAt(textAlign);
    final int fontSize = getInt('fontSize');
    final FontSize size =
        fontSize == null ? null : FontSize.values.elementAt(fontSize);
    final int targetPlatform = getInt('targetPlatform');
    final AbstractTargetPlatform platform =
    targetPlatform == null ? null : AbstractTargetPlatform.values.elementAt(targetPlatform);
    return LoadedSettingsManagerState(
        themeOptions: options ?? PreferredBrightness.system, textAlign: align ?? PreferredTextAlign.justify, fontSize: size ?? FontSize.normal,targetPlatform: platform ?? AbstractTargetPlatform.android);
  }

  @override
  SettingsManagerState get initialState {
    return _initialize();
  }

  int getInt(String key) {
    int i;
    try {
      i = prefs?.getInt(key);
    } catch (e) {}
    return i;
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
          targetPlatform: event.targetPlatform);
    }
    if (event is UpdateSettingsEvent) {
      yield _updateSettings(event);
    }
  }
}
