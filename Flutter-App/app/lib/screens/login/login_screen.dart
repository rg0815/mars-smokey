import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ssds_app/api/controller.dart';
import 'package:ssds_app/api/models/requests/login_model.dart';
import 'package:ssds_app/helper/auth.dart';
import 'package:ssds_app/helper/dialog_helper.dart';
import 'package:ssds_app/services/service_locator.dart';

import '../../components/header_widget.dart';
import '../../components/snackbar/snackbar.dart';
import '../../components/theme_helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  static String routeName = '/login';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  _LoginScreenState() {
    // if (AppAuthScope.of(context).isLoggedIn()) {
    // context.go("/dashboard");
    // }
  }

  final Key _formKey = GlobalKey<FormState>();
  final double _headerHeight = 250;

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  /// This error message will be displayed in the error SnackBar
  var errorMessage = "";
  final bool _obscurePassword = true;

  @override
  void dispose() {
    usernameController.dispose();
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
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: Column(
                    children: [
                      const Text(
                        'Hallo!',
                        style: TextStyle(
                            fontSize: 60, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 30.0),
                      Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Container(
                                decoration:
                                    ThemeHelper().inputBoxDecorationShadow(),
                                child: TextField(
                                  controller: usernameController,
                                  textInputAction: TextInputAction.next,
                                  decoration: ThemeHelper().textInputDecoration(
                                      'Benutzername', 'Benutzername eingeben'),
                                ),
                              ),
                              const SizedBox(height: 30.0),
                              Container(
                                decoration:
                                    ThemeHelper().inputBoxDecorationShadow(),
                                child: TextField(
                                  controller: passwordController,
                                  obscureText: _obscurePassword,
                                  textInputAction: TextInputAction.go,
                                  decoration: ThemeHelper().textInputDecoration(
                                      'Passwort', 'Passwort eingeben'),
                                  onSubmitted: (value) async {
                                    if ((usernameController.text == '') ||
                                        (passwordController.text == '')) {
                                      errorMessage =
                                          "Bitte geben Sie einen Benutzernamen und ein Passwort ein.";

                                      DialogHelper().displayErrorSnackBar(
                                          context,
                                          errorMessage,
                                          ContentType.failure);
                                      return;
                                    }

                                    var model = LoginModel(
                                        mail: usernameController.text,
                                        password: passwordController.text);

                                    var res = await AppAuth.signIn(model, context);
                                    if (res) {
                                      context.go('/dashboard');
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(height: 15.0),
                              Container(
                                margin:
                                    const EdgeInsets.fromLTRB(10, 0, 10, 20),
                                alignment: Alignment.topRight,
                                child: GestureDetector(
                                  onTap: () {
                                    context.go("/password-forgot");
                                  },
                                  child: const Text(
                                    "Passwort vergessen?",
                                    style: TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                decoration:
                                    ThemeHelper().buttonBoxDecoration(context),
                                child: ElevatedButton(
                                  style: ThemeHelper().buttonStyle(),
                                  onPressed: () async {
                                    if ((usernameController.text == '') ||
                                        (passwordController.text == '')) {
                                      errorMessage =
                                          "Bitte geben Sie einen Benutzernamen und ein Passwort ein.";
                                      DialogHelper().displayErrorSnackBar(
                                          context,
                                          errorMessage,
                                          ContentType.failure);
                                      return;
                                    }

                                    var model = LoginModel(
                                        mail: usernameController.text,
                                        password: passwordController.text);

                                    var res = await AppAuth.signIn(model, context);
                                    if (res) {
                                      context.go('/dashboard');
                                    }

                                    // var res = await controller.authRepository
                                    //     .login(model);
                                    //
                                    // if (!res.success || res.data == null) {
                                    //   DialogHelper().displayErrorSnackBar(
                                    //       context,
                                    //       res.errorMessage ??
                                    //           "Unbekannter Fehler.",
                                    //       ContentType.failure);
                                    // } else {
                                    //   await AppAuthScope.of(context)
                                    //       .loginManually(
                                    //           res.data as LoginResponseModel);
                                    //
                                    //   context.go('/dashboard');

                                    // Navigator.pushReplacement(
                                    //     context,
                                    //     MaterialPageRoute(
                                    //         builder: (context) =>
                                    //             const MainScreen()));
                                    // }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        40, 10, 40, 10),
                                    child: Text(
                                      'Anmelden'.toUpperCase(),
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                margin:
                                    const EdgeInsets.fromLTRB(10, 20, 10, 20),
                                //child: Text('Don\'t have an account? Create'),
                                child: Text.rich(TextSpan(children: [
                                  const TextSpan(
                                      text: "Noch kein Konto vorhanden? "),
                                  TextSpan(
                                    text: 'Neuen Mandanten anlegen',
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                      context.go("/register");
                                      },
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: ThemeHelper.theme.colorScheme
                                            .secondary),
                                  ),
                                ])),
                              ),
                            ],
                          )),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
