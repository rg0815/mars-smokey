import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:ssds_app/api/models/smoke_detector_model.dart';
import 'package:ssds_app/api/repositories/smoke_detector_repository.dart';
import 'package:ssds_app/helper/auth.dart';
import 'package:ssds_app/helper/dialog_helper.dart';
import 'package:ssds_app/screens/fire_alarm/fire_alarm_screen.dart';
import 'package:ssds_app/services/service_locator.dart';

import '../../api/models/fire_alarm.dart';
import '../../api/models/responses/response_model.dart';
import '../../api/repositories/fire_alarm_repository.dart';
import '../../components/snackbar/snackbar.dart';
import '../../components/theme_helper.dart';
import '../../helper/multi_tenant_notifier.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late Future<ResponseModel> _sdResponse;
  late Future<ResponseModel> _fireAlarmResponse;

  Future<ResponseModel> getSmokeDetectors() async {
    return locator
        .get<SmokeDetectorRepository>()
        .getSmokeDetectors(ref.read(multiTenantProvider).selectedTenantId);
  }

  Future<ResponseModel> fetchFireAlarms() async {
    var selectedTenant = ref.read(multiTenantProvider).selectedTenantId;
    if (selectedTenant != AppAuth.getUser().tenantId) {
      return locator
          .get<FireAlarmRepository>()
          .getActiveFireAlarms(tenantId: selectedTenant);
    }

    return locator.get<FireAlarmRepository>().getActiveFireAlarms();
  }

  @override
  void initState() {
    super.initState();
    ref.read(multiTenantProvider);
    _sdResponse = getSmokeDetectors();
    _fireAlarmResponse = fetchFireAlarms();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(multiTenantProvider);
    if (notifier.selectedTenant == null || notifier.selectedTenantId.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Text("Bitte wählen Sie einen Mandanten aus"),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [Center(child: CircularProgressIndicator())],
          )
        ],
      );
    }

    return FutureBuilder(
        future: Future.wait([
          _sdResponse,
          _fireAlarmResponse,
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          } else {
            var sdData = snapshot.data![0];
            var fireAlarmData = snapshot.data![1];

            if (!sdData.success!) {
              return Center(
                  child: Text(sdData.errorMessage ?? "Unbekannter Fehler."));
            } else {
              if (!fireAlarmData.success!) {
                return Center(
                    child: Text(
                        fireAlarmData.errorMessage ?? "Unbekannter Fehler."));
              } else {
                var smokeDetectors = sdData.data as List<SmokeDetectorModel>;
                var fireAlarms = fireAlarmData.data as List<FireAlarm>;

                var isFireAlarmActive = fireAlarms.isNotEmpty;
                var activeSmokeDetectors = smokeDetectors
                    .where((sd) => sd.state == SmokeDetectorState.alert)
                    .toList();
                var isBatteryLow = smokeDetectors.where((sd) =>
                    sd.batteryLevel! < 20 && sd.model!.supportsBatteryAlarm!);
                var needsMaintenance = [];
                var needsBatteryChange = [];

                for (var sd in smokeDetectors) {
                  if (sd.lastMaintenance == null) {
                    needsMaintenance.add(sd);
                  } else {
                    var nextMaintenance = sd.lastMaintenance!
                        .add(Duration(days: sd.model!.maintenanceInterval!));
                    if (nextMaintenance.isBefore(DateTime.now())) {
                      needsMaintenance.add(sd);
                    }
                  }

                  if (sd.lastBatteryReplacement == null &&
                      sd.model!.supportsBatteryAlarm!) {
                    needsBatteryChange.add(sd);
                  } else {
                    var nextBatteryChange = sd.lastBatteryReplacement!.add(
                        Duration(days: sd.model!.batteryReplacementInterval!));
                    if (nextBatteryChange.isBefore(DateTime.now()) &&
                        sd.model!.supportsBatteryAlarm!) {
                      needsBatteryChange.add(sd);
                    }
                  }
                }

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView(
                    children: [
                      Column(
                        children: isFireAlarmActive
                            ? [
                                Card(
                                  child: ListTile(
                                      tileColor: Colors.red.shade800,
                                      leading: Icon(
                                        Icons.local_fire_department,
                                        color: Colors.red.shade100,
                                        size: 30,
                                      ),
                                      title: Text(
                                          "Achtung, ${fireAlarms.length} Feueralarm(e) aktiv!",
                                          style:
                                              const TextStyle(fontSize: 24))),
                                ),
                                const Divider(),
                                Column(
                                  children: fireAlarms.map<Widget>((alarm) {
                                    return Card(
                                      color: Colors.white24,
                                      child: ListTile(
                                        visualDensity:
                                            VisualDensity.comfortable,
                                        selectedColor:
                                            ThemeHelper.theme.primaryColor,
                                        leading: Icon(
                                            Icons.local_fire_department,
                                            color: Colors.red,
                                            size: 30),
                                        title: Text(
                                          'Gebäudeeinheit: ${alarm.buildingUnit!.name!}',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18),
                                        ),
                                        subtitle: Text(
                                            'Anzahl ausgelöster Melder: ${alarm.alarmedDetectors!.length}'),
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      FireAlarmScreen(
                                                          fireAlarm: alarm)));
                                        },
                                        trailing: Icon(
                                          Icons.arrow_forward_ios,
                                          color: Colors.white,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 20),
                                  child: ResponsiveGridRow(
                                      children: activeSmokeDetectors
                                          .map<ResponsiveGridCol>((detector) {
                                    return ResponsiveGridCol(
                                        xs: 12,
                                        sm: 12,
                                        md: 6,
                                        lg: 6,
                                        child: Container(
                                            // height: 100,
                                            alignment: const Alignment(0, 0),
                                            child: Card(
                                              child: ListTile(
                                                leading: Icon(
                                                    Icons.smoking_rooms,
                                                    color: Colors.red),
                                                title: Text(
                                                    'Rauchmelder: ${detector.name}'),
                                                subtitle: Text(
                                                    'Ort: ${detector.toLocation()}'),
                                              ),
                                            )));
                                  }).toList()),
                                )
                              ]
                            : [
                                ListTile(
                                  tileColor: Colors.green.shade800,
                                  leading: Icon(
                                    Icons.check,
                                    color: Colors.green.shade100,
                                    size: 30,
                                  ),
                                  title: const Text(
                                      "Es wurde kein Feuer gemeldet",
                                      style: TextStyle(fontSize: 24)),
                                  subtitle: Text(
                                    "Status: Ok. Stand: ${DateTime.now().toLocal()}",
                                  ),
                                )
                              ],
                      ),
                      const Divider(),
                      isBatteryLow.isNotEmpty
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      'Rauchmelder mit niedrigem Batteriestand:',
                                      style: TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Column(
                                    children:
                                        isBatteryLow.map<Widget>((detector) {
                                      return ListTile(
                                        leading: const Icon(Icons.battery_alert,
                                            color: Colors.red),
                                        title: Text(
                                            'Rauchmelder: ${detector.name}'),
                                        subtitle: Text(
                                            'Ort: ${detector.toLocation()}'),
                                      );
                                    }).toList(),
                                  ),
                                  const Divider(),
                                ])
                          : const SizedBox(),
                      needsMaintenance.isNotEmpty
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      'Rauchmelder, die eine Wartung benötigen:',
                                      style: TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Column(
                                    children: needsMaintenance
                                        .map<Widget>((detector) {
                                      return ListTile(
                                        leading: const Icon(Icons.build,
                                            color: Colors.red),
                                        title: Text(
                                            'Rauchmelder: ${detector.name}'),
                                        subtitle: Text(
                                            'Ort: ${detector.toLocation()}'),
                                      );
                                    }).toList(),
                                  ),
                                  const Divider(),
                                ])
                          : const SizedBox(),
                      needsBatteryChange.isNotEmpty
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      'Rauchmelder, die einen Batteriewechsel benötigen:',
                                      style: TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Column(
                                    children: needsBatteryChange
                                        .map<Widget>((detector) {
                                      return ListTile(
                                        leading: const Icon(Icons.change_circle,
                                            color: Colors.red),
                                        title: Text(
                                            'Rauchmelder: ${detector.name}'),
                                        subtitle: Text(
                                            'Ort: ${detector.toLocation()}'),
                                      );
                                    }).toList(),
                                  ),
                                  const Divider(),
                                ])
                          : const SizedBox(),
                    ],
                  ),
                );
              }
            }
          }
          return const Center(child: CircularProgressIndicator());
        });
  }
}
