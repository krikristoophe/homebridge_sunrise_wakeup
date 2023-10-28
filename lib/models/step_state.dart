import 'package:homebridge_sunrise_wakeup/models/color.dart';

abstract class StepState {
  const StepState({
    required this.brightness,
  });

  final int brightness;
}

class ColorStepState extends StepState {
  const ColorStepState({
    required super.brightness,
    required this.color,
  });
  final Color color;

  double get hue => color.hue;
  double get saturation => color.saturation;

  @override
  String toString() {
    return '''
ColorStepState(
brightness: $brightness, 
hue: $hue, 
saturation: $saturation)
      '''
        .replaceAll('\n', '')
        .trim();
  }
}

class TemperatureStepState extends StepState {
  const TemperatureStepState({
    required super.brightness,
    required this.temperature,
  });
  final int temperature;

  @override
  String toString() {
    return '''
TemperatureStepState(
brightness: $brightness, 
temperature: $temperature)
      '''
        .replaceAll('\n', '')
        .trim();
  }
}
