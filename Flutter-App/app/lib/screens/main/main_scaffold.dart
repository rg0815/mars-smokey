import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:marquee/marquee.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:ssds_app/Screens/main/components/scaffold_tabs.dart';
import 'package:ssds_app/api/repositories/fire_alarm_repository.dart';
import 'package:ssds_app/components/theme_helper.dart';
import 'package:ssds_app/helper/auth.dart';
import 'package:collection/collection.dart';
import 'package:ssds_app/helper/multi_tenant_notifier.dart';
import '../../api/models/responses/response_model.dart';
import '../../api/models/tenant_model.dart';
import '../../api/repositories/tenant_repository.dart';
import '../../components/custom_app_bar.dart';
import '../../components/custom_icon_button.dart';
import '../../components/custom_navigation_scaffold.dart';
import '../../components/custom_outline_button.dart';
import '../../services/service_locator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class MainScaffold extends ConsumerStatefulWidget {
  const MainScaffold({
    required this.selectedTab,
    required this.child,
    super.key,
    this.bottomTitle,
  });

  final ScaffoldTab selectedTab;
  final Widget child;
  final String? bottomTitle;

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<TenantModel> _tenants = [];
  late Future<ResponseModel> _tenantsRequest;
  late Future<ResponseModel> _fireAlarmResponse;

  @override
  void initState() {
    super.initState();
    _tenantsRequest = getTenants();
    _fireAlarmResponse = getFireAlarm();
    requestPermission();
    getToken();
    initInfo();
  }

  Future<ResponseModel> getFireAlarm(){
    var selectedTenant = ref.read(multiTenantProvider).selectedTenantId;
    if (selectedTenant != AppAuth.getUser().tenantId) {
      return locator
          .get<FireAlarmRepository>()
          .checkFireAlarmActive(tenantId: selectedTenant);
    }

    return locator.get<FireAlarmRepository>().checkFireAlarmActive();
  }

  Future<ResponseModel> getTenants() async {
    return locator.get<TenantRepository>().getTenants();
  }

  @pragma('vm:entry-point')
  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    // await Firebase.initializeApp(
    //     options: DefaultFirebaseOptions.currentPlatform);
    // await setupFlutterNotifications();
    showFlutterNotification(message);
    // If you're going to use other Firebase services in the background, such as Firestore,
    // make sure you call `initializeApp` before using other Firebase services.
    print('Handling a background message ${message.messageId}');
  }

  void showFlutterNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null && !kIsWeb) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            // TODO add a proper drawable resource to android, for now using
            //      one that already exists in example app.
            icon: 'launch_background',
          ),
        ),
      );
    }
  }

  /// Initialize the [FlutterLocalNotificationsPlugin] package.
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  Future<void> setupFlutterNotifications() async {
    if (isFlutterLocalNotificationsInitialized) {
      return;
    }
    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description:
          'This channel is used for important notifications.', // description
      importance: Importance.high,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    isFlutterLocalNotificationsInitialized = true;
  }

  /// Create a [AndroidNotificationChannel] for heads up notifications
  late AndroidNotificationChannel channel;

  bool isFlutterLocalNotificationsInitialized = false;

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission: ${settings.authorizationStatus}');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print(
          'User granted provisional permission: ${settings.authorizationStatus}');
    } else {
      print(
          'User declined or has not accepted permission: ${settings.authorizationStatus}');
    }
  }

  void getToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    print('Token: $token');

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      // Save newToken
    });

    //TODO send token to server
  }

  Future<void> initInfo() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    if (!kIsWeb) {
      await setupFlutterNotifications();
    }

    FirebaseMessaging.onBackgroundMessage((message) async {
      print("onBackgroundMessage: $message");
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print(
            'Message also contained a notification: ${message.notification!.body}');

        print("title: ${message.notification!.title}");
        print("body: ${message.notification!.body}");
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print(
            'Message also contained a notification: ${message.notification!.body}');

        print("title: ${message.notification!.title}");
        print("body: ${message.notification!.body}");
      }
    });
  }

  TenantModel? selectedValue;
  final TextEditingController textEditingController = TextEditingController();

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _fireAlarmResponse = getFireAlarm();

    return FutureBuilder(
        future: Future.wait([_tenantsRequest, _fireAlarmResponse]),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Scaffold(
              body: Center(
                child: Text("Error"),
              ),
            );
          } else if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          var res = snapshot.data![0] as ResponseModel;
          var fireRes = snapshot.data![1] as ResponseModel;
          if (!res.success!) {
            return Scaffold(
              body: Center(
                child: Text(res.errorMessage!),
              ),
            );
          }

          if (!fireRes.success! && fireRes.errorMessage != null && fireRes.errorMessage!.isNotEmpty && fireRes.errorMessage != "No fire active") {
            return Scaffold(
              body: Center(
                child: Text(fireRes.errorMessage!),
              ),
            );
          }

          _tenants = res.data as List<TenantModel>;
          bool fireActive;
          if(fireRes.errorMessage == "No fire active"){
            fireActive = false;
          }else{
            fireActive = true;
          }

          return Scaffold(
              key: _scaffoldKey,
              backgroundColor: ThemeHelper.theme.scaffoldBackgroundColor,
              body: CustomAdaptiveNavigationScaffold(
                drawerHeader: getHeader(),
                includeBaseDestinationsInMenu: true,
                appBar: getAppbar(widget.selectedTab),
                navigationTypeResolver: (context) {
                  if (MediaQuery.of(context).size.width > 1000) {
                    return NavigationType.permanentDrawer;
                  }

                  return NavigationType.drawer;
                },
                resizeToAvoidBottomInset: true,
                selectedIndex: getIndex(widget.selectedTab.index),
                body: Column(
                  children: [
                    fireActive ?
                    Container( color: Colors.white,
                      height: 30,
                      child: Marquee(
                        text: 'Achtung Feueralarm!',
                        accelerationCurve: Curves.easeOut,
                        startPadding: 10.0,
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade900, fontSize: 20),
                        blankSpace: 30.0,
                      ),
                    ) : Container(),
                    Expanded(child: widget.child),
                  ],
                ),
                onDestinationSelected: (int idx) {
                  _scaffoldKey.currentState!.closeDrawer();
                  switch (ScaffoldTab.values[idx]) {
                    case ScaffoldTab.profile:
                      context.go('/profile');
                      break;
                    case ScaffoldTab.dashboard:
                      context.go('/dashboard');
                      break;
                    case ScaffoldTab.building:
                      context.go('/building');
                      break;
                    case ScaffoldTab.buildingUnit:
                      context.go('/buildingUnit');
                      break;
                    case ScaffoldTab.gateway:
                      context.go('/gateway');
                      break;
                    case ScaffoldTab.smokeDetector:
                      context.go('/smokeDetector');
                      break;
                    case ScaffoldTab.tenants:
                      context.go('/tenants');
                      break;
                  }
                },
                drawerFooter: getFooter(),
                destinations: getDestinations(context, widget.selectedTab),
              ));
        });
  }

  List<CustomAdaptiveScaffoldDestination> getDestinations(
      BuildContext context, ScaffoldTab sTab) {
    var destinations =
        List<CustomAdaptiveScaffoldDestination>.empty(growable: true);
    destinations.add(CustomAdaptiveScaffoldDestination(
        title: 'Profil',
        icon: Icon(
          Icons.person,
          color: sTab == ScaffoldTab.profile
              ? ThemeHelper.theme.primaryColor
              : Colors.white,
        )));

    destinations.add(CustomAdaptiveScaffoldDestination(
      title: 'Dashboard',
      icon: Icon(Icons.dashboard,
          color: sTab == ScaffoldTab.dashboard
              ? ThemeHelper.theme.primaryColor
              : Colors.white),
    ));

    var user = AppAuth.getUser();
    if (user.isSuperAdmin == true) {
      destinations.add(CustomAdaptiveScaffoldDestination(
        title: 'Mandanten',
        icon: Icon(Icons.group,
            color: sTab == ScaffoldTab.tenants
                ? ThemeHelper.theme.primaryColor
                : Colors.white),
      ));
    }

    if (user.isSuperAdmin == true || user.isTenantAdmin == true) {
      destinations.add(CustomAdaptiveScaffoldDestination(
        title: 'Gebäude',
        icon: Icon(Icons.domain,
            color: isBuildingTab(sTab)
                ? ThemeHelper.theme.primaryColor
                : Colors.white),
      ));

      destinations.add(CustomAdaptiveScaffoldDestination(
        title: 'Gebäudeeinheit',
        icon: Icon(Icons.meeting_room,
            color: isBuildingUnitTab(sTab)
                ? ThemeHelper.theme.primaryColor
                : Colors.white),
      ));

      destinations.add(CustomAdaptiveScaffoldDestination(
        title: 'Gateway',
        icon: Icon(Icons.router,
            color: sTab == ScaffoldTab.gateway
                ? ThemeHelper.theme.primaryColor
                : Colors.white),
      ));
      destinations.add(CustomAdaptiveScaffoldDestination(
        title: 'Rauchmelder',
        icon: Icon(Icons.smoking_rooms,
            color: sTab == ScaffoldTab.smokeDetector
                ? ThemeHelper.theme.primaryColor
                : Colors.white),
      ));
    }

    return destinations;
  }

  bool isBuildingTab(ScaffoldTab selectedTab) {
    return selectedTab == ScaffoldTab.building ||
        selectedTab == ScaffoldTab.buildingDetails;
  }

  bool isBuildingUnitTab(ScaffoldTab selectedTab) {
    return selectedTab == ScaffoldTab.buildingUnit ||
        selectedTab == ScaffoldTab.buildingUnitDetails;
  }

  String getTitle(ScaffoldTab selectedTab) {
    switch (selectedTab) {
      case ScaffoldTab.profile:
        return 'Profil';
      case ScaffoldTab.dashboard:
        return 'Dashboard';
      case ScaffoldTab.building:
        return 'Gebäude';
      case ScaffoldTab.buildingUnit:
        return 'Gebäudeeinheit';
      case ScaffoldTab.gateway:
        return 'Gateway';
      case ScaffoldTab.smokeDetector:
        return 'Rauchmelder';
      case ScaffoldTab.tenants:
        if (AppAuth.getUser().isSuperAdmin == true) return 'Mandanten';
        return 'Mandant';
      case ScaffoldTab.buildingDetails:
        return "";
      case ScaffoldTab.buildingUnitDetails:
        return "";
    }

    return "";
  }

  getAppbar(ScaffoldTab selectedTab) {
    if (selectedTab == ScaffoldTab.buildingDetails) return null;
    if (selectedTab == ScaffoldTab.buildingUnitDetails) return null;

    return CustomAdaptiveAppBar(
      title: Text(getTitle(selectedTab)),
      centerTitle: true,
      iconThemeData: const IconThemeData(color: Colors.white),
    );
  }

  getIndex(int index) {
    if (index == 7) {
      return 3;
    }
    if (index == 8) {
      return 4;
    }
    return index;
  }

  List<DropdownMenuItem<String>> getItems() {
    List<DropdownMenuItem<String>> res = [];
    res = _tenants
        .map((item) => DropdownMenuItem(
              alignment: Alignment.center,
              value: item.id,
              child: Text(
                item.name!,
                style: const TextStyle(
                    // fontSize: 14,
                    ),
              ),
            ))
        .toList();

    return res;
  }

  getHeader() {
    return Column(children: [
      Image.asset(
        'assets/images/logo.png',
        width: 150,
      ),
      Divider(
        color: ThemeHelper.theme.dividerColor,
        thickness: 1,
        height: 30,
        indent: 10,
        endIndent: 10,
      ),
      Row(
        children: [
          Card(
            color: const Color(0xFF303030),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: DropdownButtonHideUnderline(
                child: DropdownButton2<String>(
              autofocus: false,
              alignment: Alignment.center,
              isExpanded: true,
              hint: Text(
                'Mandant auswählen',
                style: TextStyle(
                  fontSize: 16,
                  color: ThemeHelper.theme.hintColor,
                ),
              ),
              items: getItems(),

              value: selectedValue != null
                  ? selectedValue!.id!.isEmpty
                      ? AppAuth.selectedTenantId
                      : selectedValue!.id
                  : AppAuth.selectedTenantId,
              onChanged: (value) {
                setState(() {
                  selectedValue =
                      _tenants.where((element) => element.id == value).first;

                  ref
                      .read(multiTenantProvider.notifier)
                      .setSelectedTenant(selectedValue!.id!);
                });
              },
              buttonStyleData: const ButtonStyleData(
                height: 40,
                width: 225,
              ),
              dropdownStyleData: const DropdownStyleData(
                maxHeight: 500,
              ),
              menuItemStyleData: const MenuItemStyleData(
                height: 40,
              ),
              dropdownSearchData: DropdownSearchData(
                searchController: textEditingController,
                searchInnerWidgetHeight: 50,
                searchInnerWidget: Container(
                  height: 50,
                  padding: const EdgeInsets.only(
                    top: 8,
                    bottom: 4,
                    right: 8,
                    left: 8,
                  ),
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    expands: true,
                    maxLines: null,
                    controller: textEditingController,
                    decoration: InputDecoration(
                      // isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      hintText: 'Suche...',
                      hintStyle: const TextStyle(fontSize: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                searchMatchFn: (item, searchValue) {
                  var tenant = _tenants
                      .firstWhereOrNull((element) => element.id == item.value);

                  if (tenant == null) return false;

                  return (tenant.name!
                      .toString()
                      .toUpperCase()
                      .contains(searchValue.toUpperCase()));
                },
              ),
              //This to clear the search value when you close the menu
              onMenuStateChange: (isOpen) {
                if (!isOpen) {
                  textEditingController.clear();
                }
              },
            )),
          ),
          IconButton(
              onPressed: () {
                getTenants();
              },
              icon: const Icon(
                Icons.refresh,
                color: Colors.white,
              ))
        ],
      ),
      Divider(
        color: ThemeHelper.theme.dividerColor,
        thickness: 1,
        height: 30,
        indent: 10,
        endIndent: 10,
      ),
    ]);
  }

  getFooter() {
    return Column(
      children: [
        Card(
          color: const Color(0xFF303030),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            leading: const Icon(
              Icons.logout,
              color: Colors.white60,
            ),
            title: const Text("Abmelden",
                style: TextStyle(
                    color: Colors.white60, fontWeight: FontWeight.bold)),
            onTap: () {
              Dialogs.materialDialog(
                  dialogWidth: kIsWeb ? 0.3 : null,
                  context: context,
                  title: "Abmelden?",
                  msg: "Wirklich abmelden?",
                  color: ThemeHelper.theme.canvasColor,
                  actions: [
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
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await AppAuth.signOut();
                        context.go("/login");
                      },
                      text: 'Abmelden',
                      iconData: Icons.logout,
                      color: ThemeHelper.theme.primaryColorDark,
                      textStyle: const TextStyle(color: Colors.white),
                      iconColor: Colors.white,
                    ),
                  ]);
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Version 1.0.0',
                style: ThemeHelper.theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
