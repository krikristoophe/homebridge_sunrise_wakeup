import 'dart:async';

import 'package:cron/cron.dart';
import 'package:easy_dart_logger/easy_dart_logger.dart';
import 'package:homebridge_sunrise_wakeup/db_manager.dart';
import 'package:homebridge_sunrise_wakeup/models/device_info.dart';
import 'package:homebridge_sunrise_wakeup/models/scene_parameters.dart';
import 'package:homebridge_sunrise_wakeup/models/scene_task.dart';
import 'package:homebridge_sunrise_wakeup/models/step_state.dart';
import 'package:homebridge_sunrise_wakeup/repository.dart';

class TasksManager {
  TasksManager({
    required this.repository,
    required this.database,
  });
  static late final TasksManager instance;

  static final DartLogger _logger = DartLogger(
    configuration: const DartLoggerConfiguration(
      format: LogFormat.inline,
      name: 'tasks_manager',
    ),
  );

  static Future<void> init(Repository repository, DbManager database) async {
    TasksManager.instance = TasksManager(
      repository: repository,
      database: database,
    );

    final Iterable<TaskDbRow> existingTasks = database.getTasks();

    await Future.wait(
      existingTasks.map(
        (TaskDbRow task) => TasksManager.instance.createTask(
          id: task.id,
          parameters: SceneParameters.fromJson(task.parameters),
          deviceIds: task.deviceIds,
          cronSchedule: task.cronSchedule,
          saveInDatabase: false,
        ),
      ),
    );
  }

  final Repository repository;
  final DbManager database;

  final Map<int, SceneTask> tasks = {};

  final Cron cron = Cron();

  Future<void> createTask({
    required int id,
    required SceneParameters parameters,
    required Iterable<String> deviceIds,
    required String cronSchedule,
    bool saveInDatabase = true,
  }) async {
    _logger.info('Create task $id at $cronSchedule');
    await deleteTask(
      id,
      saveInDatabase: saveInDatabase,
    );
    final SceneTask task = SceneTask(
      cronTask: cron.schedule(
        Schedule.parse(cronSchedule),
        () => _runTask(id: id),
      ),
      timer: null,
      parameters: parameters,
      deviceIds: deviceIds,
    );
    tasks[id] = task;
    if (saveInDatabase) {
      database.createTask(
        id: id,
        parameters: parameters,
        deviceIds: deviceIds.toList(),
        cronSchedule: cronSchedule,
      );
    }
  }

  Future<void> deleteTask(
    int id, {
    bool saveInDatabase = true,
  }) async {
    final SceneTask? task = tasks.remove(id);

    if (task == null) {
      return;
    }

    _logger.info('Delete task $id');

    task.timer?.cancel();
    await task.cronTask.cancel();

    if (saveInDatabase) {
      database.deleteTask(id);
    }
  }

  Future<void> _runTask({
    required int id,
  }) async {
    _logger.info('Start run task $id');
    final SceneTask? task = tasks[id];

    if (task == null) {
      return;
    }

    final List<DeviceInfo> devices = await repository.getDevicesInfo(
      task.deviceIds,
    );

    final Timer timer = Timer.periodic(
      task.parameters.stepInterval,
      (timer) async {
        if (timer.tick > task.parameters.nbInterval) {
          timer.cancel();
          return;
        }

        final StepState step = task.parameters.calculateStep(timer.tick);

        await _applyStep(
          devices: devices,
          step: step,
        );
      },
    );

    tasks[id] = task.copyWith(timer: timer);

    while (timer.isActive) {
      await Future<void>.delayed(const Duration(seconds: 1));
    }

    _logger.info('Task $id ended');
  }

  Future<void> _applyStep({
    required Iterable<DeviceInfo> devices,
    required StepState step,
  }) async {
    if (step is ColorStepState) {
      return _applyColorStep(devices: devices, step: step);
    } else if (step is TemperatureStepState) {
      return _applyTemperatureStep(devices: devices, step: step);
    }
  }

  Future<void> _applyColorStep({
    required Iterable<DeviceInfo> devices,
    required ColorStepState step,
  }) async {
    final Iterable<String> colorableDeviceIds = devices.colorControllable.ids;

    await Future.wait([
      repository.setDevicesBrightness(
        colorableDeviceIds,
        step.brightness,
      ),
      repository.setDevicesHue(
        colorableDeviceIds,
        step.hue,
      ),
      repository.setDevicesSaturation(
        colorableDeviceIds,
        step.saturation * 100,
      ),
    ]);
  }

  Future<void> _applyTemperatureStep({
    required Iterable<DeviceInfo> devices,
    required TemperatureStepState step,
  }) async {
    final Iterable<String> notColorableDeviceIds =
        devices.temperatureControllable.ids;
    await Future.wait([
      repository.setDevicesColorTemperature(
        notColorableDeviceIds,
        step.temperature,
      ),
      repository.setDevicesBrightness(
        notColorableDeviceIds,
        step.brightness,
      ),
    ]);
  }
}
