import 'dart:async';
import 'dart:io'; 

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';


Future<void> main() async {
  final client = await connect();

  if (client.connectionStatus!.state == MqttConnectionState.connected) {
    print('MAIN:: Client connected. Subscribing to a topic...');
    
    const topic = 'test/topic'; 
    client.subscribe(topic, MqttQos.atLeastOnce);

    print('MAIN:: Publishing a test message...');
    final builder = MqttClientPayloadBuilder();
    builder.addString('Hello from Dart MQTT Client!');
    client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);

    print('MAIN:: Setup complete. Listening for messages...');
    print('MAIN:: Press Enter to exit.');
    await stdin.first;

    print('MAIN:: Disconnecting MQTT client...');
    client.disconnect();
  } else {
    print('MAIN:: MQTT client failed to connect. State: ${client.connectionStatus!.state}');
    exit(-1); 
  }
}

Future<MqttClient> connect() async {
  final String clientId = 'clientId-Erick-${DateTime.now().millisecondsSinceEpoch}';
  MqttServerClient client = MqttServerClient.withPort(
      'ba383544cf1b4a0c93db9ddfe621858f.s1.eu.hivemq.cloud',
      clientId,
      8883);

  client.logging(on: true);
  client.keepAlivePeriod = 60;
  client.secure = true; 
  client.onConnected = onConnected;
  client.onDisconnected = onDisconnected;
  client.onUnsubscribed = onUnsubscribed;
  client.onSubscribed = onSubscribed;
  client.onSubscribeFail = onSubscribeFail;
  client.pongCallback = pong;

  final connMess = MqttConnectMessage()
      .authenticateAs("Erickkk", "96488941Ab") 
      .withWillTopic('willtopic') 
      .withWillMessage('My Will message') 
      .startClean() 
      .withWillQos(MqttQos.atLeastOnce); 
  
  print('CONNECT:: MQTT client connecting....');
  client.connectionMessage = connMess;

  try {
    await client.connect();
  } on NoConnectionException catch (e) {
    print('CONNECT:: Client exception - NoConnectionException: $e');
    client.disconnect();
  } on SocketException catch (e) {
    print('CONNECT:: Client exception - SocketException: $e');
    client.disconnect();
  } catch (e) {
    print('CONNECT:: Client exception: $e');
    client.disconnect();
  }

  if (client.connectionStatus!.state != MqttConnectionState.connected) {
    print('CONNECT:: ERROR: MQTT client connection failed - status is ${client.connectionStatus}');
    client.disconnect();
  } else {
     print('CONNECT:: MQTT client connected.');
  }

  client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
    if (c != null && c.isNotEmpty) {
      final recMessage = c[0].payload as MqttPublishMessage;
      final payload = MqttPublishPayload.bytesToStringAsString(recMessage.payload.message);

      print('RECEIVED:: message: "$payload" from topic: ${c[0].topic}');
    }
  });

  return client;
}

void onConnected() {
  print('CALLBACK:: OnConnected client callback - Connected!');
}

void onDisconnected() {
  print('CALLBACK:: OnDisconnected client callback - Disconnected!');
}

void onSubscribed(String topic) {
  print('CALLBACK:: Subscribed topic: $topic');
}

void onSubscribeFail(String topic) {
  print('CALLBACK:: Failed to subscribe to $topic');
}

void onUnsubscribed(String? topic) {
  print('CALLBACK:: Unsubscribed topic: $topic');
}

void pong() {
  print('CALLBACK:: Ping response client callback invoked');
}
