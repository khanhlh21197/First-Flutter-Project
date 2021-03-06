class DeviceResponse {
  final String errorCode;
  final String result;
  final String message;
  List<dynamic> id;
  String idnha;

  DeviceResponse(this.errorCode, this.result, this.message, this.id);

  DeviceResponse.fromJson(Map<String, dynamic> json)
      : errorCode = json['errorCode'],
        result = json['result'],
        message = json['message'],
        id = json['id'],
        idnha = json['idnha'];
}
