import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:homebridge_sunrise_wakeup/models/color.dart';
import 'package:homebridge_sunrise_wakeup/models/scene_parameters.dart';

part 'create_task_request.freezed.dart';
part 'create_task_request.g.dart';

@freezed
class CreateTaskRequest with _$CreateTaskRequest {
  const factory CreateTaskRequest({
    required SceneParametersType type,
    required List<String> deviceIds,
    required String cronSchedule,
    required int totalDuration, // seconds
    required int stepInterval, // seconds
    required int fromBrightness,
    required int toBrightness,

    // colored parameters
    required List<int>? fromColor,
    required List<int>? toColor,

    // temperature parameters
    required int? fromTemperature,
    required int? toTemperature,
  }) = _CreateTaskRequest;

  const CreateTaskRequest._();

  factory CreateTaskRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateTaskRequestFromJson(json);

  Duration get totalDurationFormatted => Duration(
        seconds: totalDuration,
      );

  SceneParameters get sceneParameters {
    final Duration stepIntervalFormatted = Duration(
      seconds: stepInterval,
    );
    switch (type) {
      case SceneParametersType.colored:
        return ColoredSceneParameters(
          fromColor: Color.rgb(fromColor!),
          toColor: Color.rgb(toColor!),
          fromBrightness: fromBrightness,
          toBrightness: toBrightness,
          totalDuration: totalDurationFormatted,
          stepInterval: stepIntervalFormatted,
        );
      case SceneParametersType.temperature:
        return TemperatureSceneParameters(
          fromTemperature: fromTemperature!,
          toTemperature: toTemperature!,
          fromBrightness: fromBrightness,
          toBrightness: toBrightness,
          totalDuration: totalDurationFormatted,
          stepInterval: stepIntervalFormatted,
        );
    }
  }
}
