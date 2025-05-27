import 'dart:convert';

class OfflineRequest {
  String data;
  String requestType;

  OfflineRequest({required this.data, required this.requestType});

  factory OfflineRequest.fromJSON(String json) {
    final data = jsonDecode(json);
    return OfflineRequest(data: data['data'], requestType: data['requestType']);
  }

  String toJSON() => jsonEncode(<String, String>{
      'data': data,
      'requestType': requestType,
    });
}
