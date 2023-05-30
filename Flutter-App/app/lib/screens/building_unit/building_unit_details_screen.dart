import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ssds_app/api/models/building_unit_model.dart';
import 'package:ssds_app/api/models/room_model.dart';
import 'package:ssds_app/api/repositories/building_unit_repository.dart';
import 'package:ssds_app/components/custom_app_bar.dart';
import 'package:ssds_app/components/theme_helper.dart';
import 'package:ssds_app/screens/building_unit/NotificationScreen.dart';
import 'package:ssds_app/screens/room/room_details_screen.dart';
import 'package:ssds_app/services/service_locator.dart';

import '../../api/models/responses/response_model.dart';
import '../../components/custom_icon_button.dart';
import '../../components/custom_outline_button.dart';
import '../../helper/dialog_helper.dart';
import '../generic/add_new_entity.dart';

class BuildingUnitDetailsScreen extends ConsumerStatefulWidget {
  const BuildingUnitDetailsScreen({Key? key, required this.buildingUnitId})
      : super(key: key);
  final String buildingUnitId;

  @override
  _BuildingUnitDetailsScreenState createState() =>
      _BuildingUnitDetailsScreenState();
}

class _BuildingUnitDetailsScreenState
    extends ConsumerState<BuildingUnitDetailsScreen> {
  late Future<ResponseModel> _response;
  final ScrollController controller = ScrollController();
  final _fabKey = GlobalKey<ExpandableFabState>();
  final _formKey = GlobalKey<FormState>();
  bool _status = true;
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final TextEditingController _mqttPayloadController = TextEditingController();
  late BuildingUnitModel _buildingUnit;

  @override
  void initState() {
    super.initState();
    _response = getBuildingUnit();
  }

  Future<ResponseModel> getBuildingUnit() async {
    return locator
        .get<BuildingUnitRepository>()
        .getBuildingUnitById(widget.buildingUnitId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _response,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        }
        if (snapshot.hasData) {
          BuildingUnitModel buildingUnit =
              (snapshot.data as ResponseModel).data!;
          _buildingUnit = buildingUnit;

          nameController.text = buildingUnit.name!;
          descriptionController.text = buildingUnit.description!;

          return Scaffold(
            appBar: CustomAdaptiveAppBar(
              centerTitle: true,
              title: const Text("Gebäudeeinheit"),
              iconThemeData: const IconThemeData(color: Colors.white),
              automaticallyImplyLeading: false,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  context.go('/buildingUnit');
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
                        tooltip: "Raum hinzufügen",
                        heroTag: null,
                        child: const Icon(Icons.add),
                        onPressed: () async {
                          final state = _fabKey.currentState;
                          if (state != null) {
                            state.toggle();

                            await Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => AddNewEntityScreen(
                                    entityType: RoomModel,
                                    parentEntityId: buildingUnit.id!)));

                            setState(() {
                              _response = getBuildingUnit();
                            });
                          }
                        }),
                  ],
                ),
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  toolbarHeight: 40,
                  backgroundColor:
                      ThemeHelper.theme.primaryColorDark.withOpacity(0.5),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(buildingUnit.name!),
                      const SizedBox(
                        width: 5,
                      ),
                      Tooltip(
                          message:
                              "Erstellt: ${buildingUnit.createdAt!.toLocal()}\nGeändert: ${buildingUnit.updatedAt!.toLocal()}",
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Flexible(
                                            flex: 2,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 10.0),
                                              child: TextFormField(
                                                decoration:
                                                    const InputDecoration(
                                                        hintText:
                                                            "Name eingeben"),
                                                enabled: !_status,
                                                controller: nameController,
                                                validator: (value) {
                                                  if (value!.isEmpty) {
                                                    return 'Bitte einen Namen eingeben';
                                                  }
                                                  return null;
                                                },
                                                onSaved: (value) {
                                                  buildingUnit.name = value;
                                                },
                                              ),
                                            ),
                                          ),
                                          Flexible(
                                            flex: 2,
                                            child: TextFormField(
                                              decoration: const InputDecoration(
                                                  hintText:
                                                      "Beschreibung eingeben"),
                                              enabled: !_status,
                                              controller: descriptionController,
                                              onSaved: (value) {
                                                buildingUnit.description =
                                                    value;
                                              },
                                            ),
                                          ),
                                        ],
                                      )),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SwitchListTile(
                                        title: const Text('Voralarm senden'),
                                        value: _buildingUnit.sendPreAlarm!,
                                        onChanged: _status
                                            ? null
                                            : (value) {
                                                setState(() {
                                                  _buildingUnit.sendPreAlarm =
                                                      value;
                                                });
                                              }),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SwitchListTile(
                                        title: const Text(
                                            'MQTT-Informationen senden'),
                                        value: _buildingUnit.sendMqttInfo!,
                                        onChanged: _status
                                            ? null
                                            : (value) {
                                                setState(() {
                                                  _buildingUnit.sendMqttInfo =
                                                      value;
                                                });
                                              }),
                                  ),
                                  _buildingUnit.sendMqttInfo!
                                      ? Padding(
                                          padding: const EdgeInsets.only(
                                              left: 25.0,
                                              right: 25.0,
                                              top: 2.0),
                                          child: Column(
                                            children: [
                                              TextFormField(
                                                enabled: !_status,
                                                controller:
                                                    _mqttPayloadController,
                                                decoration:
                                                    const InputDecoration(
                                                  labelText: "MQTT-Payload",
                                                ),
                                                maxLines: 8,
                                              ),
                                              const Text(
                                                  "Hier können Sie die MQTT-Informationen anpassen. Die Informationen werden als JSON-String gesendet. "
                                                  "Folgende Variablen können verwendet werden: \n\n"
                                                  "  - {{location}} -  Ort\n"
                                                  "  - {{building}} - Gebäude\n"
                                                  "  - {{buildingUnit}} - Gebäudeteil\n"
                                                  "  - {{room}} - Raum\n"
                                                  "  - {{isExpanding}} - Brand breitet sich aus\n"
                                                  "  - {{isProbableFalseAlarm}} - eventuell Fehlalarm\n"
                                                  "  - {{isEvacuation}} - Evakuierung des Gebäudes\n"),
                                            ],
                                          ),
                                        )
                                      : Container(),
                                  const Divider(),
                                  _buildingUnit.sendPreAlarm! ?
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 25.0,
                                        right: 25.0,
                                        top: 2.0),
                                    child: Card(
                                      child: ListTile(
                                        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                                        title: Text('Voralarm-Benachrichtigungen',
                                            style: ThemeHelper.listTileTitle()),
                                        onTap: () async {
                                          await Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      NotificationScreen(
                                                          automationSettingId: null,
                                                          preAlarmAutomationSettingId:
                                                              _buildingUnit.preAlarmAutomationSetting)));
                                        },
                                      ),
                                    ),
                                  ): Container(),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 25.0,
                                        right: 25.0,
                                        top: 2.0),
                                    child: Card(
                                      child: ListTile(
                                        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                                        title: Text('Benachrichtigungen',
                                            style: ThemeHelper.listTileTitle()),
                                        onTap: () async {
                                          await Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      NotificationScreen(
                                                          automationSettingId: _buildingUnit.automationSetting,
                                                          preAlarmAutomationSettingId: null)));
                                        },
                                      ),
                                    ),
                                  ),
                                  !_status ? _getActionButtons() : Container(),
                                ])),
                      ),
                      Divider(),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 25.0, right: 25.0, top: 25.0),
                        child: AutoSizeText(
                          "Räume",
                          maxLines: 1,
                          style: ThemeHelper.theme.textTheme.headlineSmall,
                        ),
                      ),
                      // Expanded(
                      //   child:
                      ListView(
                        shrinkWrap: true,
                        padding: const EdgeInsets.only(
                            left: 25.0, right: 25.0, top: 25.0),
                        children: getRoomItems(buildingUnit),
                        // ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(
                            left: 25.0, right: 25.0, top: 25.0),
                        child: AutoSizeText(
                          "API-Schlüssel",
                          maxLines: 1,
                          style: ThemeHelper.theme.textTheme.headlineSmall,
                        ),
                      ),
                      // Expanded(
                      //   child:
                      ListView(
                        shrinkWrap: true,
                        padding: const EdgeInsets.only(
                            left: 25.0, right: 25.0, top: 25.0),
                        children: getApiKeys(buildingUnit),
                        // ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(
                            left: 25.0, right: 25.0, top: 25.0),
                        child: AutoSizeText(
                          "MQTT-Verbindungen",
                          maxLines: 1,
                          style: ThemeHelper.theme.textTheme.headlineSmall,
                        ),
                      ),
                      // Expanded(
                      //   child:
                      ListView(
                        shrinkWrap: true,
                        padding: const EdgeInsets.only(
                            left: 25.0, right: 25.0, top: 25.0),
                        children: getMQTTConnectionData(buildingUnit),
                        // ),
                      ),
                    ])),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  getRoomItems(BuildingUnitModel buildingUnit) {
    var items = <Widget>[];

    if (buildingUnit.rooms!.isEmpty) {
      items.add(Card(
        child: ListTile(
          title:
              Text("Keine Räume vorhanden", style: ThemeHelper.listTileTitle()),
          subtitle: Text("Erstellen Sie einen Raum",
              style: ThemeHelper.listTileSubtitle()),
          visualDensity: VisualDensity.comfortable,
          selectedColor: ThemeHelper.theme.primaryColor,
          hoverColor: ThemeHelper.theme.hoverColor,
          leading: const SizedBox(
            height: double.infinity,
            child: Icon(
              Icons.window,
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

    for (var room in buildingUnit.rooms!) {
      items.add(Card(
          child: ListTile(
        title: Text(room.name!, style: ThemeHelper.listTileTitle()),
        subtitle:
            Text(room.description!, style: ThemeHelper.listTileSubtitle()),
        visualDensity: VisualDensity.comfortable,
        selectedColor: ThemeHelper.theme.primaryColor,
        hoverColor: ThemeHelper.theme.hoverColor,
        leading: const SizedBox(
          height: double.infinity,
          child: Icon(
            Icons.window,
            color: Colors.white,
            size: 30,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
                tooltip: "Raum löschen",
                icon: Icon(
                  Icons.delete_outline,
                  color: ThemeHelper.theme.primaryColor,
                ),
                onPressed: () async {
                  var res = await DialogHelper().showDeleteDialog(context,
                      "Raum löschen", "Möchten Sie den Raum wirklich löschen?");

                  // if (res) {
                  //   var delRes = await locator
                  //       .get<BuildingRepository>()
                  //       .deleteBuilding(building.id!);
                  //   if (delRes.success!) {
                  //     DialogHelper().displayErrorSnackBar(
                  //         context, "Gebäude wurde gelöscht", ContentType.success);
                  //
                  //     ref.read(multiTenantProvider.notifier).setSelectedTenant(tenant.id!);
                  //   } else {
                  //     DialogHelper().displayErrorSnackBar(
                  //         context, delRes.errorMessage!, ContentType.failure);
                  //   }
                }),
            const SizedBox(width: 10),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
            ),
          ],
        ),
        onTap: () async {
          await Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => RoomDetailsScreen(roomId: room.id!)));

          setState(() {
            _response = getBuildingUnit();
          });
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

  getApiKeys(BuildingUnitModel buildingUnit) {
    return <Widget>[];
  }

  getMQTTConnectionData(BuildingUnitModel buildingUnit) {
    return <Widget>[];
  }
}
