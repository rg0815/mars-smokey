import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ssds_app/api/models/http_notification.dart';
import 'package:ssds_app/api/models/notification_setting_model.dart';
import 'package:ssds_app/api/repositories/notification_repository.dart';
import 'package:ssds_app/components/theme_helper.dart';
import 'package:ssds_app/helper/auth.dart';

import '../../api/models/http_header.dart';
import '../../components/custom_app_bar.dart';
import '../../services/service_locator.dart';

class HttpNotificationScreen extends StatefulWidget {
  const HttpNotificationScreen(
      {Key? key, required this.notificationSettingModel})
      : super(key: key);
  final NotificationSettingModel notificationSettingModel;

  @override
  _HttpNotificationScreenState createState() => _HttpNotificationScreenState();
}

class _HttpNotificationScreenState extends State<HttpNotificationScreen> {
  List<HttpNotificationModel> _httpNotificationModel = [];
  NotificationSettingModel _notificationSettingModel =
      NotificationSettingModel();

  @override
  void initState() {
    super.initState();
    _httpNotificationModel = widget.notificationSettingModel.httpNotifications!;
    _notificationSettingModel = widget.notificationSettingModel;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAdaptiveAppBar(
          centerTitle: true,
          title: const Text("HTTP-Einstellungen"),
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
        body: _httpNotificationModel.isEmpty
            ? const Center(
                child: Text("Keine HTTP-Benachrichtigungen vorhanden"))
            : ListView.builder(
                itemCount: _httpNotificationModel.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ExpansionTile(
                      leading: getLeadingIcon(_httpNotificationModel[index].method!),
                      title: Text(_httpNotificationModel[index].url!, style: ThemeHelper.listTileTitle(),),
                      subtitle: Text(
                        _httpNotificationModel[index]
                            .headers!
                            .map((header) => '${header.key}: ${header.value}')
                            .join('\n'),
                        style: ThemeHelper.listTileSubtitle(),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          setState(() {
                            _httpNotificationModel.removeAt(index);
                            _notificationSettingModel.httpNotifications =
                                _httpNotificationModel;
                          });
                          var res = await locator
                              .get<NotificationRepository>()
                              .AddOrUpdateNotificationSetting(
                                  AppAuth.getUser().id!,
                                  _notificationSettingModel);

                          if (!res.success!) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(res.errorMessage!),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("HTTP-Benachrichtigung gelöscht"),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                      ),
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Body: ${_httpNotificationModel[index].body}',
                            style: TextStyle(fontSize: 16.0),
                          ),
                        ),
                        if (_httpNotificationModel[index].headers!.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Keine Header vorhanden',
                              style: TextStyle(fontSize: 16.0, color: Colors.red),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ));
  }

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

  void _showAddNotificationDialog() {
    String? _selectedMethod;
    final _formKey = GlobalKey<FormState>();
    final _notification = HttpNotificationModel(
      url: '',
      method: '',
      body: '',
      headers: [],
    );

    // Liste für die Speicherung der Header-Formulare
    List<Widget> headerForms = [];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('HTTP-Benachrichtigung hinzufügen'),
            content: SizedBox(
              width: MediaQuery.of(context).size.width *
                  0.5, // 50% der Bildschirmbreite
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'URL'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Bitte URL eingeben';
                          }
                          return null;
                        },
                        onSaved: (value) => _notification.url = value!,
                      ),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(labelText: 'Methode'),
                        value: _selectedMethod,
                        items: <String>['GET', 'POST', 'PUT', 'DELETE', 'PATCH']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedMethod = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Bitte Methode auswählen';
                          }
                          return null;
                        },
                        onSaved: (value) => _notification.method = value!,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Body'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Bitte Body eingeben';
                          }
                          return null;
                        },
                        onSaved: (value) => _notification.body = value!,
                      ),
                      // Dynamisch generierte Header-Felder
                      for (int i = 0; i < headerForms.length; i++)
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                decoration: const InputDecoration(
                                    labelText: 'Header-Schlüssel'),
                                onSaved: (value) {
                                  if (value != null) {
                                    _notification.headers![i].key = value;
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                decoration: const InputDecoration(
                                    labelText: 'Header-Wert'),
                                onSaved: (value) {
                                  if (value != null) {
                                    _notification.headers![i].value = value;
                                  }
                                },
                              ),
                            ),
                            IconButton(
                              icon:
                                  const Icon(Icons.remove, color: Colors.white),
                              onPressed: () {
                                setState(() {
                                  headerForms.removeAt(i);
                                  _notification.headers?.removeAt(i);
                                });
                              },
                            ),
                          ],
                        ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                headerForms.add(Container());
                                _notification.headers
                                    ?.add(HttpHeader(key: '', value: ''));
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey, // Hintergrundfarbe
                            ),
                            child: const Text('Header hinzufügen'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text(
                  'Abbrechen',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text(
                  'Absenden',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    setState(() {
                      _httpNotificationModel.add(_notification);
                      _notificationSettingModel.httpNotifications =
                          _httpNotificationModel;
                    });

                    var res = await locator
                        .get<NotificationRepository>()
                        .AddOrUpdateNotificationSetting(
                            AppAuth.getUser().id!, _notificationSettingModel);
                    if (!res.success!) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(res.errorMessage!),
                        backgroundColor: Colors.red,
                      ));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: const Text('Benachrichtigung hinzugefügt'),
                        backgroundColor: Colors.green,
                      ));

                      setState(() {
                        _httpNotificationModel = res.data!.httpNotifications!;
                        _notificationSettingModel.httpNotifications =
                            _httpNotificationModel;
                      });

                      Navigator.of(context).pop();



                    }
                  }
                },
              ),
            ],
          );
        });
      },
    );
  }
}
