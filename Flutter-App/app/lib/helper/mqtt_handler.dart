import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:mqtt5_client/mqtt5_browser_client.dart';
import 'package:mqtt5_client/mqtt5_client.dart';
import 'package:mqtt5_client/mqtt5_server_client.dart';
import 'package:ssds_app/globals.dart';

import '../api/models/mqtt/mqtt_message.dart';
import 'auth.dart';

class MqttHandler with ChangeNotifier {
  final ValueNotifier<List<StringPair>> smokeDetectorData =
      ValueNotifier<List<StringPair>>([]);
  late MqttServerClient client;
  late MqttBrowserClient webClient;

  Future<Object> connect() async {
    final String clientId = 'app_${AppAuth.getUser().id}';
    final token = AppAuth.getUser().accessToken;

    if (kIsWeb) {
      webClient = MqttBrowserClient.withPort(webSocketUrl, clientId, 5000,
          maxConnectionAttempts: 5);
      webClient.logging(on: true);
      webClient.keepAlivePeriod = 20;
      webClient.onConnected = onConnected;
      webClient.onDisconnected = onDisconnected;
      webClient.onSubscribed = onSubscribed;
      webClient.autoReconnect = true;
      webClient.resubscribeOnAutoReconnect = true;
    } else {
      client = MqttServerClient.withPort(webSocketUrl, clientId, 5000,
          maxConnectionAttempts: 5);
      client.logging(on: true);
      client.keepAlivePeriod = 20;
      client.onConnected = onConnected;
      client.onDisconnected = onDisconnected;
      client.onSubscribed = onSubscribed;
      client.autoReconnect = true;
      client.resubscribeOnAutoReconnect = true;
    }

    final connMess = MqttConnectMessage()
        .authenticateAs(AppAuth.getUser().email, token)
        .withClientIdentifier(clientId)
        .keepAliveFor(20)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);

    if (kIsWeb) {
      webClient.connectionMessage = connMess;

      try {
        await webClient.connect();
      } catch (e) {
        print('Exception: $e');
        webClient.disconnect();
      }
      if (webClient.connectionStatus!.state == MqttConnectionState.connected) {
        print('MQTT_LOGS:: web client connected');
      } else {
        print(
            'MQTT_LOGS::ERROR  client connection failed - disconnecting, status is ${webClient.connectionStatus}');
        webClient.disconnect();
        return -1;
      }
    } else {
      client.connectionMessage = connMess;

      try {
        await client.connect();
      } catch (e) {
        print('Exception: $e');
        client.disconnect();
      }

      if (client.connectionStatus!.state == MqttConnectionState.connected) {
        print('MQTT_LOGS:: client connected');
      } else {
        print(
            'MQTT_LOGS::ERROR  client connection failed - disconnecting, status is ${client.connectionStatus}');
        client.disconnect();
        return -1;
      }
    }

    print('MQTT_LOGS::Subscribing to the topic');
    String topic = 'ssds/app/down/${AppAuth.getUser().id}';

    if (kIsWeb) {
      webClient.subscribe(topic, MqttQos.atMostOnce);

      webClient.updates.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {

        print("MQTT_LOGS:: ${c![0].topic}");


        handleMessage(c![0].payload as MqttPublishMessage);
      });

      return webClient;
    } else {
      client.subscribe(topic, MqttQos.atMostOnce);

      client.updates.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
        handleMessage(c![0].payload as MqttPublishMessage);
      });

      return client;
    }
  }

  void onConnected() {
    print('MQTT_LOGS:: Connected');
  }

  void onDisconnected() {
    print('MQTT_LOGS:: Disconnected');
  }

  void onSubscribed(MqttSubscription subscription) {
    print(
        'EXAMPLE::Subscription confirmed for topic ${subscription.topic.rawTopic}');
  }

  void onSubscribeFail(String topic) {
    print('MQTT_LOGS:: Failed to subscribe $topic');
  }

  void onUnsubscribed(String? topic) {
    print('MQTT_LOGS:: Unsubscribed topic: $topic');
  }

  void pong() {
    print('MQTT_LOGS:: Ping response client callback invoked');
  }

  void publishMessage(String message) {
    const pubTopic = 'test/sample';
    final builder = MqttPayloadBuilder();
    builder.addString(message);

    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      client.publishMessage(pubTopic, MqttQos.atMostOnce, builder.payload!);
    }
  }

  void disconnect() {
    if (kIsWeb) {
      webClient.disconnect();
    } else {
      client.disconnect();
    }
  }

  void handleMessage(MqttPublishMessage payloadMessage) {
    final pt =
        MqttUtilities.bytesToStringAsString(payloadMessage.payload.message!);

    print(pt);
    CustomMqttMessage mqttMessage = CustomMqttMessage.fromJson(pt);
    print(mqttMessage.payload!);


    Map<String, dynamic> payload = jsonDecode(mqttMessage.payload!);

    if (mqttMessage.action == MqttMessageAction.SF_PairingSmokeDetectorInfo) {
      if (smokeDetectorData.value
          .any((item) => item.name == payload['smokeDetectorId'])) {
        return;
      } else {
        smokeDetectorData.value = List.from(smokeDetectorData.value)
          ..add( StringPair(payload['smokeDetectorId'], payload['protocolId']));
        notifyListeners();
      }
    }
  }
}

class StringPair {
  StringPair(this.name, this.value);

  String name;
  String value;
}
