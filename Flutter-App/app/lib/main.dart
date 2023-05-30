import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ssds_app/components/theme_helper.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:ssds_app/helper/auth.dart';
import 'package:ssds_app/router/app_router.dart';
import 'package:ssds_app/services/service_locator.dart' as service_locator;
import 'package:flutter_web_plugins/url_strategy.dart';
import 'globals.dart' as globals;

import 'log_helper.dart';
import 'services/messaging_service.dart';

Future<void> main() async {
  final logger = getLogger();
  var widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseMessaging.instance.getInitialMessage();
  usePathUrlStrategy();
  service_locator.setup();
  await AppAuth.tryAutoLogin();
  // FlutterError.onError = (FlutterErrorDetails details) {
  //   FlutterError.presentError(details);
  //   logger.e(details.exception);
  // };

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ThemeData theme = ThemeHelper.theme;

  final logger = getLogger();

  final ValueKey<String> _scaffoldKey = const ValueKey<String>('App scaffold');
  final messagingService = MessagingService();

  @override
  void initState() {
    super.initState();
    messagingService.init();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: (context, snapshot) {
        FlutterNativeSplash.remove();
        return MaterialApp.router(
          routerConfig: _router,
          // builder: (context, child) => ResponsiveWrapper.builder(
          //   BouncingScrollWrapper.builder(context, child!),
          //   maxWidth: 2000,
          //   minWidth: 450,
          //   defaultScale: true,
          //   breakpoints: [
          //     const ResponsiveBreakpoint.resize(450, name: MOBILE),
          //     const ResponsiveBreakpoint.autoScale(800, name: TABLET),
          //     const ResponsiveBreakpoint.autoScale(1000, name: TABLET),
          //     const ResponsiveBreakpoint.resize(1200, name: DESKTOP),
          //     const ResponsiveBreakpoint.autoScale(2460, name: "4K"),
          //   ],
          //   background: Container(
          //     color: const Color(0xFF303030),
          //   ),
          // ),
          debugShowCheckedModeBanner: true,
          title: 'mars smokey',
          theme: theme,
          scaffoldMessengerKey: globals.snackbarKey,
        );
      },
    );
  }

  late final _router = GoRouter(
    navigatorKey: globals.navigatorKey,
    routes: AppRouter.getRoutes(),
    redirect: (context, state) {
      return AppRouter.getGuard(context, state);
    },
    debugLogDiagnostics: true,
  );
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        // etc.
      };
}
