import 'package:homebridge_sunrise_wakeup/models/color.dart';
import 'package:homebridge_sunrise_wakeup/models/step_state.dart';

enum SceneParametersType {
  colored,
  temperature;

  static SceneParametersType fromName(String name) {
    return SceneParametersType.values.firstWhere(
      (SceneParametersType type) => type.name == name,
    );
  }
}

abstract class SceneParameters {
  const SceneParameters({
    required this.fromBrightness,
    required this.toBrightness,
    required this.totalDuration,
    required this.stepInterval,
    required this.type,
  });

  factory SceneParameters.fromJson(Map<String, dynamic> json) {
    final SceneParametersType type = SceneParametersType.fromName(
      json['type'] as String,
    );

    switch (type) {
      case SceneParametersType.colored:
        return ColoredSceneParameters.fromJson(json);
      case SceneParametersType.temperature:
        return TemperatureSceneParameters.fromJson(json);
    }
  }

  final int fromBrightness;
  final int toBrightness;
  final Duration totalDuration;
  final Duration stepInterval;
  final SceneParametersType type;

  StepState calculateStep(int index);

  int get nbInterval =>
      (totalDuration.inSeconds / stepInterval.inSeconds).round();

  Map<String, dynamic> toJson() {
    return {
      'fromBrightness': fromBrightness,
      'toBrightness': toBrightness,
      'totalDuration': totalDuration.inSeconds,
      'stepInterval': stepInterval.inSeconds,
      'type': type.name,
    };
  }
}

class ColoredSceneParameters extends SceneParameters {
  const ColoredSceneParameters({
    required this.fromColor,
    required this.toColor,
    required super.fromBrightness,
    required super.toBrightness,
    required super.totalDuration,
    required super.stepInterval,
  }) : super(type: SceneParametersType.colored);

  factory ColoredSceneParameters.fromJson(Map<String, dynamic> json) {
    return ColoredSceneParameters(
      fromColor: Color.rgb((json['fromColor'] as List<dynamic>).cast<int>()),
      toColor: Color.rgb((json['toColor'] as List<dynamic>).cast<int>()),
      fromBrightness: json['fromBrightness'] as int,
      toBrightness: json['toBrightness'] as int,
      totalDuration: Duration(seconds: json['totalDuration'] as int),
      stepInterval: Duration(seconds: json['stepInterval'] as int),
    );
  }

  final Color fromColor;
  final Color toColor;

  @override
  ColorStepState calculateStep(int index) {
    final double percent = index / nbInterval;

    final Color stepColor = Color.gradient(
      from: fromColor,
      to: toColor,
      percent: percent,
    );

    final int stepBrightness =
        ((toBrightness - fromBrightness) * percent + fromBrightness).round();

    return ColorStepState(
      color: stepColor,
      brightness: stepBrightness,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'fromColor': fromColor.rgb,
      'toColor': toColor.rgb,
    };
  }
}

class TemperatureSceneParameters extends SceneParameters {
  const TemperatureSceneParameters({
    required this.fromTemperature,
    required this.toTemperature,
    required super.fromBrightness,
    required super.toBrightness,
    required super.totalDuration,
    required super.stepInterval,
  }) : super(type: SceneParametersType.temperature);

  factory TemperatureSceneParameters.fromJson(Map<String, dynamic> json) {
    return TemperatureSceneParameters(
      fromTemperature: json['fromTemperature'] as int,
      toTemperature: json['toTemperature'] as int,
      fromBrightness: json['fromBrightness'] as int,
      toBrightness: json['toBrightness'] as int,
      totalDuration: Duration(seconds: json['totalDuration'] as int),
      stepInterval: Duration(seconds: json['stepInterval'] as int),
    );
  }

  final int fromTemperature;
  final int toTemperature;

  @override
  TemperatureStepState calculateStep(int index) {
    final double percent = index / nbInterval;

    final int stepBrightness =
        ((toBrightness - fromBrightness) * percent + fromBrightness).round();

    final int stepTemperature =
        ((toTemperature - fromTemperature) * percent + fromTemperature).round();

    return TemperatureStepState(
      brightness: stepBrightness,
      temperature: stepTemperature,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'fromTemperature': fromTemperature,
      'toTemperature': toTemperature,
    };
  }
}
