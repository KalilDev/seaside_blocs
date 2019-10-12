enum FontSize { smallest, small, normal, big, biggest }
enum TextAlign { left, right, center, justify }
enum ThemeMode { system, light, dark}

enum TargetPlatform {
  android,
  iOS,
}

const Map<FontSize, double> kSizeFactorMap = {
  FontSize.smallest: 0.9,
  FontSize.small: 1.0,
  FontSize.normal: 1.2,
  FontSize.big: 1.3,
  FontSize.biggest: 1.5
};
