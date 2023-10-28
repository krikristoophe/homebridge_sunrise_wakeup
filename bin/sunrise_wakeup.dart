import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:easy_dart_logger/easy_dart_logger.dart';
import 'package:homebridge_sunrise_wakeup/db_manager.dart';
import 'package:homebridge_sunrise_wakeup/models/create_task_request.dart';
import 'package:homebridge_sunrise_wakeup/models/environnement.dart';
import 'package:homebridge_sunrise_wakeup/repository.dart';
import 'package:homebridge_sunrise_wakeup/tasks_manager.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

// on POST /task/:id
// create and schedule task with parameters

// on DELETE /task/:id
// delete and unschedule task

// TODO(christophe): stop task
// TODO(christophe): make another repo

Future<void> main(List<String> arguments) async {
  checkEnvironnement();
  final Environnement environnement = Environnement.fromEnv();

  final Repository repository = Repository(
    environnement: environnement,
  );

  final String dbFolder = Platform.environment['DB_DIRECTORY'] ?? '.';

  final DbManager database = DbManager(
    dbFolder: dbFolder,
  );

  await repository.login(
    Platform.environment['HOMEBRIDGE_USERNAME']!,
    Platform.environment['HOMEBRIDGE_PASSWORD']!,
  );

  await TasksManager.init(repository, database);

  final Router router = Router();

  router.post('/task/<id>', (Request request) async {
    routerLogger.debug('[POST] /${request.url.path}');
    final int id = int.parse(request.params['id']!);
    final String bodyStr = await request.readAsString();
    final CreateTaskRequest body = CreateTaskRequest.fromJson(
      jsonDecode(bodyStr) as Map<String, dynamic>,
    );
    await TasksManager.instance.createTask(
      id: id,
      parameters: body.sceneParameters,
      deviceIds: body.deviceIds,
      cronSchedule: body.cronSchedule,
    );

    return Response.ok(null);
  });

  router.delete('/task/<id>', (Request request) async {
    routerLogger.debug('[DELETE] /${request.url.path}');
    final int id = int.parse(request.params['id']!);

    await TasksManager.instance.deleteTask(id);

    return Response.ok(null);
  });

  final int port = int.parse(Platform.environment['PORT'] ?? '3000');

  await io.serve(router, '0.0.0.0', port);
}

final routerLogger = DartLogger(
  configuration: const DartLoggerConfiguration(
    format: LogFormat.inline,
    name: 'router',
  ),
);

void checkEnvironnement() {
  const List<String> requiredVariables = [
    'HOMEBRIDGE_USERNAME',
    'HOMEBRIDGE_PASSWORD',
    'HOMEBRIDGE_URI',
  ];

  for (final String variable in requiredVariables) {
    if (!Platform.environment.containsKey(variable)) {
      throw ArgumentError('$variable required and not provided');
    }
  }
}
