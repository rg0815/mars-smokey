import 'dart:convert';

class CustomMqttMessage {
  MqttMessageAction? action;
  String? clientId;
  String? payload;

  CustomMqttMessage({this.action, this.clientId, this.payload});

  CustomMqttMessage.fromJson(String json){
    final Map<String, dynamic> data = jsonDecode(json);
    action = data['Action'] != null ? MqttMessageAction.values[data['Action']] : null;
    clientId = data['ClientId'];
    payload = data['Payload'];
  }

  Map<String, dynamic> toJson(){
    final Map<String, dynamic> data = <String, dynamic>{};
    data['action'] = action;
    data['clientId'] = clientId;
    data['payload'] = payload;
    return data;
  }
}

enum MqttMessageAction {
  R_Connected,
  S_UsernameInfo,
  R_Info,
  R_Alert,
  R_Alarm,
  S_StartPairingGateway,
  S_StopPairingGateway,
  S_StartPairingSmokeDetector,
  S_StopPairingSmokeDetector,
  R_PairingSmokeDetectorInfo,
  S_GatewayInitialized,
  S_PerformAlarm,
  S_StopAlarm,
  SF_PairingSmokeDetectorInfo,
}
