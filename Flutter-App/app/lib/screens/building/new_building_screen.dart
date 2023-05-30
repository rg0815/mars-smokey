import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ssds_app/api/models/requests/add_building_request.dart';
import 'package:ssds_app/api/repositories/building_repository.dart';
import 'package:ssds_app/components/snackbar/snackbar.dart';
import 'package:ssds_app/helper/dialog_helper.dart';
import 'package:ssds_app/services/service_locator.dart';

import '../../components/custom_app_bar.dart';
import '../../components/custom_icon_button.dart';
import '../../components/theme_helper.dart';
import '../../helper/multi_tenant_notifier.dart';

class NewBuildingScreen extends ConsumerStatefulWidget {
  const NewBuildingScreen({Key? key, required this.tenantId}) : super(key: key);

  final String tenantId;

  @override
  _NewBuildingScreenState createState() => _NewBuildingScreenState();
}

class _NewBuildingScreenState extends ConsumerState<NewBuildingScreen> {
  final _formKey = GlobalKey<FormState>();
  AddBuildingRequest _request = AddBuildingRequest();

  getAppBar() {
    return CustomAdaptiveAppBar(
      centerTitle: true,
      title: const Text("Gebäude anlegen"),
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
                      child: Text("Neues Gebäude anlegen",
                          style: ThemeHelper.theme.textTheme.headlineMedium),
                    ),
                    const SizedBox(height: 20.0),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                      child: Text(
                        "Gebäudeinformationen",
                        style: ThemeHelper.theme.textTheme.headlineSmall,
                      ),
                    ),
                    const Padding(
                      padding:
                          EdgeInsets.only(left: 25.0, right: 25.0, top: 25.0),
                      child: Text(
                        'Gebäudename',
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
                              hintText: "Gebäudename eingeben"),
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
                        'Gebäudebeschreibung',
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
                              hintText: "Gebäudebeschreibung eingeben"),
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
                    const SizedBox(height: 15.0),
                    Divider(color: ThemeHelper.theme.dividerColor),
                    const SizedBox(height: 15.0),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                      child: Text(
                        "Adresse",
                        style: ThemeHelper.theme.textTheme.headlineSmall,
                      ),
                    ),
                    const Padding(
                      padding:
                          EdgeInsets.only(left: 25.0, right: 25.0, top: 25.0),
                      child: Text(
                        'Straße',
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
                              hintText: "Straße eingeben"),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Bitte eine Straße eingeben';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _request.street = value!;
                          },
                        ),
                      ),
                    ),
                    const Padding(
                      padding:
                          EdgeInsets.only(left: 25.0, right: 25.0, top: 25.0),
                      child: Text(
                        'Postleitzahl',
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
                              hintText: "Postleitzahl eingeben"),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Bitte eine Postleitzahl eingeben';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _request.zipCode = value!;
                          },
                        ),
                      ),
                    ),
                    const Padding(
                      padding:
                          EdgeInsets.only(left: 25.0, right: 25.0, top: 25.0),
                      child: Text(
                        'Stadt',
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
                              const InputDecoration(hintText: "Stadt eingeben"),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Bitte eine Stadt eingeben';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _request.city = value!;
                          },
                        ),
                      ),
                    ),
                    const Padding(
                      padding:
                          EdgeInsets.only(left: 25.0, right: 25.0, top: 25.0),
                      child: Text(
                        'Land',
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
                              const InputDecoration(hintText: "Land eingeben"),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Bitte ein Land eingeben';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _request.country = value!;
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
                              .get<BuildingRepository>()
                              .createBuilding(widget.tenantId, _request);
                          if (!res.success! || res.data == null) {
                            DialogHelper().displayErrorSnackBar(
                                context,
                                res.errorMessage ?? "Unbekannter Fehler.",
                                ContentType.failure);
                          } else {
                            ref
                                .read(multiTenantProvider.notifier)
                                .setSelectedTenant(widget.tenantId);

                            DialogHelper().displayErrorSnackBar(
                                context,
                                "Gebäude erfolgreich angelegt.",
                                ContentType.success);



                            context.pop();
                          }
                        }
                      },
                      text: "Gebäude anlegen",
                      iconData: Icons.add_home,
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
