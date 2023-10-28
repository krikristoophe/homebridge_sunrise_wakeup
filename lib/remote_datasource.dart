import 'package:dart_datasource_models/dart_datasource_models.dart';
import 'package:homebridge_sunrise_wakeup/models/device_characteristic.dart';
import 'package:homebridge_sunrise_wakeup/models/device_info.dart';
import 'package:homebridge_sunrise_wakeup/models/environnement.dart';
import 'package:homebridge_sunrise_wakeup/models/login_response.dart';

part 'remote_datasource.ddg.dart';

@DartGeneratorRemoteDatasource()
class RemoteDatasource with _$RemoteDatasource {
  const RemoteDatasource({
    required this.environnement,
  });

  @override
  final Environnement environnement;

  @DartGeneratorRequest(
    path: '/api/auth/login',
    method: HttpMethod.post,
  )
  Future<LoginResponse> login(String username, String password) => _login(
        RequestParameters(
          body: {
            'username': username,
            'password': password,
          },
        ),
      );

  @DartGeneratorRequest(
    path: '/api/accessories/:uniqueId',
    method: HttpMethod.get,
    authenticate: true,
  )
  Future<DeviceInfo> getDeviceInfo(String uniqueId) => _getDeviceInfo(
        RequestParameters(
          routeParams: {
            'uniqueId': uniqueId,
          },
        ),
      );

  @DartGeneratorRequest(
    path: '/api/accessories/:uniqueId',
    method: HttpMethod.put,
    authenticate: true,
    log: false,
  )
  Future<void> setDeviceCharacteristic({
    required String uniqueId,
    required DeviceCharacteristicType type,
    required dynamic value,
  }) =>
      _setDeviceCharacteristic(
        RequestParameters(
          routeParams: {
            'uniqueId': uniqueId,
          },
          body: {
            'characteristicType': type.name,
            'value': value,
          },
        ),
      );
}
