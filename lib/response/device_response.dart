class DeviceResponse {
  final String errorCode;
  final String result;
  final String message;
  final String _id;

  DeviceResponse(this.errorCode, this.result, this.message, this._id);

  DeviceResponse.fromJson(Map<String, dynamic> json)
      : errorCode = json['errorCode'],
        result = json['result'],
        message = json['message'],
        _id = json['_id'];
}
