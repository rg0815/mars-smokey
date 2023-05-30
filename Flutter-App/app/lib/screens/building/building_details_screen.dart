import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ssds_app/Screens/address/address_screen.dart';
import 'package:ssds_app/api/models/building_model.dart';
import 'package:ssds_app/api/models/building_unit_model.dart';
import 'package:ssds_app/components/custom_app_bar.dart';
import 'package:ssds_app/components/theme_helper.dart';
import 'package:ssds_app/services/service_locator.dart';

import '../../api/models/address_model.dart';
import '../../api/models/responses/response_model.dart';
import '../../api/repositories/building_repository.dart';
import '../../components/custom_icon_button.dart';
import '../../components/custom_outline_button.dart';
import '../../components/snackbar/snackbar.dart';
import '../../helper/dialog_helper.dart';
import '../../helper/multi_tenant_notifier.dart';
import '../generic/add_new_entity.dart';

class BuildingDetailsScreen extends ConsumerStatefulWidget {
  const BuildingDetailsScreen({Key? key, required this.buildingId})
      : super(key: key);
  final String buildingId;

  @override
  _BuildingDetailsScreenState createState() => _BuildingDetailsScreenState();
}

class _BuildingDetailsScreenState extends ConsumerState<BuildingDetailsScreen> {
  late Future<ResponseModel> _response;
  final ScrollController controller = ScrollController();
  final _fabKey = GlobalKey<ExpandableFabState>();
  final _formKey = GlobalKey<FormState>();
  bool _status = true;
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  late BuildingModel _building;

  @override
  void initState() {
    super.initState();
    _response = getBuilding();
  }

  Future<ResponseModel> getBuilding() async {
    return locator.get<BuildingRepository>().getBuildingById(widget.buildingId);
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
          BuildingModel building = (snapshot.data as ResponseModel).data!;
          _building = building;

          nameController.text = building.name!;
          descriptionController.text = building.description!;

          return Scaffold(
            appBar: CustomAdaptiveAppBar(
              centerTitle: true,
              title: const Text("Gebäude"),
              iconThemeData: const IconThemeData(color: Colors.white),
              automaticallyImplyLeading: false,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  context.go('/building');
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
                        tooltip: "Gebäudeeinheit hinzufügen",
                        heroTag: null,
                        child: const Icon(Icons.add),
                        onPressed: () async {
                          final state = _fabKey.currentState;
                          if (state != null) {
                            state.toggle();

                            await Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => AddNewEntityScreen(entityType: BuildingUnitModel,
                                    parentEntityId: building.id!)));

                            setState(() {
                              _response = getBuilding();
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
                      Text(building.name!),
                      const SizedBox(
                        width: 5,
                      ),
                      Tooltip(
                          message:
                              "Erstellt: ${building.createdAt!.toLocal()}\nGeändert: ${building.updatedAt!.toLocal()}",
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
                                                  building.name = value;
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
                                                building.description = value;
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
                          "Adresse",
                          maxLines: 1,
                          style: ThemeHelper.theme.textTheme.headlineSmall,
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.only(
                              left: 25.0, right: 25.0, top: 25.0),
                          child: Card(
                            child: ListTile(
                              title: Text(building.address!.street!,
                                  style: ThemeHelper.listTileTitle()),
                              subtitle: Text(
                                  "${building.address!.zipCode!} ${building.address!.city!} - ${building.address!.country!}",
                                  style: ThemeHelper.listTileSubtitle()),
                              visualDensity: VisualDensity.comfortable,
                              selectedColor: ThemeHelper.theme.primaryColor,
                              hoverColor: ThemeHelper.theme.hoverColor,
                              leading: const SizedBox(
                                height: double.infinity,
                                child: Icon(
                                  Icons.pin_drop,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white,
                              ),
                              onTap: () async {
                                var res = await Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) => AddressScreen(
                                                address: building.address!)))
                                    as AddressModel;
                                setState(() {
                                  building.address = res;
                                });
                              },
                            ),
                          )),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 25.0, right: 25.0, top: 25.0),
                        child: AutoSizeText(
                          "Gebäudeeinheiten",
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
                        children: getBuildingUnitsItems(building),
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

  getBuildingUnitsItems(BuildingModel building) {
    var items = <Widget>[];

    if (building.buildingUnits!.isEmpty) {
      items.add(Card(
        child: ListTile(
          title: Text("Keine Gebäudeeinheiten vorhanden",
              style: ThemeHelper.listTileTitle()),
          subtitle: Text("Erstellen Sie eine Gebäudeeinheit",
              style: ThemeHelper.listTileSubtitle()),
          visualDensity: VisualDensity.comfortable,
          selectedColor: ThemeHelper.theme.primaryColor,
          hoverColor: ThemeHelper.theme.hoverColor,
          leading: const SizedBox(
            height: double.infinity,
            child: Icon(
              Icons.no_meeting_room,
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

    for (var buItem in building.buildingUnits!) {
      items.add(Card(
          child: ListTile(
        title: Text(buItem.name!, style: ThemeHelper.listTileTitle()),
        subtitle:
            Text(buItem.description!, style: ThemeHelper.listTileSubtitle()),
        visualDensity: VisualDensity.comfortable,
        selectedColor: ThemeHelper.theme.primaryColor,
        hoverColor: ThemeHelper.theme.hoverColor,
        leading: const SizedBox(
          height: double.infinity,
          child: Icon(
            Icons.meeting_room,
            color: Colors.white,
            size: 30,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white,
        ),
        onTap: () {
          context.go('/buildingUnit/details/${buItem.id}');
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

                    var res = await locator
                        .get<BuildingRepository>()
                        .updateBuilding(_building.id!, _building);

                    if (!res.success! || res.data == null) {
                      DialogHelper().displayErrorSnackBar(
                          context,
                          res.errorMessage ?? "Unbekannter Fehler.",
                          ContentType.failure);
                    } else {
                      ref
                          .read(multiTenantProvider.notifier)
                          .setSelectedTenant(_building.tenantId!);

                      DialogHelper().displayErrorSnackBar(context,
                          "Aktualisierung erfolgreich.", ContentType.success);

                      var building = res.data! as BuildingModel;

                      setState(() {
                        _building = building;
                      });

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
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
