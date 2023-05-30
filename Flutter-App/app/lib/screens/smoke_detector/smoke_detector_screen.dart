import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/shared/types.dart';
import 'package:ssds_app/api/models/smoke_detector_model.dart';
import 'package:ssds_app/api/repositories/gateway_repository.dart';
import 'package:ssds_app/screens/smoke_detector/pre_add_smoke_detector.dart';
import 'package:ssds_app/screens/smoke_detector/smoke_detector_details_screen.dart';

import '../../api/models/gateway_model.dart';
import '../../api/models/responses/response_model.dart';
import '../../api/repositories/smoke_detector_repository.dart';
import '../../components/custom_icon_button.dart';
import '../../components/custom_outline_button.dart';
import '../../components/snackbar/snackbar.dart';
import '../../components/theme_helper.dart';
import '../../helper/dialog_helper.dart';
import '../../helper/multi_tenant_notifier.dart';
import '../../services/service_locator.dart';

class SmokeDetectorScreen extends ConsumerStatefulWidget {
  const SmokeDetectorScreen({Key? key}) : super(key: key);

  @override
  _SmokeDetectorScreenState createState() => _SmokeDetectorScreenState();
}

class _SmokeDetectorScreenState extends ConsumerState<SmokeDetectorScreen> {
  late Future<ResponseModel> _response;

  Future<ResponseModel> getSmokeDetectors(String tenantId) {
    return locator.get<SmokeDetectorRepository>().getSmokeDetectors(tenantId);
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
    } else {
      _response = getSmokeDetectors(notifier.selectedTenantId);
    }

    return FutureBuilder(
        future: _response,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }
          if (snapshot.hasData) {
            var res = snapshot.data as ResponseModel;
            if (!res.success!) {
              return Center(
                child: Text(res.errorMessage!),
              );
            }

            var detectors = res.data as List<SmokeDetectorModel>;

            return Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                toolbarHeight: 40,
                backgroundColor:
                    ThemeHelper.theme.primaryColorDark.withOpacity(0.5),
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("Mandant: ${notifier.selectedTenant?.name}",
                        style: const TextStyle(fontSize: 16)),
                  ],
                ),
                centerTitle: true,
              ),
              body: SafeArea(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                    Expanded(
                      child: ListView(
                        shrinkWrap: true,
                        children: getSdItems(detectors),
                      ),
                    )
                  ])),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }

  getSdItems(List<SmokeDetectorModel> smokeDetectors) {
    var items = <Widget>[];

    if (smokeDetectors.isEmpty) {
      items.add(Card(
        child: ListTile(
          title: Text("Keine Rauchmelder vorhanden",
              style: ThemeHelper.listTileTitle()),
          visualDensity: VisualDensity.comfortable,
          selectedColor: ThemeHelper.theme.primaryColor,
          hoverColor: ThemeHelper.theme.hoverColor,
          leading: Icon(
            Icons.smoking_rooms,
            color: ThemeHelper.theme.disabledColor,
          ),
        ),
      ));
      return items;
    }

    for (var detector in smokeDetectors) {
      items.add(Card(
          child: ListTile(
        title: Text("${detector.name!} - ${detector.description!}",
            style: ThemeHelper.listTileTitle()),
        subtitle: Column(children: [
          Row(children: [
            Text("Raum: ${detector.room!.name!}",
                style: ThemeHelper.listTileSubtitle())
          ]),
          Row(children: [
            Text("Gebäudeeinheit: ${detector.room!.buildingUnit!.name!}",
                style: ThemeHelper.listTileSubtitle())
          ]),
          Row(children: [
            Text("Gebäude: ${detector.room!.buildingUnit!.building!.name!}",
                style: ThemeHelper.listTileSubtitle())
          ]),
        ]),
        visualDensity: VisualDensity.comfortable,
        selectedColor: ThemeHelper.theme.primaryColor,
        hoverColor: ThemeHelper.theme.hoverColor,
        leading: SizedBox(
          height: double.infinity,
          child: getIcon(detector),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: "Rauchmelder löschen",
              icon: Icon(
                Icons.delete_outline,
                color: ThemeHelper.theme.primaryColor,
              ),
              onPressed: () async {
                var res = await DialogHelper().showDeleteDialog(
                    context,
                    "Rauchmelder löschen",
                    "Möchten Sie den Rauchmelder wirklich löschen?");

                if (res) {
                  var delRes = await locator
                      .get<SmokeDetectorRepository>()
                      .deleteSmokeDetector(detector.id!);
                  if (delRes.success!) {
                    DialogHelper().displayErrorSnackBar(context,
                        "Rauchmelder wurde gelöscht", ContentType.success);

                    ref.read(multiTenantProvider.notifier).setSelectedTenant(
                        ref.read(multiTenantProvider).selectedTenantId);
                  } else {
                    DialogHelper().displayErrorSnackBar(
                        context, delRes.errorMessage!, ContentType.failure);
                  }
                }
              },
            ),
            SizedBox(width: 10),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
            ),
          ],
        ),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => SmokeDetectorDetailsScreen(
              smokeDetector: detector,
            ),
          ));
        },
      )));
    }

    return items;
  }

  getIcon(SmokeDetectorModel detector) {
    switch (detector.state) {
      case SmokeDetectorState.normal:
        return const Icon(
          Icons.check,
          color: Colors.green,
          size: 30,
        );
      case SmokeDetectorState.warning:
        return const Icon(
          Icons.warning,
          color: Colors.orange,
          size: 30,
        );
      case SmokeDetectorState.alert:
        return const Icon(
          Icons.local_fire_department,
          color: Colors.red,
          size: 30,
        );
    }
  }
}
