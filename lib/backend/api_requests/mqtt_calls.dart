import '/mqtt/mqtt_service.dart';

class MotorCalls {
  static Future<void> toldoFecharMqtt({
    required MQTTService mqtt,
  }) async {
    final topic = 'casa/erick/toldo_janela/toldo/cmd';
    mqtt.publish(topic, 'POS:100');
  }

  static Future<void> toldoAbrirMqtt({
    required MQTTService mqtt,
  }) async {
    final topic = 'casa/erick/toldo_janela/toldo/cmd';
    mqtt.publish(topic, 'POS:0');
  }

}