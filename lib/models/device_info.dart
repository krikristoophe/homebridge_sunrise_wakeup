import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:homebridge_sunrise_wakeup/models/device_characteristic.dart';

part 'device_info.freezed.dart';
part 'device_info.g.dart';

@freezed
class DeviceInfo with _$DeviceInfo {
  const factory DeviceInfo({
    required String uniqueId,
    required String serviceName,
    @JsonKey(name: 'serviceCharacteristics')
    required List<DeviceCharacteristic> characteristics,
  }) = _DeviceInfo;

  const DeviceInfo._();

  factory DeviceInfo.fromJson(Map<String, dynamic> json) =>
      _$DeviceInfoFromJson(json);

  bool get isColorControllable => characteristics
      .where(
        (DeviceCharacteristic characteristic) =>
            characteristic.type == DeviceCharacteristicType.Hue,
      )
      .isNotEmpty;
}

extension DeviceInfoList on Iterable<DeviceInfo> {
  Iterable<DeviceInfo> get colorControllable => where(
        (DeviceInfo device) => device.isColorControllable,
      );

  Iterable<DeviceInfo> get temperatureControllable => where(
        (DeviceInfo device) => !device.isColorControllable,
      );

  Iterable<String> get ids => map((DeviceInfo device) => device.uniqueId);
}
