import 'package:email_validator/email_validator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ssds_app/api/models/requests/register_tenant_admin_model.dart';
import 'package:ssds_app/api/models/tenant_model.dart';
import 'package:ssds_app/api/repositories/tenant_repository.dart';

import '../../api/controller.dart';
import '../../api/models/requests/register_model.dart';
import '../../api/repositories/user_repository.dart';
import '../../components/header_widget.dart';
import '../../components/snackbar/snackbar.dart';
import '../../components/theme_helper.dart';
import '../../services/service_locator.dart';

class RegisterTenantScreen extends StatefulWidget {
  const RegisterTenantScreen({Key? key}) : super(key: key);

  @override
  _RegisterTenantScreenState createState() => _RegisterTenantScreenState();
}

class _RegisterTenantScreenState extends State<RegisterTenantScreen> {
  final double _headerHeight = 250;
  final _formKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();
  final _model = RegisterTenantAdminModel();

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
                              'Neuen Mandanten anlegen',
                              style: TextStyle(
                                  fontSize: 35, fontWeight: FontWeight.bold),
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
                                    'Mandantenname', 'Mandantenname eingeben'),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Bitte einen Mandantenname eingeben';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _model.tenantName = value!;
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
                                  _model.tenantDescription = value!;
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
                                    'Vorname', 'Vorname eingeben'),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Bitte einen Vornamen eingeben';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _model.firstName = value!;
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
                                  _model.lastName = value!;
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
                                  _model.email = value!;
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
                                  _model.password = value!;
                                },
                                controller: passwordController,
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
                                    "Konto anlegen".toUpperCase(),
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

                                    var tenantModel = TenantModel();
                                    tenantModel.name = _model.tenantName;
                                    tenantModel.description =
                                        _model.tenantDescription;

                                    var res = await locator
                                        .get<TenantRepository>()
                                        .createTenant(tenantModel);
                                    if (res.success!) {
                                      var tenantId = res.data.id;
                                      var userModel = RegisterModel();
                                      userModel.email = _model.email!;
                                      userModel.firstName = _model.firstName!;
                                      userModel.lastName = _model.lastName!;
                                      userModel.password = _model.password!;
                                      var result = await locator
                                          .get<UserRepository>()
                                          .registerTenantAdmin(
                                              userModel, tenantId);

                                      if (!result.success! ||
                                          result.data == null) {
                                        displayErrorSnackBar(
                                            context,
                                            result.errorMessage ??
                                                "Unbekannter Fehler.",
                                            ContentType.failure);
                                      } else {
                                        displayErrorSnackBar(
                                            context,
                                            "Registrierung erfolgreich. Sie können sich nun einloggen.",
                                            ContentType.success);
                                        context.go("/login");
                                      }
                                    } else {
                                      displayErrorSnackBar(
                                          context,
                                          res.errorMessage ??
                                              "Unbekannter Fehler.",
                                          ContentType.failure);
                                    }
                                  }
                                },
                              ),
                            ),
                            const SizedBox(height: 30.0),
                            Text.rich(
                              TextSpan(
                                children: [
                                  const TextSpan(
                                      text: "Sie haben bereits ein Konto? "),
                                  TextSpan(
                                    text: 'Zum Login',
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        context.go("/login");
                                      },
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: ThemeHelper.theme.colorScheme
                                            .secondary),
                                  ),
                                ],
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
