import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:provider/provider.dart';

import '../flutter/theme.dart';
import '../flutter/util.dart';
import '../flutter/widgets.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:auto_haus/l10n/app_localizations.dart';

import 'velocidades_model.dart';
export 'velocidades_model.dart';

class VelocidadesWidget extends StatefulWidget {
  const VelocidadesWidget({super.key});

  static String routeName = 'Velocidades';
  static String routePath = '/velocidades';

  @override
  State<VelocidadesWidget> createState() => _VelocidadesWidgetState();
}

class _VelocidadesWidgetState extends State<VelocidadesWidget> {
  late VelocidadesModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  MqttServerClient? _client;
  StreamSubscription? _updatesSubscription;

  final String _topicBase = "casa/erick/toldo_janela";
  late final String _topicToldoVelocidadeSet;
  late final String _topicToldoVelocidadeReset;
  late final String _topicJanelaVelocidadeSet;
  late final String _topicJanelaVelocidadeReset;
  late final String _topicVelocidadesGeralEstado;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => VelocidadesModel());

    _topicToldoVelocidadeSet = '$_topicBase/toldo/velocidade/set';
    _topicToldoVelocidadeReset = '$_topicBase/toldo/velocidade/reset';
    _topicJanelaVelocidadeSet = '$_topicBase/janela/velocidade/set';
    _topicJanelaVelocidadeReset = '$_topicBase/janela/velocidade/reset';
    _topicVelocidadesGeralEstado = '$_topicBase/velocidades/estado';

    _model.textFieldATTextController ??=
        TextEditingController(text: FlutterAppState().velAtras.toString());
    _model.textFieldATFocusNode ??= FocusNode();

    _model.textFieldBFTextController ??=
        TextEditingController(text: FlutterAppState().velBfrente.toString());
    _model.textFieldBFFocusNode ??= FocusNode();

    _model.textController3 ??=
        TextEditingController(text: FlutterAppState().velJanelaAbrir.toString());
    _model.textFieldFocusNode1 ??= FocusNode();

    _model.textFieldAFTextController ??=
        TextEditingController(text: FlutterAppState().velAfrente.toString());
    _model.textFieldAFFocusNode ??= FocusNode();

    _model.textFieldBTTextController ??=
        TextEditingController(text: FlutterAppState().velBtras.toString());
    _model.textFieldBTFocusNode ??= FocusNode();

    _model.textController6 ??=
        TextEditingController(text: FlutterAppState().velJanelaFechar.toString());
    _model.textFieldFocusNode2 ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _connect();
    });
  }

  @override
  void dispose() {
    _updatesSubscription?.cancel();
    _client?.disconnect();
    _model.dispose();
    super.dispose();
  }

  void _log(String message) {
    debugPrint('[MQTT Velocidades] $message');
  }

  Future<void> _connect() async {
    if (_client?.connectionStatus?.state == MqttConnectionState.connected || _client?.connectionStatus?.state == MqttConnectionState.connecting) return;

    final String url = 'e637335d485a428f98d9fb45c66b6923.s1.eu.hivemq.cloud';
    final int port = 8883;
    final String username = 'Erickkk';
    final String password = '96488941Ab';
    final String clientId = 'flutter_velocidades_ui_${DateTime.now().millisecondsSinceEpoch}';

    _log('Iniciando conexão com $url:$port...');
    _client = MqttServerClient.withPort(url, clientId, port)
      ..logging(on: false)
      ..keepAlivePeriod = 30
      ..onConnected = _onConnected
      ..onDisconnected = _onDisconnected
      ..onSubscribed = (topic) => _log('Inscrito no tópico: $topic');

    _client!.secure = true;
    _client!.securityContext = SecurityContext.defaultContext;
    _client!.connectionMessage = MqttConnectMessage().withClientIdentifier(clientId).startClean();

    try {
      await _client!.connect(username, password);
    } catch (e) {
      _log('ERRO ao conectar: ${e.toString()}');
      _disconnect();
    }
  }

  void _onConnected() {
    _log('Conexão MQTT estabelecida!');
    if (!mounted) return;

    _client!.subscribe(_topicVelocidadesGeralEstado, MqttQos.atLeastOnce);

    _updatesSubscription = _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
      final String payload = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      final String topic = c[0].topic;

      _log('Mensagem recebida no tópico [$topic]: "$payload"');

      try {
        final Map<String, dynamic> jsonPayload = json.decode(payload);
        if (!mounted) return;

        setState(() {
          if (topic == _topicVelocidadesGeralEstado) {
            if (jsonPayload.containsKey('toldo')) {
              final toldoVels = jsonPayload['toldo'];
              FlutterAppState().velAfrente = (toldoVels['vaf'] as num?)?.toInt() ?? FlutterAppState().velAfrente;
              FlutterAppState().velBfrente = (toldoVels['vbf'] as num?)?.toInt() ?? FlutterAppState().velBfrente;
              FlutterAppState().velAtras = (toldoVels['vat'] as num?)?.toInt() ?? FlutterAppState().velAtras;
              FlutterAppState().velBtras = (toldoVels['vbt'] as num?)?.toInt() ?? FlutterAppState().velBtras;
            }
            if (jsonPayload.containsKey('janela')) {
              final janelaVels = jsonPayload['janela'];
              FlutterAppState().velJanelaAbrir = (janelaVels['vabrir'] as num?)?.toInt() ?? FlutterAppState().velJanelaAbrir;
              FlutterAppState().velJanelaFechar = (janelaVels['vfechar'] as num?)?.toInt() ?? FlutterAppState().velJanelaFechar;
            }

            _model.textFieldATTextController?.text = FlutterAppState().velAtras.toString();
            _model.textFieldBFTextController?.text = FlutterAppState().velBfrente.toString();
            _model.textController3?.text = FlutterAppState().velJanelaAbrir.toString();
            _model.textFieldAFTextController?.text = FlutterAppState().velAfrente.toString();
            _model.textFieldBTTextController?.text = FlutterAppState().velBtras.toString();
            _model.textController6?.text = FlutterAppState().velJanelaFechar.toString();

            FlutterAppState().update(() {}); 
          }
        });
      } catch (e) {
        _log("Erro ao processar mensagem do tópico [$topic]: $e");
      }
    });
  }

  void _onDisconnected() {
    _log('Desconectado do MQTT.');
  }

  void _disconnect() {
    _client?.disconnect();
  }

  void _publishCommand(String topic, String message) {
    if (_client?.connectionStatus?.state != MqttConnectionState.connected) {
      _log('Não conectado, impossível publicar.');
      return;
    }
    final builder = MqttClientPayloadBuilder()..addString(message);
    _client!.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
    _log('Publicado no tópico [$topic]: "$message"');
  }

  void _publishJsonCommand(String topic, Map<String, dynamic> jsonData) {
    final String jsonString = json.encode(jsonData);
    _publishCommand(topic, jsonString);
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FlutterAppState>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Color(0xFF010B14),
        body: SafeArea(
          top: true,
          child: Stack(
            children: [
              Stack(
                children: [
                  Align(
                    alignment: AlignmentDirectional(0.0, 0.0),
                    child: Container(
                      width: 402.0,
                      height: 906.0,
                      child: Stack(
                        children: [
                          Align(
                            alignment: AlignmentDirectional(0.0, -1.0),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 18.0, 0.0, 0.0),
                              child: Text(AppLocalizations.of(context)!.ajusteVel,
                                style: FlutterTheme.of(context)
                                    .titleMedium
                                    .override(
                                      fontFamily: 'Inter Tight',
                                      color: Colors.white,
                                      fontSize: 25.0,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: AlignmentDirectional(-1.0, -1.0),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  20.0, 345.0, 0.0, 10.0),
                              child: Text(AppLocalizations.of(context)!.janela,
                                style: FlutterTheme.of(context)
                                    .titleLarge
                                    .override(
                                      fontFamily: 'Inter Tight',
                                      color: Color(0xFFFFF8F8),
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: AlignmentDirectional(-1.0, -1.0),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  20.0, 215.0, 0.0, 10.0),
                              child: Text(AppLocalizations.of(context)!.toldoRecolher,
                                style: FlutterTheme.of(context)
                                    .titleLarge
                                    .override(
                                      fontFamily: 'Inter Tight',
                                      color: Color(0xFFFFF8F8),
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: AlignmentDirectional(-1.0, -1.0),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  20.0, 85.0, 0.0, 10.0),
                              child: Text(AppLocalizations.of(context)!.toldoAbrir,
                                style: FlutterTheme.of(context)
                                    .titleLarge
                                    .override(
                                      fontFamily: 'Inter Tight',
                                      color: Color(0xFFFFF8F8),
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: AlignmentDirectional(1.0, -1.0),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 140.0, 50.0, 0.0),
                              child: Container(
                                width: 100.0,
                                child: TextFormField(
                                  controller: _model.textFieldATTextController,
                                  focusNode: _model.textFieldATFocusNode,
                                  onChanged: (text) => EasyDebounce.debounce(
                                    '_model.textFieldATTextController',
                                    Duration(milliseconds: 2000),
                                    () async {
                                      FlutterAppState().velAtras = int.parse(text);
                                      FlutterAppState().update(() {});
                                      _publishJsonCommand(_topicToldoVelocidadeSet, {
                                        "vaf": FlutterAppState().velAfrente,
                                        "vbf": FlutterAppState().velBfrente,
                                        "vat": FlutterAppState().velAtras,
                                        "vbt": FlutterAppState().velBtras,
                                      });
                                    },
                                  ),
                                  autofocus: false,
                                  textInputAction: TextInputAction.done,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    labelText: AppLocalizations.of(context)!.velATras,
                                    labelStyle: FlutterTheme.of(context)
                                        .labelMedium
                                        .override(
                                          fontFamily: 'Inter',
                                          letterSpacing: 0.0,
                                        ),
                                    hintText: '210',
                                    hintStyle: FlutterTheme.of(context)
                                        .labelMedium
                                        .override(
                                          fontFamily: 'Inter',
                                          letterSpacing: 0.0,
                                        ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0x00000000),
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0x00000000),
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            FlutterTheme.of(context).error,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            FlutterTheme.of(context).error,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    filled: true,
                                    fillColor: FlutterTheme.of(context)
                                        .secondaryBackground,
                                  ),
                                  style: FlutterTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Inter',
                                        letterSpacing: 0.0,
                                      ),
                                  keyboardType: TextInputType.number,
                                  cursorColor:
                                      FlutterTheme.of(context).primaryText,
                                  validator: _model
                                      .textFieldATTextControllerValidator
                                      .asValidator(context),
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: AlignmentDirectional(-1.0, -1.0),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  50.0, 270.0, 0.0, 0.0),
                              child: Container(
                                width: 100.0,
                                child: TextFormField(
                                  controller: _model.textFieldBFTextController,
                                  focusNode: _model.textFieldBFFocusNode,
                                  onChanged: (text) => EasyDebounce.debounce(
                                    '_model.textFieldBFTextController',
                                    Duration(milliseconds: 2000),
                                    () async {
                                      FlutterAppState().velBfrente = int.parse(text);
                                      FlutterAppState().update(() {});
                                      _publishJsonCommand(_topicToldoVelocidadeSet, {
                                        "vaf": FlutterAppState().velAfrente,
                                        "vbf": FlutterAppState().velBfrente,
                                        "vat": FlutterAppState().velAtras,
                                        "vbt": FlutterAppState().velBtras,
                                      });
                                    },
                                  ),
                                  autofocus: false,
                                  textInputAction: TextInputAction.done,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    labelText: AppLocalizations.of(context)!.velBFrente,
                                    labelStyle: FlutterTheme.of(context)
                                        .labelMedium
                                        .override(
                                          fontFamily: 'Inter',
                                          letterSpacing: 0.0,
                                        ),
                                    hintText: 'TextField',
                                    hintStyle: FlutterTheme.of(context)
                                        .labelMedium
                                        .override(
                                          fontFamily: 'Inter',
                                          letterSpacing: 0.0,
                                        ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0x00000000),
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0x00000000),
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            FlutterTheme.of(context).error,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            FlutterTheme.of(context).error,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    filled: true,
                                    fillColor: FlutterTheme.of(context)
                                        .secondaryBackground,
                                  ),
                                  style: FlutterTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Inter',
                                        letterSpacing: 0.0,
                                      ),
                                  keyboardType: TextInputType.number,
                                  cursorColor:
                                      FlutterTheme.of(context).primaryText,
                                  validator: _model
                                      .textFieldBFTextControllerValidator
                                      .asValidator(context),
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: AlignmentDirectional(-1.0, -1.0),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  50.0, 400.0, 0.0, 0.0),
                              child: Container(
                                width: 100.0,
                                child: TextFormField(
                                  controller: _model.textController3,
                                  focusNode: _model.textFieldFocusNode1,
                                  onChanged: (text) => EasyDebounce.debounce(
                                    '_model.textController3',
                                    Duration(milliseconds: 2000),
                                    () async {
                                      FlutterAppState().velJanelaAbrir = int.parse(text);
                                      safeSetState(() {});
                                      _publishJsonCommand(_topicJanelaVelocidadeSet, {
                                        "vabrir": FlutterAppState().velJanelaAbrir,
                                        "vfechar": FlutterAppState().velJanelaFechar,
                                      });
                                    },
                                  ),
                                  autofocus: false,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    labelText: AppLocalizations.of(context)!.abrirA,
                                    labelStyle: FlutterTheme.of(context)
                                        .labelMedium
                                        .override(
                                          fontFamily: 'Inter',
                                          letterSpacing: 0.0,
                                        ),
                                    hintText: 'TextField',
                                    hintStyle: FlutterTheme.of(context)
                                        .labelMedium
                                        .override(
                                          fontFamily: 'Inter',
                                          letterSpacing: 0.0,
                                        ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0x00000000),
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0x00000000),
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            FlutterTheme.of(context).error,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            FlutterTheme.of(context).error,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    filled: true,
                                    fillColor: FlutterTheme.of(context)
                                        .secondaryBackground,
                                  ),
                                  style: FlutterTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Inter',
                                        letterSpacing: 0.0,
                                      ),
                                  keyboardType: TextInputType.number,
                                  cursorColor:
                                      FlutterTheme.of(context).primaryText,
                                  validator: _model.textController3Validator
                                      .asValidator(context),
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: AlignmentDirectional(-1.0, -1.0),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  50.0, 140.0, 0.0, 10.0),
                              child: Container(
                                width: 100.0,
                                child: TextFormField(
                                  controller: _model.textFieldAFTextController,
                                  focusNode: _model.textFieldAFFocusNode,
                                  onChanged: (text) => EasyDebounce.debounce(
                                    '_model.textFieldAFTextController',
                                    Duration(milliseconds: 2000),
                                    () async {
                                      FlutterAppState().velAfrente = int.parse(text);
                                      FlutterAppState().update(() {});
                                      _publishJsonCommand(_topicToldoVelocidadeSet, {
                                        "vaf": FlutterAppState().velAfrente,
                                        "vbf": FlutterAppState().velBfrente,
                                        "vat": FlutterAppState().velAtras,
                                        "vbt": FlutterAppState().velBtras,
                                      });
                                    },
                                  ),
                                  autofocus: false,
                                  textInputAction: TextInputAction.done,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    labelText: AppLocalizations.of(context)!.velAFrente,
                                    labelStyle: FlutterTheme.of(context)
                                        .labelMedium
                                        .override(
                                          fontFamily: 'Inter',
                                          letterSpacing: 0.0,
                                        ),
                                    hintText: 'TextField',
                                    hintStyle: FlutterTheme.of(context)
                                        .labelMedium
                                        .override(
                                          fontFamily: 'Inter',
                                          letterSpacing: 0.0,
                                        ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0x00000000),
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0x00000000),
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            FlutterTheme.of(context).error,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            FlutterTheme.of(context).error,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    filled: true,
                                    fillColor: Color(0xFF14181B),
                                  ),
                                  style: FlutterTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Inter',
                                        color: Colors.white,
                                        letterSpacing: 0.0,
                                      ),
                                  keyboardType: TextInputType.number,
                                  cursorColor:
                                      FlutterTheme.of(context).primaryText,
                                  validator: _model
                                      .textFieldAFTextControllerValidator
                                      .asValidator(context),
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: AlignmentDirectional(1.0, -1.0),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 270.0, 50.0, 0.0),
                              child: Container(
                                width: 100.0,
                                child: TextFormField(
                                  controller: _model.textFieldBTTextController,
                                  focusNode: _model.textFieldBTFocusNode,
                                  onChanged: (text) => EasyDebounce.debounce(
                                    '_model.textFieldBTTextController',
                                    Duration(milliseconds: 2000),
                                    () async {
                                      FlutterAppState().velBtras = int.parse(text);
                                      FlutterAppState().update(() {});
                                      _publishJsonCommand(_topicToldoVelocidadeSet, {
                                        "vaf": FlutterAppState().velAfrente,
                                        "vbf": FlutterAppState().velBfrente,
                                        "vat": FlutterAppState().velAtras,
                                        "vbt": FlutterAppState().velBtras,
                                      });
                                    },
                                  ),
                                  autofocus: false,
                                  textInputAction: TextInputAction.done,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    labelText: AppLocalizations.of(context)!.velBTras,
                                    labelStyle: FlutterTheme.of(context)
                                        .labelMedium
                                        .override(
                                          fontFamily: 'Inter',
                                          letterSpacing: 0.0,
                                        ),
                                    hintStyle: FlutterTheme.of(context)
                                        .labelMedium
                                        .override(
                                          fontFamily: 'Inter',
                                          letterSpacing: 0.0,
                                        ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0x00000000),
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0x00000000),
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            FlutterTheme.of(context).error,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            FlutterTheme.of(context).error,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    filled: true,
                                    fillColor: FlutterTheme.of(context)
                                        .secondaryBackground,
                                  ),
                                  style: FlutterTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Inter',
                                        letterSpacing: 0.0,
                                      ),
                                  keyboardType: TextInputType.number,
                                  cursorColor:
                                      FlutterTheme.of(context).primaryText,
                                  validator: _model
                                      .textFieldBTTextControllerValidator
                                      .asValidator(context),
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: AlignmentDirectional(1.0, -1.0),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 400.0, 50.0, 0.0),
                              child: Container(
                                width: 100.0,
                                child: TextFormField(
                                  controller: _model.textController6,
                                  focusNode: _model.textFieldFocusNode2,
                                  onChanged: (text) => EasyDebounce.debounce(
                                    '_model.textController6',
                                    Duration(milliseconds: 2000),
                                    () async {
                                      FlutterAppState().velJanelaFechar = int.parse(text);
                                      safeSetState(() {});
                                      _publishJsonCommand(_topicJanelaVelocidadeSet, {
                                        "vabrir": FlutterAppState().velJanelaAbrir,
                                        "vfechar": FlutterAppState().velJanelaFechar,
                                      });
                                    },
                                  ),
                                  autofocus: false,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    labelText: AppLocalizations.of(context)!.fecharA,
                                    labelStyle: FlutterTheme.of(context)
                                        .labelMedium
                                        .override(
                                          fontFamily: 'Inter',
                                          letterSpacing: 0.0,
                                        ),
                                    hintText: 'TextField',
                                    hintStyle: FlutterTheme.of(context)
                                        .labelMedium
                                        .override(
                                          fontFamily: 'Inter',
                                          letterSpacing: 0.0,
                                        ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0x00000000),
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0x00000000),
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            FlutterTheme.of(context).error,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            FlutterTheme.of(context).error,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    filled: true,
                                    fillColor: FlutterTheme.of(context)
                                        .secondaryBackground,
                                  ),
                                  style: FlutterTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Inter',
                                        letterSpacing: 0.0,
                                      ),
                                  keyboardType: TextInputType.number,
                                  cursorColor:
                                      FlutterTheme.of(context).primaryText,
                                  validator: _model.textController6Validator
                                      .asValidator(context),
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: AlignmentDirectional(0.0, -1.0),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  120.0, 560.0, 120.0, 10.0),
                              child: FlutterButtonWidget(
                                onPressed: () async {
                                  _publishCommand(_topicToldoVelocidadeReset, "RESET");
                                  _publishCommand(_topicJanelaVelocidadeReset, "RESET");

                                  FlutterAppState().velAfrente = 87;
                                  FlutterAppState().velBfrente = 200;
                                  FlutterAppState().velAtras = 210;
                                  FlutterAppState().velBtras = 90;
                                  FlutterAppState().velJanelaAbrir = 100;
                                  FlutterAppState().velJanelaFechar = 100;
                                  FlutterAppState().update(() {});
                                  
                                  _model.textFieldATTextController?.text = FlutterAppState().velAtras.toString();
                                  _model.textFieldBFTextController?.text = FlutterAppState().velBfrente.toString();
                                  _model.textController3?.text = FlutterAppState().velJanelaAbrir.toString();
                                  _model.textFieldAFTextController?.text = FlutterAppState().velAfrente.toString();
                                  _model.textFieldBTTextController?.text = FlutterAppState().velBtras.toString();
                                  _model.textController6?.text = FlutterAppState().velJanelaFechar.toString();

                                  safeSetState(() {}); 
                                },
                                text: AppLocalizations.of(context)!.resetarVelocidades,
                                icon: Icon(
                                  Icons.replay,
                                  size: 15.0,
                                ),
                                options: FlutterButtonOptions(
                                  width: 170.0,
                                  height: 65.0,
                                  padding: EdgeInsets.all(8.0),
                                  iconPadding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 0.0),
                                  color: FlutterTheme.of(context).primary,
                                  textStyle: FlutterTheme.of(context)
                                      .titleSmall
                                      .override(
                                        fontFamily: 'Inter Tight',
                                        color:
                                            FlutterTheme.of(context).info,
                                        letterSpacing: 0.0,
                                      ),
                                  elevation: 2.0,
                                  borderSide: BorderSide(
                                    color: Colors.transparent,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: AlignmentDirectional(0.0, -1.0),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  120.0, 480.0, 120.0, 10.0),
                              child: FlutterButtonWidget(
                                onPressed: () async {
                                  _publishJsonCommand(_topicToldoVelocidadeSet, {
                                    "vaf": FlutterAppState().velAfrente,
                                    "vbf": FlutterAppState().velBfrente,
                                    "vat": FlutterAppState().velAtras,
                                    "vbt": FlutterAppState().velBtras,
                                  });

                                  _publishJsonCommand(_topicJanelaVelocidadeSet, {
                                    "vabrir": FlutterAppState().velJanelaAbrir,
                                    "vfechar": FlutterAppState().velJanelaFechar,
                                  });

                                  safeSetState(() {});
                                },
                                text: AppLocalizations.of(context)!.definirVelocidades,
                                icon: Icon(
                                  Icons.done,
                                  size: 15.0,
                                ),
                                options: FlutterButtonOptions(
                                  width: 165.0,
                                  height: 65.0,
                                  padding: EdgeInsets.all(8.0),
                                  iconPadding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 0.0),
                                  color: FlutterTheme.of(context).primary,
                                  textStyle: FlutterTheme.of(context)
                                      .titleSmall
                                      .override(
                                        fontFamily: 'Inter Tight',
                                        color:
                                            FlutterTheme.of(context).info,
                                        letterSpacing: 0.0,
                                      ),
                                  elevation: 2.0,
                                  borderSide: BorderSide(
                                    color: Colors.transparent,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}