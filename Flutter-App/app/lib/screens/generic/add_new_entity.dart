import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ssds_app/api/models/room_model.dart';
import 'package:ssds_app/api/models/smoke_detector_model_model.dart';

import '../../api/models/building_unit_model.dart';
import '../../api/models/gateway_model.dart';
import '../../api/models/smoke_detector_model.dart';
import '../../api/repositories/building_unit_repository.dart';
import '../../api/repositories/gateway_repository.dart';
import '../../api/repositories/room_repository.dart';
import '../../api/repositories/smoke_detector_repository.dart';
import '../../components/custom_app_bar.dart';
import '../../components/custom_icon_button.dart';
import '../../components/snackbar/snackbar.dart';
import '../../components/theme_helper.dart';
import '../../helper/dialog_helper.dart';
import '../../services/service_locator.dart';

class AddNewEntityScreen extends ConsumerStatefulWidget {
  const AddNewEntityScreen(
      {Key? key,
      required this.entityType,
      required this.parentEntityId,
      this.gateway,
      this.smokeDetector,
      this.possibleModels})
      : super(key: key);

  final String parentEntityId;
  final Type entityType;
  final GatewayModel? gateway;
  final SmokeDetectorModel? smokeDetector;
  final List<SmokeDetectorModelModel>? possibleModels;

  @override
  _AddNewEntityScreenState createState() => _AddNewEntityScreenState();
}

class _AddNewEntityScreenState extends ConsumerState<AddNewEntityScreen> {
  final _formKey = GlobalKey<FormState>();
  BuildingUnitModel _buildingUnitRequest = BuildingUnitModel();
  RoomModel _roomRequest = RoomModel();
  late GatewayModel _gatewayModel = widget.gateway ?? GatewayModel();
  late SmokeDetectorModel _smokeDetectorModel =
      widget.smokeDetector ?? SmokeDetectorModel();
  SmokeDetectorModelModel? _selectedModel;

  getAppBar() {
    return CustomAdaptiveAppBar(
      centerTitle: true,
      title: getTitle(),
      iconThemeData: const IconThemeData(color: Colors.white),
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          context.pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(),
      body: Scaffold(
        body: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(25.0),
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
                      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                      child: getHeading(),
                    ),
                    const SizedBox(height: 20.0),
                    const Padding(
                      padding:
                          EdgeInsets.only(left: 25.0, right: 25.0, top: 25.0),
                      child: Text(
                        'Name',
                        style: TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 25.0, right: 25.0, top: 2.0),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: TextFormField(
                          decoration:
                              const InputDecoration(hintText: "Name eingeben"),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Bitte einen Namen eingeben';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            if (widget.entityType == BuildingUnitModel) {
                              _buildingUnitRequest.name = value!;
                            } else if (widget.entityType == RoomModel) {
                              _roomRequest.name = value!;
                            } else if (widget.entityType == GatewayModel) {
                              _gatewayModel.name = value!;
                            } else if (widget.entityType ==
                                SmokeDetectorModel) {
                              _smokeDetectorModel.name = value!;
                            }
                          },
                        ),
                      ),
                    ),
                    const Padding(
                      padding:
                          EdgeInsets.only(left: 25.0, right: 25.0, top: 25.0),
                      child: Text(
                        'Beschreibung',
                        style: TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 25.0, right: 25.0, top: 2.0),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: TextFormField(
                          decoration: const InputDecoration(
                              hintText: "Beschreibung eingeben"),
                          onSaved: (value) {
                            if (widget.entityType == BuildingUnitModel) {
                              _buildingUnitRequest.description = value!;
                            } else if (widget.entityType == RoomModel) {
                              _roomRequest.description = value!;
                            } else if (widget.entityType == GatewayModel) {
                              _gatewayModel.description = value!;
                            } else if (widget.entityType ==
                                SmokeDetectorModel) {
                              _smokeDetectorModel.description = value!;
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 30.0),
                    Visibility(
                      visible: widget.entityType == SmokeDetectorModel,
                      child: const Padding(
                        padding:
                            EdgeInsets.only(left: 25.0, right: 25.0, top: 25.0),
                        child: Text(
                          'Rauchmelder-Modell',
                          style: TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    widget.entityType == SmokeDetectorModel
                        ? Padding(
                            padding: const EdgeInsets.only(
                                left: 25.0, right: 25.0, top: 2.0),
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: DropdownButtonFormField<
                                  SmokeDetectorModelModel>(
                                decoration: InputDecoration(
                                  labelText: "Rauchmelder-Modell",
                                  border: OutlineInputBorder(),
                                ),
                                value: widget.possibleModels!.first,
                                items: widget.possibleModels!
                                    .map((e) => DropdownMenuItem<
                                            SmokeDetectorModelModel>(
                                          value: e,
                                          child: Text(
                                              "${e.name!}-${e.description!}"),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  _selectedModel = value;
                                },
                              ),
                            ),
                          )
                        : const SizedBox(height: 0.0),
                    Visibility(
                        visible: widget.entityType == SmokeDetectorModel,
                        child: const SizedBox(height: 30.0)),
                    CustomIconButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();

                          if (widget.entityType == BuildingUnitModel) {
                            var res = await locator
                                .get<BuildingUnitRepository>()
                                .createBuildingUnit(widget.parentEntityId,
                                    _buildingUnitRequest);
                            if (!res.success! || res.data == null) {
                              DialogHelper().displayErrorSnackBar(
                                  context,
                                  res.errorMessage ?? "Unbekannter Fehler.",
                                  ContentType.failure);
                            } else {
                              DialogHelper().displayErrorSnackBar(
                                  context,
                                  "Gebäudeeinheit erfolgreich angelegt.",
                                  ContentType.success);

                              context.pop();
                            }
                          } else if (widget.entityType == RoomModel) {
                            var res = await locator
                                .get<RoomRepository>()
                                .createRoom(
                                    widget.parentEntityId, _roomRequest);
                            if (!res.success! || res.data == null) {
                              DialogHelper().displayErrorSnackBar(
                                  context,
                                  res.errorMessage ?? "Unbekannter Fehler.",
                                  ContentType.failure);
                            } else {
                              DialogHelper().displayErrorSnackBar(
                                  context,
                                  "Raum erfolgreich angelegt.",
                                  ContentType.success);

                              context.pop();
                            }
                          } else if (widget.entityType == GatewayModel) {
                            _gatewayModel.roomId = widget.parentEntityId;

                            var res = await locator
                                .get<GatewayRepository>()
                                .updateGatewayByClientId(
                                    widget.gateway!.clientId!, _gatewayModel);
                            if (!res.success! || res.data == null) {
                              DialogHelper().displayErrorSnackBar(
                                  context,
                                  res.errorMessage ?? "Unbekannter Fehler.",
                                  ContentType.failure);
                            } else {
                              DialogHelper().displayErrorSnackBar(
                                  context,
                                  "Gateway erfolgreich aktualisiert.",
                                  ContentType.success);

                              context.pop();
                            }
                          } else if (widget.entityType == SmokeDetectorModel) {
                            _smokeDetectorModel.roomId = widget.parentEntityId;

                            if (_selectedModel == null) {
                              DialogHelper().displayErrorSnackBar(
                                  context,
                                  "Bitte wählen Sie ein Rauchmelder-Modell aus.",
                                  ContentType.failure);
                              return;
                            }

                            _smokeDetectorModel.smokeDetectorModelId =
                                _selectedModel!.id;

                            var res = await locator
                                .get<SmokeDetectorRepository>()
                                .updateSmokeDetector(_smokeDetectorModel.id!,
                                    _smokeDetectorModel);
                            if (!res.success! || res.data == null) {
                              DialogHelper().displayErrorSnackBar(
                                  context,
                                  res.errorMessage ?? "Unbekannter Fehler.",
                                  ContentType.failure);
                            } else {
                              DialogHelper().displayErrorSnackBar(
                                  context,
                                  "Rauchmelder erfolgreich aktualisiert.",
                                  ContentType.success);

                              context.pop();
                              context.pop();
                            }
                          }
                        }
                      },
                      text: getTitleText(),
                      iconData: Icons.add,
                      color: ThemeHelper.theme.primaryColorDark,
                      textStyle: const TextStyle(color: Colors.white),
                      iconColor: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  getTitle() {
    if (widget.entityType == BuildingUnitModel) {
      return const Text("Gebäudeeinheit anlegen");
    } else if (widget.entityType == RoomModel) {
      return const Text("Raum anlegen");
    } else if (widget.entityType == GatewayModel) {
      return const Text("Gateway anlegen");
    } else if (widget.entityType == SmokeDetectorModel) {
      return const Text("Rauchmelder anlegen");
    }
  }

  getHeading() {
    if (widget.entityType == BuildingUnitModel) {
      return Text("Neue Gebäudeeinheit anlegen",
          style: ThemeHelper.theme.textTheme.headlineMedium);
    } else if (widget.entityType == RoomModel) {
      return Text("Neuen Raum anlegen",
          style: ThemeHelper.theme.textTheme.headlineMedium);
    } else if (widget.entityType == GatewayModel) {
      return Text("Neues Gateway anlegen",
          style: ThemeHelper.theme.textTheme.headlineMedium);
    } else if (widget.entityType == SmokeDetectorModel) {
      return Text("Neuen Rauchmelder anlegen",
          style: ThemeHelper.theme.textTheme.headlineMedium);
    }
  }

  getTitleText() {
    if (widget.entityType == BuildingUnitModel) {
      return "Gebäudeeinheit anlegen";
    } else if (widget.entityType == RoomModel) {
      return "Raum anlegen";
    } else if (widget.entityType == GatewayModel) {
      return "Gateway anlegen";
    } else if (widget.entityType == SmokeDetectorModel) {
      return "Rauchmelder anlegen";
    }
  }
}
