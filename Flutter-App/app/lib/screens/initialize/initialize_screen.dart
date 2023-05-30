import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ssds_app/api/repositories/init_repository.dart';
import 'package:ssds_app/main.dart';

import '../../api/controller.dart';
import '../../api/models/requests/register_model.dart';
import '../../api/models/tenant_model.dart';
import '../../api/repositories/tenant_repository.dart';
import '../../components/header_widget.dart';
import '../../components/snackbar/snackbar.dart';
import '../../components/theme_helper.dart';
import '../../services/service_locator.dart';

class InitializeScreen extends StatefulWidget {
  const InitializeScreen({Key? key}) : super(key: key);

  @override
  _InitializeScreenState createState() => _InitializeScreenState();
}

class _InitializeScreenState extends State<InitializeScreen> {
  final double _headerHeight = 250;
  final _formKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();
  final _user = RegisterModel();
  final _tenant = TenantModel();

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: _headerHeight,
              child: HeaderWidget(_headerHeight, true),
            ),
            SafeArea(
              child: Container(
                margin: const EdgeInsets.fromLTRB(25, 10, 25, 10),
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 25,
                            ),
                            const Text(
                              'Anwendung initialisieren. Bitte Daten für SuperUser eingeben.',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                              // textAlign: TextAlign.center,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Container(
                              decoration:
                                  ThemeHelper().inputBoxDecorationShadow(),
                              child: TextFormField(
                                decoration: ThemeHelper().textInputDecoration(
                                    'Vorname', 'Vorname eingeben'),
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
                            const SizedBox(
                              height: 20,
                            ),
                            Container(
                              decoration:
                                  ThemeHelper().inputBoxDecorationShadow(),
                              child: TextFormField(
                                decoration: ThemeHelper().textInputDecoration(
                                    'Nachname', 'Nachname eingeben'),
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
                            const SizedBox(height: 20.0),
                            Container(
                              decoration:
                                  ThemeHelper().inputBoxDecorationShadow(),
                              child: TextFormField(
                                decoration: ThemeHelper().textInputDecoration(
                                    "E-Mail-Adresse",
                                    "E-Mail-Adresse eingeben"),
                                keyboardType: TextInputType.emailAddress,
                                validator: (val) {
                                  if (val!.isNotEmpty) {
                                    var valid = EmailValidator.validate(val);
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
                            const SizedBox(height: 20.0),
                            Container(
                              decoration:
                                  ThemeHelper().inputBoxDecorationShadow(),
                              child: TextFormField(
                                obscureText: true,
                                decoration: ThemeHelper().textInputDecoration(
                                    "Passwort", "Passwort eingeben"),
                                validator: (val) {
                                  if (val!.isEmpty) {
                                    return "Passwort eingeben";
                                  } else if (val.length < 6) {
                                    return "Passwort muss mindestens 6 Zeichen lang sein";
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _user.password = value!;
                                },
                                controller: passwordController,
                              ),
                            ),
                            const SizedBox(height: 20.0),
                            const Divider(
                              height: 20,
                              thickness: 2,
                            ),
                            const SizedBox(height: 20.0),
                            Container(
                              decoration:
                                  ThemeHelper().inputBoxDecorationShadow(),
                              child: TextFormField(
                                decoration: ThemeHelper().textInputDecoration(
                                    'Mandantenname', 'Mandantenname eingeben'),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Bitte einen Mandantenname eingeben';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _tenant.name = value!;
                                },
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Container(
                              decoration:
                                  ThemeHelper().inputBoxDecorationShadow(),
                              child: TextFormField(
                                decoration: ThemeHelper().textInputDecoration(
                                    'Mandantenbeschreibung',
                                    'Mandantenbeschreibung eingeben'),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Bitte eine Mandantenbeschreibung eingeben';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _tenant.description = value!;
                                },
                              ),
                            ),
                            const SizedBox(height: 40.0),
                            Container(
                              decoration:
                                  ThemeHelper().buttonBoxDecoration(context),
                              child: ElevatedButton(
                                style: ThemeHelper().buttonStyle(),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(40, 10, 40, 10),
                                  child: Text(
                                    "Initialisieren und Account anlegen"
                                        .toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    _formKey.currentState!.save();

                                    var tRes = await locator
                                        .get<TenantRepository>()
                                        .createTenant(_tenant);
                                    if (tRes.success!) {
                                      var tenantId = tRes.data.id as String;

                                      var model = RegisterModel.createTenantAdmin(
                                          _user.firstName,
                                          _user.lastName,
                                          _user.email,
                                          _user.password,
                                          tenantId);
                                      var res = await locator
                                          .get<InitRepository>()
                                          .initialize(model);

                                      if (!res.success! || res.data == null) {
                                        displayErrorSnackBar(
                                            context,
                                            res.errorMessage ??
                                                "Unbekannter Fehler.",
                                            ContentType.failure);
                                      } else {
                                        displayErrorSnackBar(
                                            context,
                                            "Initialisierung erfolgreich. Sie können sich nun einloggen.",
                                            ContentType.success);

                                        context.go("/login");
                                      }
                                    } else {
                                      displayErrorSnackBar(
                                          context,
                                          tRes.errorMessage ??
                                              "Unbekannter Fehler.",
                                          ContentType.failure);
                                    }
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void displayErrorSnackBar(
      BuildContext context, String errorMessage, ContentType contentType) {
    var title = "";
    if (contentType == ContentType.failure) {
      title = "Fehler!";
    } else if (contentType == ContentType.success) {
      title = "Erfolg!";
    } else if (contentType == ContentType.warning) {
      title = "Warnung!";
    } else if (contentType == ContentType.help) {
      title = "Hilfe!";
    }

    var width = context.size?.width;

    final snackBar = SnackBar(
        width: width,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: title,
          message: errorMessage,
          contentType: contentType,
        ));

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
