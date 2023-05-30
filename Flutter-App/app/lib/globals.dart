library app.globals;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

Level logLevel = Level.info;
GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final GlobalKey<ScaffoldMessengerState> snackbarKey =
    GlobalKey<ScaffoldMessengerState>();

String systemServiceUrl = "";
String userServiceUrl = "";
String webSocketUrl = "";
String? passwordResetToken;
String? fcmToken;

// String selectedTenantId = "";
