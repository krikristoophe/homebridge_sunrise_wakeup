import 'package:freezed_annotation/freezed_annotation.dart';

part 'device_characteristic.freezed.dart';
part 'device_characteristic.g.dart';

enum DeviceCharacteristicType {
  // ignore: constant_identifier_names
  Brightness,
  // ignore: constant_identifier_names
  Hue,
  // ignore: constant_identifier_names
  ColorTemperature,
  // ignore: constant_identifier_names
  Saturation,
  // ignore: constant_identifier_names
  On,
}

@freezed
class DeviceCharacteristic with _$DeviceCharacteristic {
  const factory DeviceCharacteristic({
    required DeviceCharacteristicType type,
  }) = _DeviceCharacteristic;

  factory DeviceCharacteristic.fromJson(Map<String, dynamic> json) =>
      _$DeviceCharacteristicFromJson(json);
}
