import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_dialogs/dialogs.dart';
import 'package:material_dialogs/shared/types.dart';
import 'package:ssds_app/api/models/gateway_model.dart';
import 'package:ssds_app/api/models/room_model.dart';
import 'package:ssds_app/api/repositories/room_repository.dart';
import 'package:ssds_app/components/custom_app_bar.dart';
import 'package:ssds_app/components/theme_helper.dart';
import 'package:ssds_app/screens/gateway/pre_add_gateway.dart';
import 'package:ssds_app/services/service_locator.dart';

import '../../api/models/responses/response_model.dart';
import '../../api/repositories/gateway_repository.dart';
import '../../components/custom_icon_button.dart';
import '../../components/custom_outline_button.dart';
import '../../components/snackbar/snackbar.dart';
import '../../helper/dialog_helper.dart';
import '../../helper/multi_tenant_notifier.dart';
import '../smoke_detector/pre_add_smoke_detector.dart';

class RoomDetailsScreen extends ConsumerStatefulWidget {
  const RoomDetailsScreen({Key? key, required this.roomId}) : super(key: key);
  final String roomId;

  @override
  _RoomDetailsScreenState createState() => _RoomDetailsScreenState();
}

class _RoomDetailsScreenState extends ConsumerState<RoomDetailsScreen> {
  late Future<ResponseModel> _response;
  final ScrollController controller = ScrollController();
  final _fabKey = GlobalKey<ExpandableFabState>();
  final _formKey = GlobalKey<FormState>();
  bool _status = true;
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  late RoomModel _room;

  @override
  void initState() {
    super.initState();
    _response = getRoom();
  }

  Future<ResponseModel> getRoom() async {
    return locator.get<RoomRepository>().getRoomById(widget.roomId);
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(multiTenantProvider);

    return FutureBuilder(
      future: _response,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        }
        if (snapshot.hasData) {
          RoomModel roomModel = (snapshot.data as ResponseModel).data!;
          _room = roomModel;

          nameController.text = roomModel.name!;
          descriptionController.text = roomModel.description!;

          return Scaffold(
            appBar: CustomAdaptiveAppBar(
              centerTitle: true,
              title: const Text("Raum"),
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
                        tooltip: "Rauchmelder hinzufügen",
                        heroTag: null,
                        child: const Icon(Icons.smoking_rooms),
                        onPressed: () async {
                          final state = _fabKey.currentState;
                          if (state != null) {
                            state.toggle();

                            var res = await locator
                                .get<GatewayRepository>()
                                .getGateways(roomModel.buildingUnitId!, true);
                            if (res.success!) {
                              var gateways = res.data as List<GatewayModel>;
                              if (gateways.isEmpty) {
                                DialogHelper().displayErrorSnackBar(
                                    context,
                                    "Kein Gateway vorhanden",
                                    ContentType.failure);
                                return;
                              }

                              String gwId = "";

                              //show dialog with gateways as dropdown
                              await Dialogs.materialDialog(
                                  dialogWidth: kIsWeb ? 0.4 : null,
                                  barrierDismissible: false,
                                  context: context,
                                  title: "Gateway auswählen?",
                                  msgAlign: TextAlign.center,
                                  msg:
                                      "Bitte wählen Sie ein Gateway aus, welches zum Verbinden des neuen Rauchmelders genutzt werden soll.",
                                  color: ThemeHelper.theme.canvasColor,
                                  customView: Column(
                                    children: [
                                      const SizedBox(height: 20.0),

                                      //make dropdown to select gateway
                                      DropdownButtonFormField<GatewayModel>(
                                        decoration: InputDecoration(
                                          labelText: "Gateway",
                                          border: OutlineInputBorder(),
                                        ),
                                        value: gateways.first,
                                        items: gateways
                                            .map((e) =>
                                                DropdownMenuItem<GatewayModel>(
                                                  value: e,
                                                  child: Text(
                                                      "${e.name!}-${e.description!}"),
                                                ))
                                            .toList(),
                                        onChanged: (value) {
                                          gwId = value!.id!;
                                        },
                                      ),
                                      const SizedBox(height: 10.0),
                                    ],
                                  ),
                                  customViewPosition:
                                      CustomViewPosition.BEFORE_ACTION,
                                  actions: [
                                    Wrap(children: [
                                      CustomIconOutlineButton(
                                        onPressed: () {
                                          context.pop("");
                                        },
                                        text: 'Abbruch',
                                        iconData: Icons.cancel_outlined,
                                        textStyle:
                                            const TextStyle(color: Colors.grey),
                                        iconColor: Colors.grey,
                                      ),
                                      CustomIconButton(
                                        onPressed: () {
                                          context.pop(gwId);
                                        },
                                        text: 'Gateway auswählen',
                                        iconData: Icons.save,
                                        color:
                                            ThemeHelper.theme.primaryColorDark,
                                        textStyle: const TextStyle(
                                            color: Colors.white),
                                        iconColor: Colors.white,
                                      ),
                                    ])
                                  ]);

                              if (gwId.isEmpty) {
                                DialogHelper().displayErrorSnackBar(
                                    context,
                                    "Bitte wählen Sie ein Gateway aus",
                                    ContentType.failure);
                                return;
                              }

                              //navigate to add smoke detector screen
                              await Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          PreAddSmokeDetectorScreen(
                                              gatewayId: gwId,
                                              roomId: widget.roomId)));

                              setState(() {
                                _response = getRoom();
                              });
                            } else {
                              DialogHelper().displayErrorSnackBar(context,
                                  res.errorMessage!, ContentType.failure);
                              return;
                            }

                            // await Navigator.of(context).push(MaterialPageRoute(
                            //     builder: (context) => AddNewEntityScreen(entityType: RoomModel,
                            //         parentEntityId: buildingUnit.id!)));

                            setState(() {
                              _response = getRoom();
                            });
                          }
                        }),
                    FloatingActionButton.small(
                        tooltip: "Gateway hinzufügen",
                        heroTag: null,
                        child: const Icon(Icons.router),
                        onPressed: () async {
                          final state = _fabKey.currentState;
                          if (state != null) {
                            state.toggle();

                            // await Navigator.of(context).push(MaterialPageRoute(
                            //     builder: (context) => AddNewEntityScreen(entityType: RoomModel,
                            //         parentEntityId: buildingUnit.id!)));

                            setState(() {
                              _response = getRoom();
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
                      Text(roomModel.name!),
                      const SizedBox(
                        width: 5,
                      ),
                      Tooltip(
                          message:
                              "Erstellt: ${roomModel.createdAt!.toLocal()}\nGeändert: ${roomModel.updatedAt!.toLocal()}",
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
                                                  roomModel.name = value;
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
                                                roomModel.description = value;
                                              },
                                            ),
                                          ),
                                        ],
                                      )),
                                  !_status ? _getActionButtons() : Container(),
                                ])),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 25.0, right: 25.0, top: 25.0),
                        child: AutoSizeText(
                          "Rauchmelder",
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
                        children: getSmokeDetectors(roomModel),
                        // ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 25.0, right: 25.0, top: 25.0),
                        child: AutoSizeText(
                          "Gateways",
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
                        children: getGateways(roomModel),
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

  getSmokeDetectors(RoomModel room) {
    var items = <Widget>[];

    if (room.smokeDetectors!.isEmpty) {
      items.add(Card(
        child: ListTile(
          title: Text("Keine Rauchmelder vorhanden",
              style: ThemeHelper.listTileTitle()),
          subtitle: Text("Fügen Sie einen Rauchmelder hinzu",
              style: ThemeHelper.listTileSubtitle()),
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

    for (var detector in room.smokeDetectors!) {
      items.add(Card(
          child: ListTile(
        title: Text(detector.name!, style: ThemeHelper.listTileTitle()),
        subtitle:
            Text(detector.description!, style: ThemeHelper.listTileSubtitle()),
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
          context.go('/smokedetector/${detector.id}');
        },
      )));
    }

    items.add(const SizedBox(height: 50));

    return items;
  }

  getGateways(RoomModel room) {
    var items = <Widget>[];

    if (room.gateways!.isEmpty) {
      items.add(Card(
        child: ListTile(
          title: Text("Keine Gateways vorhanden",
              style: ThemeHelper.listTileTitle()),
          subtitle: Text("Fügen Sie ein Gateway hinzu",
              style: ThemeHelper.listTileSubtitle()),
          visualDensity: VisualDensity.comfortable,
          selectedColor: ThemeHelper.theme.primaryColor,
          hoverColor: ThemeHelper.theme.hoverColor,
          leading: const SizedBox(
            height: double.infinity,
            child: Icon(
              Icons.hide_source,
              color: Colors.white,
              size: 30,
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.white,
          ),
          onTap: () async {
            await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => PreAddGatewayScreen(roomId: room.id!)));

            setState(() {
              _response = getRoom();
            });
          },
        ),
      ));
      return items;
    }

    for (var gateway in room.gateways!) {
      items.add(Card(
          child: ListTile(
        title: Text(gateway.name!, style: ThemeHelper.listTileTitle()),
        subtitle:
            Text(gateway.description!, style: ThemeHelper.listTileSubtitle()),
        visualDensity: VisualDensity.comfortable,
        selectedColor: ThemeHelper.theme.primaryColor,
        hoverColor: ThemeHelper.theme.hoverColor,
        leading: const SizedBox(
          height: double.infinity,
          child: Icon(
            Icons.router,
            color: Colors.white,
            size: 30,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white,
        ),
        onTap: () {
          context.go('/gateway/${gateway.id}');
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
}
