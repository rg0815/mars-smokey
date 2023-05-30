import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ssds_app/Screens/Password/components/password_reset_model.dart';
import 'package:ssds_app/api/repositories/user_repository.dart';

import '../../api/controller.dart';
import '../../components/header_widget.dart';
import '../../components/snackbar/snackbar.dart';
import '../../components/theme_helper.dart';
import '../../services/service_locator.dart';
import '../Login/login_screen.dart';

class PasswordResetRequestScreen extends StatefulWidget {
  const PasswordResetRequestScreen({Key? key}) : super(key: key);

  static const routeName = '/password-reset-request';

  @override
  _PasswordResetRequestScreenState createState() =>
      _PasswordResetRequestScreenState();
}

class _PasswordResetRequestScreenState
    extends State<PasswordResetRequestScreen> {
  final double _headerHeight = 250;
  final _formKey = GlobalKey<FormState>();
  final mailController = TextEditingController();

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
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.topLeft,
                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Passwort vergessen?',
                          style: TextStyle(
                              fontSize: 35, fontWeight: FontWeight.bold),
                          // textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Geben Sie die mit Ihrem Konto verbundene E-Mail-Adresse ein.',
                          style: TextStyle(
                              // fontSize: 20,
                              fontWeight: FontWeight.bold),
                          // textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Wir senden Ihnen per E-Mail einen Verifizierungscode, um Ihre Identität zu überprüfen.',
                          style: TextStyle(
                              // fontSize: 20,
                              ),
                          // textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40.0),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: TextFormField(
                            decoration: ThemeHelper().textInputDecoration(
                                "E-Mail", "E-Mail-Adresse eingeben"),
                            validator: (val) {
                              if (val!.isEmpty) {
                                return "E-Mail-Adresse darf nicht leer sein";
                              } else if (!RegExp(
                                      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$")
                                  .hasMatch(val)) {
                                return "Gültige E-Mail-Adresse eingeben";
                              }
                              return null;
                            },
                            controller: mailController,
                          ),
                          decoration: ThemeHelper().inputBoxDecorationShadow(),
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
                                  "Absenden".toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  var model = PasswordResetModel();
                                  model.email = mailController.text;
                                  var res = await  locator.get<UserRepository>()
                                      .resetPasswordRequest(model);
                                  if (!res.success!) {
                                    displayErrorSnackBar(
                                        context,
                                        res.errorMessage ??
                                            "Unbekannter Fehler.",
                                        ContentType.failure);
                                  } else {
                                    displayErrorSnackBar(
                                        context,
                                        "Passwort-Reset wurde erfolgreich angefragt.",
                                        ContentType.success);

                                   context.go("/login");
                                  }
                                }
                              }
                              // if (_formKey.currentState!.validate()) {
                              //   Navigator.pushReplacement(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) =>
                              //             ForgotPasswordVerificationPage()),
                              //   );
                              // }
                              // },
                              ),
                        ),
                        const SizedBox(height: 30.0),
                        Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                  text: "Erinnern Sie sich an Ihr Passwort? "),
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
                  )
                ],
              ),
            ),
          )
        ],
      ),
    ));
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
