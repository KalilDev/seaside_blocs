import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import 'enums.dart';

@immutable
abstract class SettingsManagerState extends Equatable {
  SettingsManagerState(
      {this.themeOptions, this.textAlign, this.fontSize, this.targetPlatform});
  final ThemeMode themeOptions;
  final TextAlign textAlign;
  final FontSize fontSize;
  final TargetPlatform targetPlatform;
  @override
  List<Object> get props => [themeOptions,textAlign,fontSize,targetPlatform];
}

class PlaceholderSettingsManagerState extends SettingsManagerState {}

class LoadedSettingsManagerState extends SettingsManagerState {
  LoadedSettingsManagerState(
      {ThemeMode themeOptions, TextAlign textAlign, FontSize fontSize,TargetPlatform targetPlatform})
      : super(
            themeOptions: themeOptions,
            textAlign: textAlign,
            fontSize: fontSize,
            targetPlatform: targetPlatform);
}
