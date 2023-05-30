import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ssds_app/api/models/automation_setting.dart';
import 'package:ssds_app/api/models/http_notification.dart';
import 'package:ssds_app/api/models/responses/response_model.dart';

import '../../components/custom_app_bar.dart';
import '../../components/theme_helper.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen(
      {Key? key, this.automationSettingId, this.preAlarmAutomationSettingId})
      : super(key: key);

  final AutomationSetting? automationSettingId;
  final PreAlarmAutomationSetting? preAlarmAutomationSettingId;

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late AutomationSetting? automationSetting;
  late PreAlarmAutomationSetting? preAlarmAutomationSetting;
  bool _isPreAlarm = false;

  @override
  void initState() {
    super.initState();
    automationSetting = widget.automationSettingId;
    preAlarmAutomationSetting = widget.preAlarmAutomationSettingId;

    if (preAlarmAutomationSetting != null) {
      _isPreAlarm = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAdaptiveAppBar(
        centerTitle: true,
        title: _isPreAlarm
            ? const Text("Voralarm-Benachrichtigungs-Einstellungen")
            : const Text("Benachrichtigungs-Einstellungen"),
        iconThemeData: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddNotificationDialog();
        },
        child: const Icon(Icons.add),
      ),
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 25.0),
            child: Card(
              child: ListTile(
                  trailing: const Icon(Icons.add, color: Colors.white),
                  onTap: () {
                    addNewNotification();
                  },
                  title: Text("HTTP-Benachrichtigungen")),
            ),
          ),
          ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.only(left: 25.0, right: 25.0, top: 25.0),
            children: getHttpSettings(),
          ),
          const SizedBox(
            height: 20.0,
          ),
          Padding(
            padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 25.0),
            child: Card(
              child: ListTile(
                trailing: const Icon(Icons.add, color: Colors.white),
                onTap: () {
                  addNewNotification();
                },
                title: Text("E-Mail-Benachrichtigungen"),
              ),
            ),
          ),
          ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.only(left: 25.0, right: 25.0, top: 25.0),
            children: getRoomItems(),
          ),
          const SizedBox(
            height: 20.0,
          ),
          Padding(
            padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 25.0),
            child: Card(
              child: ListTile(
                  trailing: const Icon(Icons.add, color: Colors.white),
                  onTap: () {
                    addNewNotification();
                  },
                  title: Text("SMS-Benachrichtigungen")),
            ),
          ),
          ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.only(left: 25.0, right: 25.0, top: 25.0),
            children: getRoomItems(),
          ),
          const SizedBox(
            height: 20.0,
          ),
          Padding(
            padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 25.0),
            child: Card(
              child: ListTile(
                trailing: const Icon(Icons.add, color: Colors.white),
                onTap: () {
                  addNewNotification();
                },
                title: Text("Anruf-Benachrichtigungen"),
              ),
            ),
          ),
          ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.only(left: 25.0, right: 25.0, top: 25.0),
            children: getRoomItems(),
          ),
          const SizedBox(
            height: 20.0,
          ),
        ],
      ),
    );
  }

  getHttpSettings() {
    var items = <Widget>[];

    var usedSettings = <HttpNotificationModel>[];
    if (_isPreAlarm && preAlarmAutomationSetting != null) {
      usedSettings = preAlarmAutomationSetting!.httpNotifications!;
    } else if (automationSetting != null) {
      usedSettings = automationSetting!.httpNotifications!;
    } else {
      return items;
    }

    for (var item in usedSettings) {
      items.add(Card(
        child: ExpansionTile(
          leading: getLeadingIcon(item.method!),
          title: Text(
            item.url!,
            style: ThemeHelper.listTileTitle(),
          ),
          subtitle: Text(
            item.headers!
                .map((header) => '${header.key}: ${header.value}')
                .join('\n'),
            style: ThemeHelper.listTileSubtitle(),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () async {},
          ),
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Body: ${item.body}',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            if (item.headers!.isEmpty)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Keine Header vorhanden',
                  style: TextStyle(fontSize: 16.0, color: Colors.red),
                ),
              ),
          ],
        ),
      ));
    }

    return items;
  }

  getRoomItems() {
    var items = <Widget>[];
    var usedSettings = <HttpNotificationModel>[];
    return items;
  }

  void addNewNotification() {}
}

void _showAddNotificationDialog() {}

getLeadingIcon(String method) {
  var color = Colors.grey;
  switch (method) {
    case 'GET':
      color = Colors.green;
      break;
    case 'POST':
      color = Colors.blue;
      break;
    case 'PUT':
      color = Colors.orange;
      break;
    case 'DELETE':
      color = Colors.red;
      break;
    case 'PATCH':
      color = Colors.purple;
      break;
  }

  return Container(
      width: 100,
      padding: const EdgeInsets.all(8),
      alignment: Alignment.center,
      color: color,
      child: Text(method,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          )));
}
