import 'dart:async';

import 'package:cron/cron.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:homebridge_sunrise_wakeup/models/scene_parameters.dart';

part 'scene_task.freezed.dart';

@freezed
class SceneTask with _$SceneTask {
  const factory SceneTask({
    required ScheduledTask cronTask,
    required Timer? timer,
    required SceneParameters parameters,
    required Iterable<String> deviceIds,
  }) = _SceneTask;
}
