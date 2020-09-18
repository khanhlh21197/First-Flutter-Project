import 'package:my_first_flutter_project/model/device.dart';

class DeviceResponse {
  final String errorCode;
  final String result;
  final String message;
  final List<dynamic> id;

  DeviceResponse(this.errorCode, this.result, this.message, this.id);

  DeviceResponse.fromJson(Map<String, dynamic> json)
      : errorCode = json['errorCode'],
        result = json['result'],
        message = json['message'],
        id = json['id'];
}
