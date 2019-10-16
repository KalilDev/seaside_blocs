import 'package:meta/meta.dart';

import './enums.dart';

@immutable
abstract class SettingsManagerEvent {}

class LoadedSettingsEvent extends SettingsManagerEvent {
  LoadedSettingsEvent(
      {this.themeOptions, this.textAlign, this.fontSize, this.targetPlatform});
  final PreferredBrightness themeOptions;
  final PreferredTextAlign textAlign;
  final FontSize fontSize;
  final AbstractTargetPlatform targetPlatform;
}

class UpdateThemeEvent extends SettingsManagerEvent {
  UpdateThemeEvent(this.themeOptions);
  final PreferredBrightness themeOptions;
}

class UpdateAlignmentEvent extends SettingsManagerEvent {
  UpdateAlignmentEvent(this.textAlign);
  final PreferredTextAlign textAlign;
}

class UpdateFontSizeEvent extends SettingsManagerEvent {
  UpdateFontSizeEvent(this.fontSize);
  final FontSize fontSize;
}

class UpdatePlatformEvent extends SettingsManagerEvent {
  UpdatePlatformEvent(this.targetPlatform);
  final AbstractTargetPlatform targetPlatform;
}