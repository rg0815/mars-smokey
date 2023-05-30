import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ssds_app/api/models/requests/add_building_request.dart';
import 'package:ssds_app/api/repositories/building_repository.dart';
import 'package:ssds_app/components/snackbar/snackbar.dart';
import 'package:ssds_app/helper/dialog_helper.dart';
import 'package:ssds_app/services/service_locator.dart';

import '../../api/models/building_unit_model.dart';
import '../../api/repositories/building_unit_repository.dart';
import '../../components/custom_app_bar.dart';
import '../../components/custom_icon_button.dart';
import '../../components/theme_helper.dart';
import '../../helper/multi_tenant_notifier.dart';

class NewBuildingUnitScreen extends ConsumerStatefulWidget {
  const NewBuildingUnitScreen({Key? key, required this.buildingId}) : super(key: key);

  final String buildingId;

  @override
  _NewBuildingUnitScreenState createState() => _NewBuildingUnitScreenState();
}

class _NewBuildingUnitScreenState extends ConsumerState<NewBuildingUnitScreen> {
  final _formKey = GlobalKey<FormState>();
  BuildingUnitModel _request = BuildingUnitModel();

  getAppBar() {
    return CustomAdaptiveAppBar(
      centerTitle: true,
      title: const Text("Gebäudeeinheit anlegen"),
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
                      child: Text("Neue Gebäudeeinheit anlegen",
                          style: ThemeHelper.theme.textTheme.headlineMedium),
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
                          decoration: const InputDecoration(
                              hintText: "Name eingeben"),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Bitte einen Namen eingeben';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _request.name = value!;
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
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Bitte eine Beschreibung eingeben';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _request.description = value!;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 30.0),
                    CustomIconButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();

                          var res = await locator
                              .get<BuildingUnitRepository>()
                              .createBuildingUnit(widget.buildingId, _request);
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
                        }
                      },
                      text: "Gebäudeeinheit anlegen",
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
}
