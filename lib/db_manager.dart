import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:homebridge_sunrise_wakeup/models/scene_parameters.dart';
import 'package:sqlite3/sqlite3.dart';

class DbManager {
  DbManager({
    this.dbFolder = '.',
  }) : _db = sqlite3.open('$dbFolder/sunrise_wakeup.db') {
    _migrateDb();
  }

  final String dbFolder;

  late final Database _db;

  static const int _dbVersion = 1;

  void _migrateDb() {
    final int currentVersion = _db.userVersion;

    if (currentVersion < 1) {
      _db.execute('''
CREATE TABLE tasks(
  id INTEGER PRIMARY KEY,
  parameters TEXT NOT NULL,
  device_ids TEXT NOT NULL,
  cron_schedule TEXT NOT NULL
);
      ''');
    }

    _db.userVersion = _dbVersion;
  }

  void deleteTask(int id) {
    _db.prepare(
      '''
DELETE FROM tasks
WHERE id=?;
''',
      persistent: true,
      vtab: false,
    ).execute([id]);
  }

  void createTask({
    required int id,
    required SceneParameters parameters,
    required List<String> deviceIds,
    required String cronSchedule,
  }) {
    _db.prepare(
      '''
INSERT INTO tasks(id, parameters, device_ids, cron_schedule)
VALUES(?, ?, ?, ?);
''',
      persistent: true,
      vtab: false,
    ).execute(
      [
        id,
        jsonEncode(parameters.toJson()),
        json.encode(deviceIds),
        cronSchedule,
      ],
    );
  }

  Iterable<TaskDbRow> getTasks() {
    final result = _db.select(
      '''
SELECT * FROM tasks;
''',
    );

    return result.rows.whereNotNull().map((List<Object?> row) {
      return {
        'id': row[0]! as int,
        'parameters': row[1]! as String,
        'device_ids': row[2]! as String,
        'cron_schedule': row[3]! as String,
      };
    }).map((Map<String, dynamic> row) {
      final List<dynamic> deviceIds = json.decode(
        row['device_ids'] as String,
      ) as List<dynamic>;
      return (
        id: row['id'] as int,
        parameters: jsonDecode(row['parameters'] as String),
        deviceIds: deviceIds.cast<String>(),
        cronSchedule: row['cron_schedule'] as String
      );
    });
  }
}

typedef TaskDbRow = ({
  int id,
  Map<String, dynamic> parameters,
  List<String> deviceIds,
  String cronSchedule,
});
