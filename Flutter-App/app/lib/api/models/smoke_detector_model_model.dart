import 'base_entity_model.dart';

class SmokeDetectorModelModel extends BaseEntity {
  CommunicationType? communicationType;
  bool? supportsRemoteAlarm;
  bool? supportsBatteryAlarm;
  int? batteryReplacementInterval;
  int? maintenanceInterval;
  SmokeDetectorProtocol? smokeDetectorProtocol;

  SmokeDetectorModelModel(
      {super.id,
      super.name,
      super.description,
      super.createdAt,
      super.updatedAt,
      this.communicationType,
      this.supportsRemoteAlarm,
      this.supportsBatteryAlarm,
      this.smokeDetectorProtocol,
      this.batteryReplacementInterval,
      this.maintenanceInterval});

  SmokeDetectorModelModel.fromJson(Map<String, dynamic> json){
    super.id = json['id'];
    super.name = json['name'];
    super.description = json['description'];
    super.createdAt = DateTime.parse(json['createdAt'].toString());
    super.updatedAt = DateTime.parse(json['updatedAt'].toString());
    supportsRemoteAlarm = json['supportsRemoteAlarm'];
    supportsBatteryAlarm = json['supportsBatteryAlarm'];

    // Convert integer to CommunicationType enum
    if(json['communicationType'] != null) {
      communicationType = CommunicationType.values[json['communicationType']];
    }

    // Convert integer to SmokeDetectorProtocol enum
    if(json['smokeDetectorProtocol'] != null) {
      smokeDetectorProtocol = SmokeDetectorProtocol.values[json['smokeDetectorProtocol']];
    }

    batteryReplacementInterval = json['batteryReplacementInterval'];
    maintenanceInterval = json['maintenanceInterval'];
  }

}

enum CommunicationType { Mhz433, Mhz868, Gira }
enum SmokeDetectorProtocol{RM175Rf, Fa22Rf, Gira}