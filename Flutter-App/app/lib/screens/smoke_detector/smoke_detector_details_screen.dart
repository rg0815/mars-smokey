import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ssds_app/api/models/smoke_detector_maintenance_model.dart';
import 'package:ssds_app/api/repositories/room_repository.dart';
import 'package:ssds_app/api/repositories/smoke_detector_repository.dart';
import 'package:ssds_app/components/custom_app_bar.dart';
import 'package:ssds_app/components/theme_helper.dart';
import 'package:ssds_app/helper/auth.dart';
import 'package:ssds_app/main.dart';
import 'package:ssds_app/services/service_locator.dart';

import '../../api/models/smoke_detector_model.dart';
import '../../api/repositories/building_repository.dart';
import '../../api/repositories/building_unit_repository.dart';
import '../../components/custom_icon_button.dart';
import '../../components/custom_outline_button.dart';
import '../../components/snackbar/snackbar.dart';
import '../../helper/dialog_helper.dart';
import 'smoke_detector_maintenance_screen.dart';

class SmokeDetectorDetailsScreen extends ConsumerStatefulWidget {
  const SmokeDetectorDetailsScreen({Key? key, required this.smokeDetector})
      : super(key: key);
  final SmokeDetectorModel smokeDetector;

  @override
  _SmokeDetectorDetailsScreenState createState() =>
      _SmokeDetectorDetailsScreenState();
}

class _SmokeDetectorDetailsScreenState
    extends ConsumerState<SmokeDetectorDetailsScreen> {
  final _fabKey = GlobalKey<ExpandableFabState>();
  final _formKey = GlobalKey<FormState>();
  bool _status = true;
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  late SmokeDetectorModel _smokeDetectorModel;
  bool _isTestActive = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _smokeDetectorModel = widget.smokeDetector;

    nameController.text = _smokeDetectorModel.name!;
    descriptionController.text = _smokeDetectorModel.description!;

    return Scaffold(
      appBar: CustomAdaptiveAppBar(
        centerTitle: true,
        title: const Text("Rauchmelder"),
        iconThemeData: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
          },
        ),
      ),
      body: Scaffold(
          floatingActionButtonLocation: ExpandableFab.location,
          floatingActionButton: ExpandableFab(
            distance: 60,
            childrenOffset: const Offset(6, 6),
            key: _fabKey,
            type: ExpandableFabType.left,
            overlayStyle: ExpandableFabOverlayStyle(blur: 2),
            children: [
              FloatingActionButton.small(
                tooltip: "Bearbeiten",
                heroTag: null,
                child: const Icon(Icons.edit),
                onPressed: () {
                  final state = _fabKey.currentState;
                  if (state != null) {
                    state.toggle();
                  }
                  setState(() {
                    _status = false;
                  });
                },
              ),
              FloatingActionButton.small(
                  tooltip: "Wartung hinzufügen",
                  heroTag: null,
                  child: const Icon(Icons.smoking_rooms),
                  onPressed: () async {
                    final state = _fabKey.currentState;
                    if (state != null) {
                      state.toggle();
                    }

                    var model = SmokeDetectorMaintenanceModel();
                    model.smokeDetector = _smokeDetectorModel;
                    model.time = DateTime.now();
                    model.userId = AppAuth.getUser().id;
                    model.comment = "";

                    var roomres = await locator.get<RoomRepository>().getRoomById(_smokeDetectorModel.roomId!);
                    if(!roomres.success!){
                      return;
                    }
                    var room = roomres.data;
                    var bUres = await locator.get<BuildingUnitRepository>().getBuildingUnitById(room!.buildingUnitId!);
                    if(!bUres.success!){
                      return;
                    }
                    var buildingUnit = bUres.data;
                    var bres= await locator.get<BuildingRepository>().getBuildingById(buildingUnit!.buildingId!);
                    if(!bres.success!){
                      return;
                    }
                    var building = bres.data;



                    await Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => SmokeDetectorMaintenanceScreen(
                            smokeDetectorMaintenanceModel: model,
                            isNew: true,
                            buildingName: building!.name!,
                            buildingUnitName:buildingUnit!.name!,
                            roomName: room!.name!,
                            address: building!.address!
                                .toLocationString())));
                  }),
              _smokeDetectorModel.model!.supportsRemoteAlarm!
                  ? FloatingActionButton.small(
                      tooltip:
                          _isTestActive ? "Test beenden" : "Rauchmelder testen",
                      heroTag: null,
                      backgroundColor: _isTestActive ? Colors.red : null,
                      foregroundColor: _isTestActive ? Colors.white : null,
                      onPressed: () async {
                        final state = _fabKey.currentState;
                        if (state != null) {
                          state.toggle();

                          setState(() {
                            _isTestActive = !_isTestActive;
                          });

                          if (_isTestActive) {
                            var res = await locator
                                .get<SmokeDetectorRepository>()
                                .testAlarm(_smokeDetectorModel.id!);
                            if (!res.success!) {
                              DialogHelper().displayErrorSnackBar(
                                  context,
                                  res.errorMessage ?? "Unbekannter Fehler.",
                                  ContentType.failure);
                            } else {
                              DialogHelper().displayErrorSnackBar(
                                  context,
                                  "Test erfolgreich gestartet.",
                                  ContentType.success);
                            }
                          } else {
                            var res = await locator
                                .get<SmokeDetectorRepository>()
                                .stopTestAlarm(_smokeDetectorModel.id!);
                            if (!res.success!) {
                              DialogHelper().displayErrorSnackBar(
                                  context,
                                  res.errorMessage ?? "Unbekannter Fehler.",
                                  ContentType.failure);
                            } else {
                              DialogHelper().displayErrorSnackBar(
                                  context,
                                  "Test erfolgreich beendet.",
                                  ContentType.success);
                            }
                          }
                        }
                      },
                      child: _isTestActive
                          ? const Icon(Icons.stop)
                          : const Icon(Icons.play_arrow))
                  : Container(),
            ],
          ),
          appBar: AppBar(
            automaticallyImplyLeading: false,
            toolbarHeight: 40,
            backgroundColor: getBackgroundColor(),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_smokeDetectorModel.name!),
                const SizedBox(
                  width: 5,
                ),
                Tooltip(
                    message:
                        "Erstellt: ${_smokeDetectorModel.createdAt!.toLocal()}\nGeändert: ${_smokeDetectorModel.updatedAt!.toLocal()}",
                    child: const Icon(
                      Icons.info_outline,
                      color: Colors.white,
                      size: 16,
                    ))
              ],
            ),
            centerTitle: true,
          ),
          body: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.only(top: 25.0),
              children: [
                Form(
                  key: _formKey,
                  child: Padding(
                      padding: const EdgeInsets.only(bottom: 25.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                                padding: const EdgeInsets.only(
                                    left: 25.0, right: 25.0, top: 25.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: const [
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        'Name',
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        'Beschreibung',
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                )),
                            Padding(
                                padding: const EdgeInsets.only(
                                    left: 25.0, right: 25.0, top: 2.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      flex: 2,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 10.0),
                                        child: TextFormField(
                                          decoration: const InputDecoration(
                                              hintText: "Name eingeben"),
                                          enabled: !_status,
                                          controller: nameController,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'Bitte einen Namen eingeben';
                                            }
                                            return null;
                                          },
                                          onSaved: (value) {
                                            _smokeDetectorModel.name = value;
                                          },
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      flex: 2,
                                      child: TextFormField(
                                        decoration: const InputDecoration(
                                            hintText: "Beschreibung eingeben"),
                                        enabled: !_status,
                                        controller: descriptionController,
                                        onSaved: (value) {
                                          _smokeDetectorModel.description =
                                              value;
                                        },
                                      ),
                                    ),
                                  ],
                                )),
                            !_status ? _getActionButtons() : Container(),
                          ])),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 25.0, right: 25.0, top: 25.0),
                  child: AutoSizeText(
                    "Wartungen",
                    maxLines: 1,
                    style: ThemeHelper.theme.textTheme.headlineSmall,
                  ),
                ),
                // Expanded(
                //   child:
                ListView(
                  shrinkWrap: true,
                  padding:
                      const EdgeInsets.only(left: 25.0, right: 25.0, top: 25.0),
                  children: getMaintenances(),
                  // ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 25.0, right: 25.0, top: 25.0),
                  child: AutoSizeText(
                    "Alarme",
                    maxLines: 1,
                    style: ThemeHelper.theme.textTheme.headlineSmall,
                  ),
                ),
                // Expanded(
                //   child:
                ListView(
                  shrinkWrap: true,
                  padding:
                      const EdgeInsets.only(left: 25.0, right: 25.0, top: 25.0),
                  children: getAlarms(),
                  // ),
                ),
              ])),
    );
  }

  getAlarms() {
    var items = <Widget>[];

    if (_smokeDetectorModel.events!.isEmpty) {
      items.add(Card(
        child: ListTile(
          title: Text("Keine Alarme vorhanden",
              style: ThemeHelper.listTileTitle()),
          visualDensity: VisualDensity.comfortable,
          selectedColor: ThemeHelper.theme.primaryColor,
          hoverColor: ThemeHelper.theme.hoverColor,
          leading: const SizedBox(
            height: double.infinity,
            child: Icon(
              Icons.smoke_free,
              color: Colors.white,
              size: 30,
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.white,
          ),
          onTap: () {
            // context.go('/new/buildingUnit/${building.id!}');
          },
        ),
      ));
      return items;
    }

    for (var alarm in _smokeDetectorModel.events!) {
      items.add(Card(
          child: ListTile(
        title: Text(alarm.startTime.toString(),
            style: ThemeHelper.listTileTitle()),
        subtitle: Text(alarm.fireAlarm!.endTime.toString(),
            style: ThemeHelper.listTileSubtitle()),
        visualDensity: VisualDensity.comfortable,
        selectedColor: ThemeHelper.theme.primaryColor,
        hoverColor: ThemeHelper.theme.hoverColor,
        leading: const SizedBox(
          height: double.infinity,
          child: Icon(
            Icons.smoking_rooms,
            color: Colors.white,
            size: 30,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white,
        ),
        onTap: () {
          // context.go('/smokedetector/${detector.id}');
        },
      )));
    }

    items.add(const SizedBox(height: 50));

    return items;
  }

  getMaintenances() {
    var items = <Widget>[];

    if (_smokeDetectorModel.maintenances!.isEmpty) {
      items.add(Card(
        child: ListTile(
          title: Text("Keine Wartungseinträge vorhanden",
              style: ThemeHelper.listTileTitle()),
          visualDensity: VisualDensity.comfortable,
          selectedColor: ThemeHelper.theme.primaryColor,
          hoverColor: ThemeHelper.theme.hoverColor,
          leading: const SizedBox(
            height: double.infinity,
            child: Icon(
              Icons.build,
              color: Colors.white,
              size: 30,
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.white,
          ),
          onTap: () async {
            var model = SmokeDetectorMaintenanceModel();
            model.smokeDetector = _smokeDetectorModel;
            model.time = DateTime.now();
            model.comment = "";
            model.userId = AppAuth.getUser().id!;

            var roomres = await locator.get<RoomRepository>().getRoomById(_smokeDetectorModel.roomId!);
            if(!roomres.success!){
              return;
            }
            var room = roomres.data;
            var bUres = await locator.get<BuildingUnitRepository>().getBuildingUnitById(room!.buildingUnitId!);
            if(!bUres.success!){
              return;
            }
            var buildingUnit = bUres.data;
            var bres= await locator.get<BuildingRepository>().getBuildingById(buildingUnit!.buildingId!);
            if(!bres.success!){
              return;
            }
            var building = bres.data;





            await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => SmokeDetectorMaintenanceScreen(
                    smokeDetectorMaintenanceModel: model,
                    isNew: true,
                    buildingName:
                        building!.name!,
                    buildingUnitName:
                        buildingUnit!.name!,
                    roomName: room!.name!,
                    address: building!.address!
                        .toLocationString())));
            setState(() {});
          },
        ),
      ));
      return items;
    }

    for (var maintenance in _smokeDetectorModel.maintenances!) {
      items.add(Card(
          child: ListTile(
        title: Text(maintenance.time.toString(),
            style: ThemeHelper.listTileTitle()),
        subtitle:
            Text(maintenance.comment!, style: ThemeHelper.listTileSubtitle()),
        visualDensity: VisualDensity.comfortable,
        selectedColor: ThemeHelper.theme.primaryColor,
        hoverColor: ThemeHelper.theme.hoverColor,
        leading: const SizedBox(
          height: double.infinity,
          child: Icon(
            Icons.build,
            color: Colors.white,
            size: 30,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white,
        ),
        onTap: () async {
          maintenance.smokeDetector = _smokeDetectorModel;

          var roomres = await locator.get<RoomRepository>().getRoomById(_smokeDetectorModel.roomId!);
          if(!roomres.success!){
            return;
          }
          var room = roomres.data;
          var bUres = await locator.get<BuildingUnitRepository>().getBuildingUnitById(room!.buildingUnitId!);
          if(!bUres.success!){
            return;
          }
          var buildingUnit = bUres.data;
          var bres= await locator.get<BuildingRepository>().getBuildingById(buildingUnit!.buildingId!);
          if(!bres.success!){
            return;
          }
          var building = bres.data;


          await Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => SmokeDetectorMaintenanceScreen(
                  smokeDetectorMaintenanceModel: maintenance,
                  isNew: false,
                  buildingName:
                      building!.name!,
                  buildingUnitName:
                 buildingUnit!.name!,
                  roomName: room!.name!,
                  address: building!.address!
                      .toLocationString())));
        },
      )));
    }

    items.add(const SizedBox(height: 50));
    return items;
  }

  Widget _getActionButtons() {
    return Padding(
      padding: const EdgeInsets.only(left: 25.0, right: 25.0, top: 45.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: CustomIconOutlineButton(
                text: "Abbrechen",
                iconColor: Colors.grey,
                iconData: Icons.cancel_outlined,
                textStyle: const TextStyle(color: Colors.grey),
                onPressed: () {
                  setState(() {
                    _status = true;
                    FocusScope.of(context).requestFocus(FocusNode());
                  });
                },
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: CustomIconButton(
                  text: "Speichern",
                  iconColor: Colors.white,
                  color: ThemeHelper.theme.primaryColorDark,
                  iconData: Icons.save,
                  textStyle: const TextStyle(color: Colors.white),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();

                      // var res = await locator
                      //     .get<BuildingUnitRepository>()
                      //     .updateBuildingUnit(_buildingUnit.id!, _buildingUnit);

                      // if (!res.success! || res.data == null) {
                      //   DialogHelper().displayErrorSnackBar(
                      //       context,
                      //       res.errorMessage ?? "Unbekannter Fehler.",
                      //       ContentType.failure);
                      // } else {
                      //
                      //   DialogHelper().displayErrorSnackBar(context,
                      //       "Aktualisierung erfolgreich.", ContentType.success);
                      //
                      //   var building = res.data! as BuildingModel;
                      //
                      //   setState(() {
                      //     _building = building;
                      //   });

                      // context.go("/building/details/${building.id}");

                      //
                      //     DialogHelper().displayErrorSnackBar(context,
                      //         "Aktualisierung erfolgreich.", ContentType.success);
                      //
                      //     setState(() {
                      //       firstNameController.text = userModel.firstName!;
                      //       lastNameController.text = userModel.lastName!;
                      //       // MainScreen.changePage(1);
                      //     });
                    }
                    setState(() {
                      _status = true;
                      FocusScope.of(context).requestFocus(FocusNode());
                    });
                  }
                  // },
                  ),
            ),
          ),
        ],
      ),
    );
  }

  getBackgroundColor() {
    if (_smokeDetectorModel.state == SmokeDetectorState.alert) {
      return ThemeHelper.theme.primaryColorDark.withOpacity(0.5);
    } else if (_smokeDetectorModel.state == SmokeDetectorState.normal) {
      return Colors.green;
    } else {
      return Colors.orange;
    }
  }
}
