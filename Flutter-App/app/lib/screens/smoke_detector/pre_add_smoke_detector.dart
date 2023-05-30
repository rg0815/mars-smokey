import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ssds_app/api/models/smoke_detector_model.dart';

import 'package:ssds_app/services/service_locator.dart';

import '../../api/models/responses/response_model.dart';
import '../../api/models/smoke_detector_model_model.dart';
import '../../api/repositories/smoke_detector_repository.dart';
import '../../components/custom_app_bar.dart';
import '../../components/snackbar/snackbar.dart';
import '../../components/theme_helper.dart';
import '../../helper/dialog_helper.dart';
import '../../helper/mqtt_handler.dart';
import '../generic/add_new_entity.dart';

class PreAddSmokeDetectorScreen extends ConsumerStatefulWidget {
  const PreAddSmokeDetectorScreen(
      {Key? key, required this.gatewayId, required this.roomId})
      : super(key: key);

  final String gatewayId;
  final String roomId;

  @override
  _PreAddSmokeDetectorScreenState createState() =>
      _PreAddSmokeDetectorScreenState();
}

class _PreAddSmokeDetectorScreenState
    extends ConsumerState<PreAddSmokeDetectorScreen> {
  MqttHandler mqttHandler = MqttHandler();
  late Future<ResponseModel> _response;

  @override
  void initState() {
    super.initState();
    _response = getModels();
  }

  Future<ResponseModel> getModels() async {
    return locator.get<SmokeDetectorRepository>().getSmokeDetectorModels();
  }

  @override
  void dispose() {
    mqttHandler.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(),
      body: Scaffold(
          body: FutureBuilder(
        future: locator
            .get<SmokeDetectorRepository>()
            .startPairing(widget.gatewayId),
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
              return FutureBuilder(
                future: Future.wait([mqttHandler.connect(), _response]),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          "Error: ${snapshot.error}",
                          style: ThemeHelper.theme.textTheme.headlineMedium,
                        ),
                      );
                    } else if (snapshot.hasData) {
                      var res = (snapshot.data![1] as ResponseModel);
                      if (res.success == false) {
                        return Center(
                          child: Text(
                            "Error: ${res.errorMessage}",
                            style: ThemeHelper.theme.textTheme.headlineMedium,
                          ),
                        );
                      }

                      var models = res.data as List<SmokeDetectorModelModel>;

                      return ListView(
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(25.0),
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 25.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20.0, right: 20.0),
                                    child: Text("Neuen Rauchmelder anlegen",
                                        style: ThemeHelper
                                            .theme.textTheme.headlineMedium),
                                  ),
                                  const SizedBox(height: 20.0),
                                ],
                              ),
                            ),
                            ValueListenableBuilder<List<StringPair>>(
                              builder: (BuildContext context,
                                  List<StringPair> values, Widget? child) {
                                return ListView.builder(
                                  shrinkWrap: true,
                                  // Damit das ListView im Column korrekt angezeigt wird
                                  physics: NeverScrollableScrollPhysics(),
                                  // Verhindert das Scrollen in der inneren Liste
                                  itemCount: values.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    if (values.isEmpty) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }

                                    return Card(
                                        child: ListTile(
                                            title: Text(
                                                "Mögliche Rauchmeldermodelle",
                                                style: ThemeHelper
                                                    .listTileTitle()),
                                            subtitle: getPossibleModels(
                                                values[index].value, models),
                                            visualDensity:
                                                VisualDensity.comfortable,
                                            selectedColor:
                                                ThemeHelper.theme.primaryColor,
                                            hoverColor:
                                                ThemeHelper.theme.hoverColor,
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
                                            onTap: () async {
                                              var resSd = await locator
                                                  .get<
                                                      SmokeDetectorRepository>()
                                                  .getSmokeDetectorById(values[
                                                          index]
                                                      .name) as ResponseModel;

                                              if (!resSd.success! ||
                                                  resSd.data == null) {
                                                DialogHelper()
                                                    .displayErrorSnackBar(
                                                        context,
                                                        resSd.errorMessage ??
                                                            "Unbekannter Fehler.",
                                                        ContentType.failure);
                                              } else {
                                                var sd = resSd.data
                                                    as SmokeDetectorModel;

                                                var resStopParing = await locator
                                                    .get<
                                                        SmokeDetectorRepository>()
                                                    .stopPairing(
                                                        widget.gatewayId);

                                                if (!resStopParing.success!) {
                                                  DialogHelper().displayErrorSnackBar(
                                                      context,
                                                      resStopParing
                                                              .errorMessage ??
                                                          "Unbekannter Fehler.",
                                                      ContentType.failure);
                                                } else {
                                                  var possibleModels = List<
                                                          SmokeDetectorModelModel>.empty(
                                                      growable: true);

                                                  SmokeDetectorModelModel
                                                      tempModel =
                                                      models.firstWhere(
                                                          (element) =>
                                                              element.id ==
                                                              values[index]
                                                                  .value);

                                                  for (var model in models) {
                                                    if (model
                                                            .smokeDetectorProtocol ==
                                                        tempModel
                                                            .smokeDetectorProtocol) {
                                                      possibleModels.add(model);
                                                    }
                                                  }

                                                  await Navigator.of(context)
                                                      .push(MaterialPageRoute(
                                                          builder: (context) =>
                                                              AddNewEntityScreen(
                                                                  entityType:
                                                                      SmokeDetectorModel,
                                                                  parentEntityId:
                                                                      widget
                                                                          .roomId,
                                                                  smokeDetector:
                                                                      sd,
                                                                  possibleModels:
                                                                      possibleModels)));
                                                }
                                              }
                                            }));
                                  },
                                );
                              },
                              valueListenable: mqttHandler.smokeDetectorData,
                            ),
                            const SizedBox(height: 30.0)
                          ]);
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              );
            }
          } else {
            return const Center(
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
      title: const Text("Rauchmelder hinzufügen"),
      iconThemeData: const IconThemeData(color: Colors.white),
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () async {
          await locator
              .get<SmokeDetectorRepository>()
              .stopPairing(widget.gatewayId);
          context.pop();
        },
      ),
    );
  }

  Widget getPossibleModels(
      String tempProtoId, List<SmokeDetectorModelModel> models) {
    var widgetList = <Widget>[];

    SmokeDetectorModelModel tempModel =
        models.firstWhere((element) => element.id == tempProtoId);

    for (var model in models) {
      if (model.smokeDetectorProtocol == tempModel.smokeDetectorProtocol) {
        widgetList.add(Row(children: [
          Text("${model.name} - ${model.description}",
              style: ThemeHelper.listTileSubtitle())
        ]));
      }
    }

    return Column(children: widgetList);
  }
}
