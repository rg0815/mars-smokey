import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ssds_app/api/models/user_invitation.dart';
import 'package:ssds_app/api/repositories/user_repository.dart';

import '../../api/controller.dart';
import '../../api/models/requests/register_model.dart';
import '../../api/models/responses/response_model.dart';
import '../../components/header_widget.dart';
import '../../components/snackbar/snackbar.dart';
import '../../components/theme_helper.dart';
import '../../services/service_locator.dart';

class RegisterUserInvitationScreen extends StatefulWidget {
  const RegisterUserInvitationScreen({Key? key, required this.invitationToken})
      : super(key: key);

  final String invitationToken;

  @override
  _RegisterUserInvitationScreenState createState() =>
      _RegisterUserInvitationScreenState();
}

class _RegisterUserInvitationScreenState
    extends State<RegisterUserInvitationScreen> {
  late Future<ResponseModel> _response;
  final double _headerHeight = 250;
  final _formKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();
  final _user = RegisterModel();

  @override
  void initState() {
    super.initState();
    _response =
        locator.get<UserRepository>().getInvitation(widget.invitationToken);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _response,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        }
        if (snapshot.hasData) {
          var invitation = UserInvitation.fromJson(snapshot.data!.data);

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
                              alignment: Alignment.topLeft,
                              margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Anlegen eines neuen Kontos',
                                    style: TextStyle(
                                        fontSize: 35,
                                        fontWeight: FontWeight.bold),
                                    // textAlign: TextAlign.center,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    'Sie wurden von Ihrem Mandanten eingeladen, ein neues Konto anzulegen.',
                                    style: TextStyle(
                                        // fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                    // textAlign: TextAlign.center,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    'Bitte geben Sie Ihre Daten ein und bestätigen Sie die Registrierung.',
                                    style: TextStyle(
                                        // fontSize: 20,
                                        ),
                                    // textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
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
                                        fontSize: 35,
                                        fontWeight: FontWeight.bold),
                                    // textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Container(
                                    decoration: ThemeHelper()
                                        .inputBoxDecorationShadow(),
                                    child: TextFormField(
                                      decoration: ThemeHelper()
                                          .textInputDecoration(
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
                                    decoration: ThemeHelper()
                                        .inputBoxDecorationShadow(),
                                    child: TextFormField(
                                      decoration: ThemeHelper()
                                          .textInputDecoration(
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
                                    decoration: ThemeHelper()
                                        .inputBoxDecorationShadow(),
                                    child: TextFormField(
                                      decoration: ThemeHelper()
                                          .textInputDecoration("E-Mail-Adresse",
                                              "E-Mail-Adresse eingeben"),
                                      keyboardType: TextInputType.emailAddress,
                                      readOnly: true,
                                      controller: TextEditingController(
                                          text: invitation.email),
                                    ),
                                  ),
                                  const SizedBox(height: 20.0),
                                  Container(
                                    decoration: ThemeHelper()
                                        .inputBoxDecorationShadow(),
                                    child: TextFormField(
                                      obscureText: true,
                                      decoration: ThemeHelper()
                                          .textInputDecoration(
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
                                  const SizedBox(height: 40.0),
                                  Container(
                                    decoration: ThemeHelper()
                                        .buttonBoxDecoration(context),
                                    child: ElevatedButton(
                                      style: ThemeHelper().buttonStyle(),
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            40, 10, 40, 10),
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

                                          var model = RegisterModel.create(
                                              _user.firstName,
                                              _user.lastName,
                                              invitation.email!,
                                              _user.password);
                                          var res = await  locator.get<UserRepository>()
                                              .registerUser(model, invitation.registrationToken!);

                                          if (!res.success! ||
                                              res.data == null) {
                                            displayErrorSnackBar(
                                                context,
                                                res.errorMessage ??
                                                    "Unbekannter Fehler.",
                                                ContentType.failure);
                                          } else {
                                            displayErrorSnackBar(
                                                context,
                                                "Registrierung erfolgreich. Sie können sich nun einloggen.",
                                                ContentType.success);
                                            context.go("/login");
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
                                            text:
                                                "Sie haben bereits ein Konto? "),
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
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
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
