import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import 'enums.dart';

@immutable
abstract class SettingsManagerState extends Equatable {
  SettingsManagerState(
      {this.themeOptions, this.textAlign, this.fontSize, this.targetPlatform, this.demoState});
  final PreferredBrightness themeOptions;
  final PreferredTextAlign textAlign;
  final FontSize fontSize;
  final AbstractTargetPlatform targetPlatform;
  final DemoModeState demoState;

  SettingsManagerState copyWith({PreferredBrightness themeOptions, PreferredTextAlign textAlign, FontSize fontSize,AbstractTargetPlatform targetPlatform,DemoModeState demoState});

  @override
  List<Object> get props => [themeOptions,textAlign,fontSize,targetPlatform,demoState];
}

class LoadedSettingsManagerState extends SettingsManagerState {
  LoadedSettingsManagerState(
      {PreferredBrightness themeOptions, PreferredTextAlign textAlign, FontSize fontSize,AbstractTargetPlatform targetPlatform, DemoModeState demoState})
      : super(
            themeOptions: themeOptions,
            textAlign: textAlign,
            fontSize: fontSize,
            targetPlatform: targetPlatform,
            demoState: demoState);

  @override
  LoadedSettingsManagerState copyWith({PreferredBrightness themeOptions, PreferredTextAlign textAlign, FontSize fontSize,AbstractTargetPlatform targetPlatform, DemoModeState demoState}) {
    return LoadedSettingsManagerState(themeOptions: themeOptions ?? this.themeOptions,
        textAlign: textAlign ?? this.textAlign,
        fontSize: fontSize ?? this.fontSize,
        targetPlatform: targetPlatform ?? this.targetPlatform,
        demoState: demoState ?? this.demoState);
  }
}
