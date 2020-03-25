import 'package:seaside_blocs/src/singletons.dart';

enum FontSize { smallest, small, normal, big, biggest }
enum PreferredTextAlign { left, right, center, justify }
enum PreferredBrightness { system, light, dark}

enum AbstractTargetPlatform {
  android,
  iOS,
}

class DemoModeState {
  const DemoModeState({this.didShowInitialTutorial});
  final bool didShowInitialTutorial;

  factory DemoModeState.fromInt(int i) {
    if (isWeb)
      return DemoModeState(didShowInitialTutorial: true);

    if (i == 0) {
      /// Default
      return DemoModeState(didShowInitialTutorial: false);
    }
    final bool didShowInitialTutorial = i.remainder(2).abs() < 0.005;
    print(i.remainder(2).abs());
    return DemoModeState(didShowInitialTutorial: didShowInitialTutorial);
  }

  int toInt() {
    return didShowInitialTutorial ? 2 : 1;
  }

  DemoModeState copyWith({bool didShowInitialTutorial}) {
    return DemoModeState(
      didShowInitialTutorial: didShowInitialTutorial ?? this.didShowInitialTutorial
    );
  }
}

const Map<FontSize, double> kSizeFactorMap = {
  FontSize.smallest: 0.9,
  FontSize.small: 1.0,
  FontSize.normal: 1.2,
  FontSize.big: 1.3,
  FontSize.biggest: 1.5
};
