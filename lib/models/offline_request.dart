import 'dart:convert';

class OfflineRequest {
  String resource;
  String data;
  String requestType;

  OfflineRequest(
      {required this.resource, required this.data, required this.requestType});

  factory OfflineRequest.fromJSON(String json) {
    final data = jsonDecode(json);
    return OfflineRequest(
        resource: data['resource'],
        data: data['data'],
        requestType: data['requestType']);
  }

  String toJSON() {
    return jsonEncode({
      "resource": resource,
      "data": data,
      "requestType": requestType,
    });
  }
}
