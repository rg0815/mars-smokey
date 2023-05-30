import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:signature/signature.dart';
import 'package:ssds_app/api/repositories/smoke_detector_repository.dart';
import 'package:ssds_app/components/custom_app_bar.dart';
import 'package:ssds_app/helper/auth.dart';
import 'package:ssds_app/services/service_locator.dart';

import '../../api/models/smoke_detector_maintenance_model.dart';
import '../../components/snackbar/snackbar.dart';
import '../../helper/dialog_helper.dart';

class SmokeDetectorMaintenanceScreen extends ConsumerStatefulWidget {
  const SmokeDetectorMaintenanceScreen(
      {Key? key,
      required this.smokeDetectorMaintenanceModel,
      required this.isNew,
      required this.buildingName,
      required this.buildingUnitName,
      required this.roomName,
      required this.address})
      : super(key: key);
  final SmokeDetectorMaintenanceModel smokeDetectorMaintenanceModel;
  final bool isNew;
  final String buildingName;
  final String buildingUnitName;
  final String roomName;
  final String address;

  @override
  _SmokeDetectorMaintenanceScreenState createState() =>
      _SmokeDetectorMaintenanceScreenState();
}

class _SmokeDetectorMaintenanceScreenState
    extends ConsumerState<SmokeDetectorMaintenanceScreen> {
  late SmokeDetectorMaintenanceModel _smokeDetectorMaintenanceModel;
  final _signatureController = SignatureController(exportBackgroundColor: Colors.white, exportPenColor: Colors.black, penStrokeWidth: 5);

  final TextEditingController _buildingController = TextEditingController();
  final TextEditingController _buildingUnitController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _personController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _buildingController.text = widget.buildingName;
    _buildingUnitController.text =
        "${widget.buildingUnitName} - ${widget.roomName}";
    _addressController.text = widget.address;
    _dateController.text = DateTime.now().toLocal().toString();
    _commentController.text = widget.smokeDetectorMaintenanceModel.comment!;
    _personController.text =
        "${AppAuth.getUser().firstName} ${AppAuth.getUser().lastName}";

    _smokeDetectorMaintenanceModel = widget.smokeDetectorMaintenanceModel;
    if (widget.isNew) {
      _smokeDetectorMaintenanceModel.comment = "";
      _smokeDetectorMaintenanceModel.isTested = false;
      _smokeDetectorMaintenanceModel.isCleaned = false;
      _smokeDetectorMaintenanceModel.isDustCleaned = false;
      _smokeDetectorMaintenanceModel.isBatteryReplaced = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAdaptiveAppBar(
          centerTitle: true,
          title: const Text("Rauchmelderwartung"),
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
          appBar: AppBar(
            automaticallyImplyLeading: false,
            toolbarHeight: 40,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_smokeDetectorMaintenanceModel.smokeDetector!.name!),
                const SizedBox(
                  width: 5,
                ),
                widget.isNew
                    ? const SizedBox()
                    : Tooltip(
                        message:
                            "Erstellt: ${_smokeDetectorMaintenanceModel.createdAt!.toLocal()}}",
                        child: const Icon(
                          Icons.info_outline,
                          color: Colors.white,
                          size: 16,
                        ))
              ],
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: _buildingController,
                  enabled: false,
                  decoration: InputDecoration(
                    labelText: "Gebäude",
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _buildingUnitController,
                  enabled: false,
                  decoration: InputDecoration(
                    labelText: "Gebäudeeinheit",
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _addressController,
                  enabled: false,
                  decoration: InputDecoration(
                    labelText: "Adresse",
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _dateController,
                  enabled: false,
                  decoration: InputDecoration(
                    labelText: "Datum",
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                CheckboxListTile(
                  enabled: widget.isNew,
                  title: Text("Batterie gewechselt"),
                  value: _smokeDetectorMaintenanceModel.isBatteryReplaced,
                  onChanged: (newValue) {
                    setState(() {
                      _smokeDetectorMaintenanceModel.isBatteryReplaced =
                          newValue!;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                CheckboxListTile(
                  enabled: widget.isNew,
                  title: Text("Rauchmelder abgestaubt"),
                  value: _smokeDetectorMaintenanceModel.isDustCleaned,
                  onChanged: (newValue) {
                    setState(() {
                      _smokeDetectorMaintenanceModel.isDustCleaned = newValue!;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                CheckboxListTile(
                  enabled: widget.isNew,
                  title: Text("Rauchmelder gereinigt"),
                  value: _smokeDetectorMaintenanceModel.isCleaned,
                  onChanged: (newValue) {
                    setState(() {
                      _smokeDetectorMaintenanceModel.isCleaned = newValue!;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                CheckboxListTile(
                  enabled: widget.isNew,
                  title: Text("Testalarm durchgeführt"),
                  value: _smokeDetectorMaintenanceModel.isTested,
                  onChanged: (newValue) {
                    setState(() {
                      _smokeDetectorMaintenanceModel.isTested = newValue!;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _commentController,
                  enabled: widget.isNew,
                  decoration: InputDecoration(
                    labelText: "Kommentar",
                  ),
                  maxLines: 5,
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _personController,
                  enabled: false,
                  decoration: InputDecoration(
                    labelText: "Durchführer",
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                widget.isNew
                    ? Signature(
                        controller: _signatureController,
                        height: 300,
                        backgroundColor: Colors.red.shade200,
                      )
                    : _smokeDetectorMaintenanceModel.getPngImage(),
                const SizedBox(
                  height: 30,
                ),
                widget.isNew
                    ? ElevatedButton(
                        onPressed: () async {
                          final imageData =
                              await _signatureController.toPngBytes();

                          await showDialog(
                            context: context,
                            builder: (_) => ImageDialog(image: Image.memory(imageData!)
                            ));



                          final encoded = base64Encode(imageData!);
                          _smokeDetectorMaintenanceModel.signature = encoded;

                          _smokeDetectorMaintenanceModel.comment =
                              _commentController.text;

                          _smokeDetectorMaintenanceModel.userId =
                              AppAuth.getUser().id;
                          _smokeDetectorMaintenanceModel.time =
                              DateTime.now().toLocal();
                          _smokeDetectorMaintenanceModel.name =
                              "${_smokeDetectorMaintenanceModel.smokeDetector!.id}_${DateTime.now().toLocal()}";

                          var res = await locator
                              .get<SmokeDetectorRepository>()
                              .addMaintenance(
                                  _smokeDetectorMaintenanceModel
                                      .smokeDetector!.id!,
                                  _smokeDetectorMaintenanceModel);

                          if (!res.success!) {
                            DialogHelper().displayErrorSnackBar(
                                context,
                                res.errorMessage ?? "Unbekannter Fehler",
                                ContentType.failure);
                          } else {
                            DialogHelper().displayErrorSnackBar(
                                context,
                                "Wartung erfolgreich gespeichert",
                                ContentType.success);
                            context.pop();
                          }
                        },
                        child: const Text(
                          'Wartung speichern',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : const SizedBox()
              ],
            ),
          ),
        ));
  }
}

class ImageDialog extends StatelessWidget {
  final Image image;

  const ImageDialog({super.key, required this.image});
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: image
    );
  }
}