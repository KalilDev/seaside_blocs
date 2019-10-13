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
    try {
      PreferredBrightness options = event.themeOptions;
      PreferredTextAlign align = event.textAlign;
      FontSize size = event.fontSize;
      AbstractTargetPlatform platform = event.targetPlatform;
      if (options == null) {
        final int themeOptions = getInt('themeOptions');
        options = themeOptions == null
            ? null
            : PreferredBrightness.values.elementAt(themeOptions);
      } else {
        prefs.setInt('themeOptions', PreferredBrightness.values.indexOf(options));
      }
      if (align == null) {
        final int textAlign = getInt('textAlign');
        align =
            textAlign == null ? null : PreferredTextAlign.values.elementAt(textAlign);
      } else {
        prefs.setInt('textAlign', PreferredTextAlign.values.indexOf(align));
      }
      if (size == null) {
        final int fontSize = getInt('fontSize');
        size = fontSize == null ? null : FontSize.values.elementAt(fontSize);
      } else {
        prefs.setInt('fontSize', FontSize.values.indexOf(size));
      }
      if (platform == null) {
        final int targetPlatform = getInt('targetPlatform');
        platform = targetPlatform == null ? null : AbstractTargetPlatform.values.elementAt(targetPlatform);
      } else {
        prefs.setInt('targetPlatform', AbstractTargetPlatform.values.indexOf(platform));
      }
      return LoadedSettingsManagerState(
          themeOptions: options, textAlign: align, fontSize: size,targetPlatform: platform);
    } catch (e) {
      return LoadedSettingsManagerState();
    }
  }

  _initialize() {
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
    dispatch(LoadedSettingsEvent(
        themeOptions: options, textAlign: align, fontSize: size,targetPlatform: platform));
  }

  @override
  SettingsManagerState get initialState {
    _initialize();
    return PlaceholderSettingsManagerState();
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
