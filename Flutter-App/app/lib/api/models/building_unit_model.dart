import 'package:ssds_app/api/models/api_key_model.dart';
import 'package:ssds_app/api/models/base_entity_model.dart';
import 'package:ssds_app/api/models/room_model.dart';

import 'address_model.dart';
import 'automation_setting.dart';
import 'building_model.dart';
import 'fire_alarm.dart';
import 'mqtt_connection_data.dart';

class BuildingUnitModel extends BaseEntity {
  List<RoomModel>? rooms;
  String? buildingId;
  BuildingModel? building;
  AddressModel? address;
  List<FireAlarm>? fireAlarms;
  bool? sendPreAlarm;
  bool? sendMqttInfo;
  String? mqttText;
  List<ApiKeyModel>? apiKeys;
  List<MqttConnectionData>? mqttConnectionData;
  PreAlarmAutomationSetting? preAlarmAutomationSetting;
  AutomationSetting? automationSetting;




  BuildingUnitModel(
      {
      super.id,
      super.name,
      super.description,
      super.createdAt,
      super.updatedAt,
      this.rooms,
      this.buildingId,
      this.building,
      this.address,
      this.fireAlarms,
      this.sendPreAlarm,
      this.sendMqttInfo,
      this.mqttText,
      this.apiKeys,
      this.mqttConnectionData,
      this.preAlarmAutomationSetting,
      this.automationSetting});


  BuildingUnitModel.fromJson(Map<String, dynamic> json) {
    super.id = json['id'];
    super.name = json['name'];
    super.description = json['description'];
    super.createdAt = DateTime.parse(json['createdAt'].toString());
    super.updatedAt = DateTime.parse(json['updatedAt'].toString());
    rooms = <RoomModel>[];
    if (json['rooms'] != null) {
      json['rooms'].forEach((v) {
        rooms!.add(RoomModel.fromJson(v));
      });
    }
    buildingId = json['buildingId'];
    building = json['building'] != null
        ? BuildingModel.fromJson(json['building'])
        : null;
    address =
        json['address'] != null ? AddressModel.fromJson(json['address']) : null;
    fireAlarms = <FireAlarm>[];
    if (json['fireAlarms'] != null) {
      json['fireAlarms'].forEach((v) {
        fireAlarms!.add(FireAlarm.fromJson(v));
      });
    }
    sendPreAlarm = json['sendPreAlarm'];
    sendMqttInfo = json['sendMqttInfo'];
    automationSetting = json['automationSetting'] != null
        ? AutomationSetting.fromJson(json['automationSetting'])
        : null;
    apiKeys = <ApiKeyModel>[];
    if (json['apiKeys'] != null) {
      json['apiKeys'].forEach((v) {
        apiKeys!.add(ApiKeyModel.fromJson(v));
      });
    }
    mqttConnectionData = <MqttConnectionData>[];
    if (json['mqttConnectionData'] != null) {
      json['mqttConnectionData'].forEach((v) {
        mqttConnectionData!.add(MqttConnectionData.fromJson(v));
      });
    }
    preAlarmAutomationSetting = json['preAlarmAutomationSetting'] != null
        ? PreAlarmAutomationSetting.fromJson(json['preAlarmAutomationSetting'])
        : null;
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = super.id;
    data['name'] = super.name;
    data['description'] = super.description;
    data['createdDate'] = super.createdAt;
    data['updatedDate'] = super.updatedAt;
    if (rooms != null) {
      data['rooms'] = rooms!.map((v) => v.toJson()).toList();
    }
     data['buildingId'] = buildingId;
    if (building != null) {
      data['building'] = building!.toJson();
    }
    if (address != null) {
      data['address'] = address!.toJson();
    }
    if (fireAlarms != null) {
      data['fireAlarms'] = fireAlarms!.map((v) => v.toJson()).toList();
    }
    data['sendPreAlarm'] = sendPreAlarm;
    data['sendMqttInfo'] = sendMqttInfo;
    data['mqttText'] = mqttText;
    if (apiKeys != null) {
      data['apiKeys'] = apiKeys!.map((v) => v.toJson()).toList();
    }
    if (mqttConnectionData != null) {
      data['mqttConnectionData'] =
          mqttConnectionData!.map((v) => v.toJson()).toList();
    }
    if (preAlarmAutomationSetting != null) {
      data['preAlarmAutomationSetting'] = preAlarmAutomationSetting!.toJson();
    }
    if (automationSetting != null) {
      data['automationSetting'] = automationSetting!.toJson();
    }
    return data;
  }

  Map<String, dynamic> toCreateJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = super.name;
    data['description'] = super.description;
    return data;
  }
}
