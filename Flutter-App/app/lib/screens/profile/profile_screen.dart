import 'package:email_validator/email_validator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/shared/types.dart';
import 'package:ssds_app/api/models/requests/change_password_model.dart';
import 'package:ssds_app/api/repositories/notification_repository.dart';
import 'package:ssds_app/api/repositories/user_repository.dart';
import 'package:ssds_app/helper/auth.dart';
import '../../api/models/notification_setting_model.dart';
import '../../api/models/requests/register_model.dart';
import '../../api/models/user_model.dart';
import '../../components/custom_icon_button.dart';
import '../../components/custom_outline_button.dart';
import '../../components/snackbar/snackbar.dart';
import '../../components/theme_helper.dart';
import '../../helper/dialog_helper.dart';
import '../../services/service_locator.dart';
import 'http_notification_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _init = false;
  bool _status = true;
  final FocusNode myFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  final _fabKey = GlobalKey<ExpandableFabState>();

  // final passwordController = TextEditingController();
  final mailController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final smsController = TextEditingController();
  final _user = RegisterModel();
  late NotificationSettingModel _notification = NotificationSettingModel();

  final currPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final newPasswordConfirmController = TextEditingController();
  late bool _phoneNumberIdentical;

  @override
  void initState() {
    super.initState();
    getNotificationSetting();
  }

  Future<void> getNotificationSetting() async {
    var res = await locator
        .get<NotificationRepository>()
        .getNotificationSettingsByUserId(AppAuth.getUser().id!);

    var data = res;
    if (!data.success! || data.data == null) {
      DialogHelper().displayErrorSnackBar(
          context, "Konnte Profil nicht abrufen.", ContentType.failure);
    }

    var notificationSetting = data.data as NotificationSettingModel;

    setState(() {
      _notification = notificationSetting;

      if (notificationSetting.phoneNumber != null &&
          notificationSetting.smsNumber != null &&
          notificationSetting.phoneNumber!.phoneNumber ==
              notificationSetting.smsNumber!.phoneNumber) {
        _phoneNumberIdentical = true;
        phoneController.text = notificationSetting.phoneNumber!.phoneNumber!;
        smsController.text = notificationSetting.smsNumber!.phoneNumber!;
      } else {
        _phoneNumberIdentical = false;
        phoneController.text =
            notificationSetting.phoneNumber!.phoneNumber ?? "";
        smsController.text = notificationSetting.smsNumber!.phoneNumber ?? "";
      }

      _init = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // passwordController.text = "********";
    var user = AppAuth.getUser();

    mailController.text = user.email!;
    firstNameController.text = user.firstName!;
    lastNameController.text = user.lastName!;

    if (_init == false) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
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
                tooltip: "Passwort ändern",
                heroTag: null,
                child: const Icon(Icons.password),
                onPressed: () {
                  final state = _fabKey.currentState;
                  if (state != null) {
                    state.toggle();
                  }

                  Dialogs.materialDialog(
                      dialogWidth: kIsWeb ? 0.4 : null,
                      barrierDismissible: false,
                      context: context,
                      title: "Passwort ändern?",
                      msgAlign: TextAlign.center,
                      msg:
                          "Bitte geben Sie Ihr aktuelles, sowie das neue Passwort ein.",
                      color: ThemeHelper.theme.canvasColor,
                      customView: Column(
                        children: [
                          const SizedBox(height: 20.0),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 15.0, right: 15.0),
                            child: Container(
                              decoration:
                                  ThemeHelper().inputBoxDecorationShadow(),
                              child: TextField(
                                obscureText: true,
                                decoration: ThemeHelper().textInputDecoration(
                                    "Aktuelles Passwort",
                                    "aktuelles Passwort eingeben"),
                                controller: currPasswordController,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 15.0, right: 15.0),
                            child: Container(
                              decoration:
                                  ThemeHelper().inputBoxDecorationShadow(),
                              child: TextField(
                                obscureText: true,
                                decoration: ThemeHelper().textInputDecoration(
                                    "Neues Passwort",
                                    "neues Passwort eingeben"),
                                controller: newPasswordController,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 15.0, right: 15.0),
                            child: Container(
                              decoration:
                                  ThemeHelper().inputBoxDecorationShadow(),
                              child: TextField(
                                obscureText: true,
                                decoration: ThemeHelper().textInputDecoration(
                                    "Neues Passwort bestätigen",
                                    "neues Passwort eingeben"),
                                controller: newPasswordConfirmController,
                              ),
                            ),
                          ),
                        ],
                      ),
                      customViewPosition: CustomViewPosition.BEFORE_ACTION,
                      actions: [
                        Wrap(children: [
                          CustomIconOutlineButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            text: 'Abbruch',
                            iconData: Icons.cancel_outlined,
                            textStyle: const TextStyle(color: Colors.grey),
                            iconColor: Colors.grey,
                          ),
                          CustomIconButton(
                            onPressed: () {
                              if (currPasswordController.text.isEmpty) {
                                DialogHelper().displayErrorSnackBar(
                                    context,
                                    "Aktuelles Passwort darf nicht leer sein.",
                                    ContentType.failure);
                                return;
                              }

                              if (newPasswordController.text.isEmpty ||
                                  newPasswordConfirmController.text.isEmpty) {
                                DialogHelper().displayErrorSnackBar(
                                    context,
                                    "Neues Passwort darf nicht leer sein.",
                                    ContentType.failure);
                                return;
                              }

                              if (newPasswordConfirmController.text !=
                                  newPasswordController.text) {
                                DialogHelper().displayErrorSnackBar(
                                    context,
                                    "Passwörter stimmen nicht überein.",
                                    ContentType.failure);
                                return;
                              }

                              if (newPasswordController.text.length < 8) {
                                DialogHelper().displayErrorSnackBar(
                                    context,
                                    "Passwort muss mindestens 8 Zeichen lang sein.",
                                    ContentType.failure);
                                return;
                              }

                              var model = ChangePasswordModel(
                                  oldPassword: currPasswordController.text,
                                  newPassword: newPasswordController.text);

                              locator
                                  .get<UserRepository>()
                                  .changePassword(model)
                                  .then((res) {
                                if (res.success!) {
                                  DialogHelper().displayErrorSnackBar(
                                      context,
                                      "Passwort erfolgreich geändert.",
                                      ContentType.success);
                                  Navigator.of(context).pop();
                                } else {
                                  DialogHelper().displayErrorSnackBar(
                                      context,
                                      res.errorMessage ?? "Unbekannter Fehler.",
                                      ContentType.failure);
                                }
                              });

                              // Navigator.of(context).pop();
                            },
                            text: 'Passwort ändern',
                            iconData: Icons.save,
                            color: ThemeHelper.theme.primaryColorDark,
                            textStyle: const TextStyle(color: Colors.white),
                            iconColor: Colors.white,
                          ),
                        ])
                      ]);
                }),
          ],
        ),
        body: Form(
            key: _formKey,
            child: ListView(
              children: [
                Column(
                  children: [
                    Padding(
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
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Text(
                                        'E-Mail',
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              )),
                          Padding(
                              padding: const EdgeInsets.only(
                                  left: 25.0, right: 25.0, top: 2.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Flexible(
                                    child: TextFormField(
                                      style: TextStyle(
                                          color:
                                              ThemeHelper.theme.disabledColor),
                                      decoration: const InputDecoration(
                                          hintText: "E-Mail eingeben"),
                                      enabled: false,
                                      controller: mailController,
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (val) {
                                        if (val!.isNotEmpty) {
                                          var valid =
                                              EmailValidator.validate(val);
                                          if (!valid) {
                                            return "Gültige E-Mail-Adresse eingeben.";
                                          } else {
                                            return null;
                                          }
                                        }
                                        return "E-Mail-Adresse eingeben";
                                      },
                                      onSaved: (value) {
                                        _user.email = value!;
                                      },
                                    ),
                                  ),
                                ],
                              )),
                          Padding(
                              padding: const EdgeInsets.only(
                                  left: 25.0, right: 25.0, top: 25.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: const [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Vorname',
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Nachname',
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
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Flexible(
                                    flex: 2,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(right: 10.0),
                                      child: TextFormField(
                                        decoration: const InputDecoration(
                                            hintText: "Vorname eingeben"),
                                        enabled: !_status,
                                        controller: firstNameController,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'Bitte einen Vornamen eingeben';
                                          }
                                          return null;
                                        },
                                        onSaved: (value) {
                                          _user.firstName = value!;
                                        },
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    flex: 2,
                                    child: TextFormField(
                                      decoration: const InputDecoration(
                                          hintText: "Nachname eingeben"),
                                      enabled: !_status,
                                      controller: lastNameController,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Bitte einen Nachnamen eingeben';
                                        }
                                        return null;
                                      },
                                      onSaved: (value) {
                                        _user.lastName = value!;
                                      },
                                    ),
                                  ),
                                ],
                              )),
                          const SizedBox(height: 10),
                          const Divider(
                            height: 24,
                            thickness: 2,
                          ),
                          const SizedBox(height: 10),
                          Padding(
                              padding: const EdgeInsets.only(
                                  left: 25.0, right: 25.0, top: 25.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Telefonnummer (optional)',
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Visibility(
                                    visible: !_phoneNumberIdentical,
                                    child: const Expanded(
                                      flex: 2,
                                      child: Text(
                                        'SMS-Nummer (optional)',
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                          Padding(
                              padding: const EdgeInsets.only(
                                  left: 25.0, right: 25.0, top: 2.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Flexible(
                                    flex: 2,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(right: 10.0),
                                      child: TextFormField(
                                        decoration: const InputDecoration(
                                            hintText:
                                                "Telefonnummer eingeben (beginnend mit 00xx)"),
                                        enabled: !_status,
                                        controller: phoneController,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return null;
                                          }

                                          var regex = RegExp(r'^00\d{8,20}$');

                                          if (!regex.hasMatch(value)) {
                                            return 'Bitte eine gültige Telefonnummer eingeben';
                                          }
                                          return null;
                                        },
                                        onSaved: (value) {
                                          _notification.phoneNumber!
                                              .phoneNumber = value!;
                                        },
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    flex: 2,
                                    child: Visibility(
                                      visible: !_phoneNumberIdentical,
                                      child: TextFormField(
                                        decoration: const InputDecoration(
                                            hintText:
                                                "SMS-Nummer eingeben (beginnend mit 00xx)"),
                                        enabled: !_status,
                                        controller: smsController,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return null;
                                          }

                                          var regex = RegExp(r'^00\d{8,20}$');

                                          if (!regex.hasMatch(value)) {
                                            return 'Bitte eine gültige Telefonnummer eingeben';
                                          }
                                          return null;
                                        },
                                        onSaved: (value) {
                                          _notification.smsNumber!.phoneNumber =
                                              value!;
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Card(
                              child: CheckboxListTile(
                                enabled: !_status,
                                title: const Text("Nummern sind identisch"),
                                value: _phoneNumberIdentical,
                                onChanged: (value) {
                                  setState(() {
                                    _phoneNumberIdentical = value!;
                                  });
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Card(
                              child: ListTile(
                                title: Text("HTTP-Einstellungen bearbeiten",
                                    style: ThemeHelper.listTileTitle()
                                        .copyWith(fontSize: 18)),
                                subtitle: Text("Hier klicken",
                                    style: ThemeHelper.listTileSubtitle()),
                                visualDensity: VisualDensity.comfortable,
                                selectedColor: ThemeHelper.theme.primaryColor,
                                hoverColor: ThemeHelper.theme.hoverColor,
                                leading: const Icon(
                                  Icons.http,
                                  color: Colors.white,
                                  size: 30,
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios,
                                    color: Colors.white),
                                onTap: () async {
                                var res=  await Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              HttpNotificationScreen(
                                                notificationSettingModel:
                                                    _notification,
                                              )));

                                getNotificationSetting();



                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Divider(
                            height: 24,
                            thickness: 2,
                          ),
                          const SizedBox(height: 10),
                          const Padding(
                              padding: EdgeInsets.only(
                                  left: 25.0, right: 25.0, top: 15.0),
                              child: Text(
                                'Benachrichtigungen',
                                style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold),
                              )),
                          const SizedBox(height: 10),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 20.0, right: 20.0),
                            child: SwitchListTile(
                              title: const Text('E-Mail Benachrichtigungen'),
                              value: _notification.emailNotification!,
                              onChanged: _status
                                  ? null
                                  : (value) {
                                      setState(() {
                                        _notification.emailNotification = value;
                                      });
                                    },
                            ),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 20.0, right: 20.0),
                            child: SwitchListTile(
                              title: const Text('Anruf Benachrichtigungen'),
                              value: _notification.phoneCallNotification!,
                              onChanged: _status
                                  ? null
                                  : (value) {
                                      setState(() {
                                        _notification.phoneCallNotification =
                                            value;
                                      });
                                    },
                            ),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 20.0, right: 20.0),
                            child: SwitchListTile(
                              title: const Text('SMS Benachrichtigungen'),
                              value: _notification.smsNotification!,

                              // if !status -> disabled
                              onChanged: _status
                                  ? null
                                  : (value) {
                                      setState(() {
                                        _notification.smsNotification = value;
                                      });
                                    },
                            ),
                          ),
                          !_status ? _getActionButtons() : Container(),
                        ],
                      ),
                    )
                  ],
                ),
              ],
            )));
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    // passwordController.dispose();
    mailController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    super.dispose();
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

                    //check if user changed
                    if (firstNameController.text !=
                            AppAuth.getUser().firstName ||
                        lastNameController.text != AppAuth.getUser().lastName) {
                      var model = RegisterModel.create(firstNameController.text,
                          lastNameController.text, _user.email, "dummy123");
                      var res =
                          await locator.get<UserRepository>().editUser(model);

                      if (!res.success! || res.data == null) {
                        DialogHelper().displayErrorSnackBar(
                            context,
                            res.errorMessage ?? "Unbekannter Fehler.",
                            ContentType.failure);
                      } else {
                        var userModel = res.data! as UserModel;

                        var user = AppAuth.getUser();
                        user.firstName = userModel.firstName;
                        user.lastName = userModel.lastName;
                        await AppAuth.setUser(user);

                        setState(() {
                          firstNameController.text = userModel.firstName!;
                          lastNameController.text = userModel.lastName!;
                          // MainScreen.changePage(1);
                        });
                      }
                    }

                    if (_phoneNumberIdentical) {
                      _notification.smsNumber!.phoneNumber =
                          _notification.phoneNumber!.phoneNumber;
                    }

                    _notification.email!.email = AppAuth.getUser().email;
                    _notification.userId = AppAuth.getUser().id;

                    var updateResult = await locator
                        .get<NotificationRepository>()
                        .AddOrUpdateNotificationSetting(
                            AppAuth.getUser().id!, _notification);

                    if (!updateResult.success! || updateResult.data == null) {
                      DialogHelper().displayErrorSnackBar(
                          context,
                          updateResult.errorMessage ?? "Unbekannter Fehler.",
                          ContentType.failure);
                    }

                    DialogHelper().displayErrorSnackBar(context,
                        "Aktualisierung erfolgreich.", ContentType.success);

                    getNotificationSetting();

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
