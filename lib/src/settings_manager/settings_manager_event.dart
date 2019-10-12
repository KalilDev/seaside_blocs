import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import './enums.dart';

@immutable
abstract class SettingsManagerEvent extends Equatable {
  SettingsManagerEvent(
      {this.themeOptions, this.textAlign, this.fontSize, this.targetPlatform});
  final ThemeMode themeOptions;
  final TextAlign textAlign;
  final FontSize fontSize;
  final TargetPlatform targetPlatform;
  @override
  List<Object> get props => [themeOptions,textAlign,fontSize,targetPlatform];
}

class LoadedSettingsEvent extends SettingsManagerEvent {
  LoadedSettingsEvent(
      {ThemeMode themeOptions, TextAlign textAlign, FontSize fontSize, TargetPlatform targetPlatform})
      : super(
            themeOptions: themeOptions,
            textAlign: textAlign,
            fontSize: fontSize,
            targetPlatform: targetPlatform);
}

class UpdateSettingsEvent extends SettingsManagerEvent {
  UpdateSettingsEvent(
      {ThemeMode themeOptions, TextAlign textAlign, FontSize fontSize, TargetPlatform targetPlatform})
      : super(
            themeOptions: themeOptions,
            textAlign: textAlign,
            fontSize: fontSize,
            targetPlatform: targetPlatform);
}
