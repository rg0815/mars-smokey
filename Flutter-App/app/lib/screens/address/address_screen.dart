import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ssds_app/api/models/address_model.dart';

import '../../api/repositories/address_repository.dart';
import '../../components/custom_app_bar.dart';
import '../../components/custom_icon_button.dart';
import '../../components/custom_outline_button.dart';
import '../../components/snackbar/snackbar.dart';
import '../../components/theme_helper.dart';
import '../../helper/dialog_helper.dart';
import '../../services/service_locator.dart';

class AddressScreen extends StatefulWidget {
   AddressScreen({super.key, required this.address});

  AddressModel address;

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  bool _status = true;
  final _formKey = GlobalKey<FormState>();
  final streetController = TextEditingController();
  final postalCodeController = TextEditingController();
  final cityController = TextEditingController();
  final countryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    streetController.text = widget.address.street!;
    postalCodeController.text = widget.address.zipCode!;
    cityController.text = widget.address.city!;
    countryController.text = widget.address.country!;

    return Scaffold(
      appBar: getAppBar(),
      body: Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              setState(() {
                _status = false;
              });
            },
            child: const Icon(Icons.edit),
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
                            const Padding(
                              padding: EdgeInsets.only(
                                  left: 25.0, right: 25.0, top: 25.0),
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
                                  enabled: !_status,
                                  controller: streetController,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Bitte eine Straße eingeben';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    widget.address.street = value!;
                                  },
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(
                                  left: 25.0, right: 25.0, top: 25.0),
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
                                  enabled: !_status,
                                  controller: postalCodeController,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Bitte eine Postleitzahl eingeben';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    // _user.firstName = value!;
                                  },
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(
                                  left: 25.0, right: 25.0, top: 25.0),
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
                                  decoration: const InputDecoration(
                                      hintText: "Stadt eingeben"),
                                  enabled: !_status,
                                  controller: cityController,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Bitte einee Stadt eingeben';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    widget.address.city = value!;
                                  },
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(
                                  left: 25.0, right: 25.0, top: 25.0),
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
                                  decoration: const InputDecoration(
                                      hintText: "Land eingeben"),
                                  enabled: !_status,
                                  controller: countryController,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Bitte ein Land eingeben';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    widget.address.country = value!;
                                  },
                                ),
                              ),
                            ),
                            !_status ? _getActionButtons() : Container(),
                          ])),
                ),
              ])),
    );
  }

  getAppBar() {
    return CustomAdaptiveAppBar(
      centerTitle: true,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Adresse bearbeiten"),
          const SizedBox(
            width: 5,
          ),
          Tooltip(
              message:
                  "Erstellt: ${widget.address.createdAt!.toLocal()}\nGeändert: ${widget.address.updatedAt!.toLocal()}",
              child: const Icon(
                Icons.info_outline,
                color: Colors.white,
                size: 16,
              ))
        ],
      ),
      iconThemeData: const IconThemeData(color: Colors.white),
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          context.pop(widget.address);
        },
      ),
    );
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


                    var res = await locator.get<AddressRepository>()
                        .updateAddress(widget.address.id! ,widget.address);

                    if (!res.success! || res.data == null) {
                      DialogHelper().displayErrorSnackBar(
                          context,
                          res.errorMessage ?? "Unbekannter Fehler.",
                          ContentType.failure);
                    } else {
                      var address = res.data! as AddressModel;

                      DialogHelper().displayErrorSnackBar(context,
                          "Aktualisierung erfolgreich.", ContentType.success);

                      setState(() {
                        widget.address = address;
                      });
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
