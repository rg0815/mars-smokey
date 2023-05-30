import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ssds_app/api/models/smoke_detector_maintenance_model.dart';
import 'package:ssds_app/api/raw/fire_alarm_api.dart';
import 'package:ssds_app/api/repositories/fire_alarm_repository.dart';
import 'package:ssds_app/api/repositories/smoke_detector_repository.dart';
import 'package:ssds_app/components/custom_app_bar.dart';
import 'package:ssds_app/components/theme_helper.dart';
import 'package:ssds_app/helper/auth.dart';
import 'package:ssds_app/services/service_locator.dart';

import '../../api/models/fire_alarm.dart';
import '../../api/models/smoke_detector_model.dart';
import '../../components/custom_icon_button.dart';
import '../../components/custom_outline_button.dart';
import '../../components/snackbar/snackbar.dart';
import '../../helper/dialog_helper.dart';

class FireAlarmScreen extends ConsumerStatefulWidget {
  const FireAlarmScreen({Key? key, required this.fireAlarm}) : super(key: key);
  final FireAlarm fireAlarm;

  @override
  _FireAlarmScreenState createState() => _FireAlarmScreenState();
}

class _FireAlarmScreenState extends ConsumerState<FireAlarmScreen> {
  final _fabKey = GlobalKey<ExpandableFabState>();
  final _formKey = GlobalKey<FormState>();
  bool _status = true;
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAdaptiveAppBar(
        centerTitle: true,
        title: const Text("Feueralarm"),
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
          floatingActionButton: FloatingActionButton(
              tooltip: "Alarm beenden",
              onPressed: () async {
                var res = await locator
                    .get<FireAlarmRepository>()
                    .stopAlarm(widget.fireAlarm.id!);
                if (!res.success!) {
                  DialogHelper().displayErrorSnackBar(
                      context,
                      res.errorMessage ?? "Unbekannter Fehler",
                      ContentType.failure);
                }
                DialogHelper().displayErrorSnackBar(context,
                    "Alarm wurde erfolgreich beendet!", ContentType.success);
                context.pop();
              },
              child: const Icon(Icons.stop)),
          appBar: AppBar(
            automaticallyImplyLeading: false,
            toolbarHeight: 40,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(widget.fireAlarm.buildingUnit!.name!),
                const SizedBox(
                  width: 5,
                ),
                Tooltip(
                    message:
                        "Erstellt: ${widget.fireAlarm.createdAt!.toLocal()}\nGeändert: ${widget.fireAlarm.updatedAt!.toLocal()}",
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
                Padding(
                  padding:
                      const EdgeInsets.only(left: 25.0, right: 25.0, top: 25.0),
                  child: AutoSizeText(
                    "Ausgelöste Rauchmelder",
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
                  children: getSmokeDetectors(),
                  // ),
                ),
              ])),
    );
  }

  getSmokeDetectors() {
    var items = <Widget>[];

    if (widget.fireAlarm.alarmedDetectors!.isEmpty) {
      items.add(Card(
        child: ListTile(
          title: Text("Kein Rauchmelder vorhanden",
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
          onTap: () {},
        ),
      ));
      return items;
    }

    for (var sd in widget.fireAlarm.alarmedDetectors!) {
      items.add(Card(
          child: ListTile(
        title:
            Text(sd.smokeDetector!.name!, style: ThemeHelper.listTileTitle()),
        subtitle: Text(sd.smokeDetector!.toLocation(),
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
      )));
    }

    items.add(const SizedBox(height: 50));

    return items;
  }
}
