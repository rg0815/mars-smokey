import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:scan_barcode/scan_barcode.dart';
import 'package:ssds_app/api/models/gateway_model.dart';
import 'package:ssds_app/api/repositories/gateway_repository.dart';
import 'package:ssds_app/components/snackbar/snackbar.dart';
import 'package:ssds_app/helper/dialog_helper.dart';
import 'package:ssds_app/services/service_locator.dart';

import '../../components/custom_app_bar.dart';
import '../../components/custom_icon_button.dart';
import '../../components/theme_helper.dart';
import '../generic/add_new_entity.dart';

class PreAddGatewayScreen extends ConsumerStatefulWidget {
  const PreAddGatewayScreen({Key? key, required this.roomId}) : super(key: key);

  final String roomId;

  @override
  _PreAddGatewayScreenState createState() => _PreAddGatewayScreenState();
}

class _PreAddGatewayScreenState extends ConsumerState<PreAddGatewayScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _validScan = false;
  var _guidController = new TextEditingController();
  CameraController? controller;
  final scanValue = ScanValue();

  var maskFormatter = MaskTextInputFormatter(
      mask: '########-####-####-####-############',
      filter: {"#": RegExp(r'[a-fA-F\d]')},
      type: MaskAutoCompletionType.lazy);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(),
      body: Scaffold(
          body: FutureBuilder(
        future: locator.get<GatewayRepository>().startPairing(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Error: ${snapshot.error}",
                  style: ThemeHelper.theme.textTheme.headlineMedium,
                ),
              );
            } else {
              return buildBody(context);
            }
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      )),
    );
  }

  getAppBar() {
    return CustomAdaptiveAppBar(
      centerTitle: true,
      title: const Text("Gateway hinzufügen"),
      iconThemeData: const IconThemeData(color: Colors.white),
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () async {
          await locator.get<GatewayRepository>().stopPairing();
          context.pop();
        },
      ),
    );
  }

  Widget buildWeb(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0),
            child: Text("Neues Gateway anlegen",
                style: ThemeHelper.theme.textTheme.headlineMedium),
          ),
          const SizedBox(height: 20.0),
          Padding(
              padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 25.0),
              child: TextField(
                controller: _guidController,
                inputFormatters: [
                  maskFormatter,
                  LengthLimitingTextInputFormatter(36),
                ],
                decoration: const InputDecoration(labelText: 'Enter GUID'),
              )),
          const SizedBox(height: 30.0),
          CustomIconButton(
            onPressed: () async {
              var guidTextField = _guidController.text;
              debugPrint("guidTextField: $guidTextField");

              var res = await locator
                  .get<GatewayRepository>()
                  .getGatewayByClientId(guidTextField);
              if (!res.success!) {
                DialogHelper().displayErrorSnackBar(
                    context,
                    res.errorMessage ?? "Unbekannter Fehler",
                    ContentType.failure);
                return;
              } else {
                var gateway = res.data as GatewayModel;
                gateway.roomId = widget.roomId;
                await locator.get<GatewayRepository>().stopPairing();
                await Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => AddNewEntityScreen(
                        entityType: GatewayModel,
                        parentEntityId: widget.roomId,
                        gateway: gateway)));
              }
            },
            text: "Gateway anlegen",
            iconData: Icons.add,
            color: ThemeHelper.theme.primaryColorDark,
            textStyle: const TextStyle(color: Colors.white),
            iconColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget buildMobile(BuildContext context) {
    return ElevatedButton(
        onPressed: () async {
          _validScan = false;
          String? barcode = await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => Scaffold(
                appBar: AppBar(
                  title: const Text("QR-Code scannen"),
                  iconTheme: const IconThemeData(color: Colors.white),
                  automaticallyImplyLeading: false,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () async {
                      context.pop("");
                    },
                  ),
                ),
                body: Column(children: [
                  Expanded(
                    flex:7,
                    child: BarcodeWidget(
                      scanValue: scanValue,
                      onCameraControllerCreate: (controller) {
                        this.controller = controller;
                      },
                      onHandleBarcodeList: (List<Barcode> barcode) async {
                        if (_validScan) {
                          // Prevent multiple pop
                          return;
                        }
                        if (barcode.isEmpty) return;
                        var bc = barcode.first.rawValue!;

                        if (bc.length == 36) {
                          if (isValidGuid(bc)) {
                            HapticFeedback.vibrate();
                            SystemSound.play(SystemSoundType.click);
                            _guidController.text = bc.toString();
                            _validScan = true;
                            // setState(() {
                            //   _guidController.text = bc.toString();
                            // });

                            context.pop(bc);
                          }
                        }
                      },
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: options(),
                  ),
                ])),
          ));

          if (barcode != null) {
            _guidController.text = barcode;
          }

          //     Scaffold(body: ReaderWidget(
          //   onScan: (Code? code) async {
          //     if (code == null || code.text == null) {
          //       return;
          //     }
          //
          //
          //   },
          //   isMultiScan: false,
          //   scanDelay: const Duration(milliseconds: 500),
          //   resolution: ResolutionPreset.high,
          //   lensDirection: CameraLensDirection.back,
          // )),

          // AiBarcodeScanner(
          //   allowDuplicates: true,
          //   canPop: false,
          //   hintText: 'Scanne den QR Code',
          //   errorText: "QR Code konnte nicht gescannt werden",
          //   successText: "QR Code erfolgreich gescannt",
          //   fit: BoxFit.contain,
          //   controller: cameraController,
          //   onScan: (String barcode) async {
          //     debugPrint(
          //         "--------------------------------------------------------------------------------------------------------------------------------------$barcode");
          //     if (barcode.length == 36) {
          //       if (isValidGuid(barcode)) {
          //         HapticFeedback.vibrate();
          //         SystemSound.play(SystemSoundType.click);
          //         setState(() {
          //           _validScan = true;
          //           _guidController.text = barcode;
          //         });
          //
          //         await locator.get<GatewayRepository>().stopPairing();
          //         if (_validScan) context.pop();
          //       }
          //     }
          //   },
          // )
          // )
          // );
        },
        child: const Text("QR Code scannen"));
  }

  Widget options() {
    return Row(
      children: [
        _buildFlash(),
        _buildCamera(),
      ].map((e) => Expanded(child: e)).toList(),
    );
  }

  var flashOn = false;

  Widget _buildFlash() {
    final icon = flashOn ? Icons.flash_on : Icons.flash_off;
    return IconButton(
      icon: Icon(icon),
      onPressed: () {
        if (controller == null) {
          debugPrint('controller is null, please wait');
          return;
        }
        setState(() {
          flashOn = !flashOn;
        });
        controller!.setFlashMode(flashOn ? FlashMode.torch : FlashMode.off);
      },
    );
  }

  var backCamera = true;

  Widget _buildCamera() {
    final icon = backCamera ? Icons.camera_front : Icons.camera_rear;
    return IconButton(
      icon: Icon(icon),
      onPressed: () async {
        if (controller == null) {
          debugPrint('controller is null, please wait');
          return;
        }

        setState(() {
          backCamera = !backCamera;
        });

        final cameras = await availableCameras();
        final camera = cameras.firstWhere((element) =>
            element.lensDirection ==
            (backCamera
                ? CameraLensDirection.back
                : CameraLensDirection.front));

        final oldConfig = scanValue.cameraConfig;
        final newConfig = oldConfig.copyWith(
          camera: camera,
        );
        scanValue.updateCameraConfig(newConfig);
      },
    );
  }

  // List<Widget> getActions() {
  //   if (kIsWeb) {
  //     return [];
  //   }
  //
  //   return [
  //     IconButton(
  //       color: Colors.white,
  //       icon: ValueListenableBuilder(
  //         valueListenable: cameraController.torchState,
  //         builder: (context, state, child) {
  //           switch (state) {
  //             case TorchState.off:
  //               return const Icon(Icons.flash_off, color: Colors.grey);
  //             case TorchState.on:
  //               return const Icon(Icons.flash_on, color: Colors.yellow);
  //           }
  //         },
  //       ),
  //       iconSize: 32.0,
  //       onPressed: () => cameraController.toggleTorch(),
  //     ),
  //     IconButton(
  //       color: Colors.white,
  //       icon: ValueListenableBuilder(
  //         valueListenable: cameraController.cameraFacingState,
  //         builder: (context, state, child) {
  //           switch (state) {
  //             case CameraFacing.front:
  //               return const Icon(Icons.camera_front);
  //             case CameraFacing.back:
  //               return const Icon(Icons.camera_rear);
  //           }
  //         },
  //       ),
  //       iconSize: 32.0,
  //       onPressed: () => cameraController.switchCamera(),
  //     )
  //   ];
  // }

  bool isValidGuid(String input) {
    final guidPattern = RegExp(
        r'^([0-9a-fA-F]){8}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){12}$');
    return guidPattern.hasMatch(input);
  }

  Widget buildBody(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(25.0),
      children: kIsWeb
          ? [buildWeb(context)]
          : [buildWeb(context), buildMobile(context)],
    );
  }
}
