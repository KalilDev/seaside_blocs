import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import './enums.dart';

@immutable
abstract class SettingsManagerEvent extends Equatable {
  SettingsManagerEvent(
      {this.themeOptions, this.textAlign, this.fontSize, this.targetPlatform});
  final PreferredBrightness themeOptions;
  final PreferredTextAlign textAlign;
  final FontSize fontSize;
  final AbstractTargetPlatform targetPlatform;
  @override
  List<Object> get props => [themeOptions,textAlign,fontSize,targetPlatform];
}

class LoadedSettingsEvent extends SettingsManagerEvent {
  LoadedSettingsEvent(
      {PreferredBrightness themeOptions, PreferredTextAlign textAlign, FontSize fontSize, AbstractTargetPlatform targetPlatform})
      : super(
            themeOptions: themeOptions,
            textAlign: textAlign,
            fontSize: fontSize,
            targetPlatform: targetPlatform);
}

class UpdateSettingsEvent extends SettingsManagerEvent {
  UpdateSettingsEvent(
      {PreferredBrightness themeOptions, PreferredTextAlign textAlign, FontSize fontSize, AbstractTargetPlatform targetPlatform})
      : super(
            themeOptions: themeOptions,
            textAlign: textAlign,
            fontSize: fontSize,
            targetPlatform: targetPlatform);
}
