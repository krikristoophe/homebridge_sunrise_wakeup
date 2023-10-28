import 'dart:math';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'color.freezed.dart';

@freezed
class Color with _$Color {
  const factory Color({
    @Default(0) int red,
    @Default(0) int green,
    @Default(0) int blue,
  }) = _Color;

  const Color._();

  factory Color.red() => const Color(red: 255);
  factory Color.green() => const Color(green: 255);
  factory Color.blue() => const Color(blue: 255);

  factory Color.gradient({
    required Color from,
    required Color to,
    required double percent,
  }) {
    return Color(
      red: (from.red + percent * (to.red - from.red)).round(),
      green: (from.green + percent * (to.green - from.green)).round(),
      blue: (from.blue + percent * (to.blue - from.blue)).round(),
    );
  }

  factory Color.rgb(List<int> rgb) {
    return Color(
      red: rgb[0],
      green: rgb[1],
      blue: rgb[2],
    );
  }

  List<int> get rgb => [red, green, blue];

  double get hue {
    final int mMax = [red, green, blue].reduce(max);
    final int mMin = [red, green, blue].reduce(min);

    final int c = mMax - mMin;

    late final double tPrime;

    if (mMax == red) {
      tPrime = ((green - blue) / c) % 6;
    } else if (mMax == green) {
      tPrime = (((blue - red) / c) + 2) % 6;
    } else if (mMax == blue) {
      tPrime = (((red - green) / c) + 4) % 6;
    } else {
      return 0;
    }

    return 60 * tPrime;
  }

  double get saturation {
    final int mMax = [red, green, blue].reduce(max);
    if (mMax == 0) {
      return 0;
    }
    final int mMin = [red, green, blue].reduce(min);

    final int c = mMax - mMin;

    return c / mMax;
  }
}

// H = hue = T
// S = saturation
// L = bridghtness
