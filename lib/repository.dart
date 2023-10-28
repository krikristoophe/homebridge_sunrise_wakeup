import 'dart:async';

import 'package:homebridge_sunrise_wakeup/models/device_characteristic.dart';
import 'package:homebridge_sunrise_wakeup/models/device_info.dart';
import 'package:homebridge_sunrise_wakeup/models/environnement.dart';
import 'package:homebridge_sunrise_wakeup/models/login_response.dart';
import 'package:homebridge_sunrise_wakeup/remote_datasource.dart';

class Repository {
  Repository({
    required this.environnement,
    RemoteDatasource? remoteDatasource,
  }) : _remoteDatasource = remoteDatasource ??
            RemoteDatasource(
              environnement: environnement,
            );

  final Environnement environnement;
  final RemoteDatasource _remoteDatasource;

  Timer? _loginTimer;

  Future<void> login(String username, String password) async {
    _loginTimer?.cancel();

    await _triggerLogin(username, password);

    _loginTimer = Timer.periodic(
      const Duration(hours: 3),
      (timer) => _triggerLogin(username, password),
    );
  }

  Future<void> _triggerLogin(String username, String password) async {
    final LoginResponse loginResponse = await _remoteDatasource.login(
      username,
      password,
    );
    HomebridgeAuthInterceptor.instance.authToken = loginResponse.accessToken;
  }

  Future<DeviceInfo> getDeviceInfo(String uniqueId) {
    return _remoteDatasource.getDeviceInfo(uniqueId);
  }

  Future<List<DeviceInfo>> getDevicesInfo(Iterable<String> uniqueIds) {
    return Future.wait(
      uniqueIds.map(
        (String uniqueId) => _remoteDatasource.getDeviceInfo(uniqueId),
      ),
    );
  }

  Future<void> _setDevicesCharacteristic({
    required Iterable<String> uniqueIds,
    required DeviceCharacteristicType type,
    required dynamic value,
  }) {
    return Future.wait(
      uniqueIds.map(
        (String uniqueId) => _remoteDatasource.setDeviceCharacteristic(
          uniqueId: uniqueId,
          type: type,
          value: value,
        ),
      ),
    );
  }

  Future<void> setDeviceBrightness(String uniqueId, int brightness) {
    return _remoteDatasource.setDeviceCharacteristic(
      uniqueId: uniqueId,
      type: DeviceCharacteristicType.Brightness,
      value: brightness,
    );
  }

  Future<void> setDevicesBrightness(
    Iterable<String> uniqueIds,
    int brightness,
  ) {
    return _setDevicesCharacteristic(
      uniqueIds: uniqueIds,
      type: DeviceCharacteristicType.Brightness,
      value: brightness,
    );
  }

  Future<void> setDeviceHue(String uniqueId, double hue) {
    return _remoteDatasource.setDeviceCharacteristic(
      uniqueId: uniqueId,
      type: DeviceCharacteristicType.Hue,
      value: hue,
    );
  }

  Future<void> setDevicesHue(Iterable<String> uniqueIds, double hue) {
    return _setDevicesCharacteristic(
      uniqueIds: uniqueIds,
      type: DeviceCharacteristicType.Hue,
      value: hue,
    );
  }

  Future<void> setDeviceSaturation(String uniqueId, double saturation) {
    return _remoteDatasource.setDeviceCharacteristic(
      uniqueId: uniqueId,
      type: DeviceCharacteristicType.Saturation,
      value: saturation,
    );
  }

  Future<void> setDevicesSaturation(
    Iterable<String> uniqueIds,
    double saturation,
  ) {
    return _setDevicesCharacteristic(
      uniqueIds: uniqueIds,
      type: DeviceCharacteristicType.Saturation,
      value: saturation,
    );
  }

  Future<void> setDeviceColorTemperature(String uniqueId, int temperature) {
    return _remoteDatasource.setDeviceCharacteristic(
      uniqueId: uniqueId,
      type: DeviceCharacteristicType.ColorTemperature,
      value: temperature,
    );
  }

  Future<void> setDevicesColorTemperature(
    Iterable<String> uniqueIds,
    int temperature,
  ) {
    return _setDevicesCharacteristic(
      uniqueIds: uniqueIds,
      type: DeviceCharacteristicType.ColorTemperature,
      value: temperature,
    );
  }
}
