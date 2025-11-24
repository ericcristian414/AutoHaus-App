import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:provider/provider.dart';

import 'package:auto_haus/flutter/theme.dart';
import '/flutter/util.dart';
import '/flutter/widgets.dart';
import 'package:auto_haus/l10n/app_localizations.dart';

import 'janela_model.dart';
export 'janela_model.dart';

class JanelaWidget extends StatefulWidget {
  const JanelaWidget({super.key});

  static String routeName = 'Janela';
  static String routePath = '/janela';

  @override
  State<JanelaWidget> createState() => _JanelaWidgetState();
}

class _JanelaWidgetState extends State<JanelaWidget> {
  late JanelaModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  int _pageIndex = 0;
  final int _totalWindows = 2; 
  late PageController _pageController;


  MqttServerClient? _client;
  StreamSubscription? _updatesSubscription;

  double _posicaoJanela = 0.0;
  double _posicaoJanelaReal = 0.0;
  String _statusChuva = 'SECO';
  bool _automacaoChuva = false;
  bool _automacaoChuvaReal = false;

  final String _topicBase = "casa/erick/toldo_janela";
  late final String _topicJanelaCmd;
  late final String _topicJanelaRealCmd;
  late final String _topicJanelaRealEstado;
  late final String _topicJanelaEstado;
  late final String _topicSensorEstado;
  late final String _topicSensorConfig;
  late final String _topicJanelaRealConfig;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => JanelaModel());

    _topicJanelaCmd = '$_topicBase/janela/cmd';
    _topicJanelaRealCmd = '$_topicBase/janelaReal/cmd';
    _topicJanelaRealEstado = '$_topicBase/janelaReal/estado';
    _topicJanelaRealConfig = '$_topicBase/janelaReal/sensor/config';
    _topicJanelaEstado = '$_topicBase/janela/estado';
    _topicSensorEstado = '$_topicBase/sensor/estado';
    _topicSensorConfig = '$_topicBase/sensor/config';

    _model.switchValue1 = FlutterAppState().sliderjanela;
    _model.switchValue2 = FlutterAppState().sliderChuvaJanela;
    _model.switchValue3 = false; 
    _model.switchValue4 = false; 
    _model.slider1Value = 0.0;   
    _model.slider2Value = 0.0;

    _pageController = PageController(initialPage: _pageIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _connect();
    });
  }

  @override
  void dispose() {
    _updatesSubscription?.cancel();
    _client?.disconnect();
    _pageController.dispose();
    _model.dispose();
    super.dispose();
  }

  void _log(String message) {
    debugPrint('[MQTT Janela] $message');
  }

  Future<void> _connect() async {
    if (_client?.connectionStatus?.state == MqttConnectionState.connected || _client?.connectionStatus?.state == MqttConnectionState.connecting) return;

    final String url = 'e637335d485a428f98d9fb45c66b6923.s1.eu.hivemq.cloud';
    final int port = 8883;
    final String username = 'Erickkk';
    final String password = '96488941Ab';
    final String clientId = 'flutter_janela_ui_${DateTime.now().millisecondsSinceEpoch}';

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

    _client!.subscribe(_topicJanelaEstado, MqttQos.atLeastOnce);
    _client!.subscribe(_topicJanelaRealEstado, MqttQos.atLeastOnce);
    _client!.subscribe(_topicSensorEstado, MqttQos.atLeastOnce);


    // CORRIGIR: Remover o setState duplicado e organizar a lógica
_updatesSubscription = _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
  final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
  final String payload = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
  final String topic = c[0].topic;

  _log('Mensagem recebida no tópico [$topic]: "$payload"');

  try {
    final Map<String, dynamic> jsonPayload = json.decode(payload);
    if (!mounted) return;

    setState(() {
      if (topic == _topicJanelaEstado && jsonPayload.containsKey('posicao')) {
        _posicaoJanela = (jsonPayload['posicao'] as num).toDouble();
        _model.slider1Value = _posicaoJanela;
      } else if (topic == _topicJanelaRealEstado && jsonPayload.containsKey('posicao')) {
        _posicaoJanelaReal = (jsonPayload['posicao'] as num).toDouble();
        _model.slider2Value = _posicaoJanelaReal;
      } else if (topic == _topicSensorEstado) {
        if (jsonPayload.containsKey('chuva')) {
          _statusChuva = jsonPayload['chuva'] as String;
        }
        if (jsonPayload.containsKey('autoMovJanela')) {
          _automacaoChuva = jsonPayload['autoMovJanela'] as bool;
          _model.switchValue2 = _automacaoChuva;
        }
        if (jsonPayload.containsKey('movJanelaRealAuto')) {
          _automacaoChuvaReal = jsonPayload['movJanelaRealAuto'] as bool;
          _model.switchValue4 = _automacaoChuvaReal;
        }
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
                  PageView(
                    controller: _pageController,
                    onPageChanged: (i) => setState(() => _pageIndex = i),
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(24.0, 40.0, 24.0, 0.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 309.0,
                                    height: 460.8,
                                    decoration: BoxDecoration(
                                      color: Color(0xFF14181B),
                                      borderRadius: BorderRadius.circular(18.0),
                                    ),
                                    child: Stack(
                                      children: [
                                        Align(
                                          alignment: AlignmentDirectional(0.0, -1.0),
                                          child: Padding(
                                            padding: EdgeInsetsDirectional.fromSTEB(50.0, 35.0, 50.0, 0.0),
                                            child: FlutterButtonWidget(
                                              onPressed: () => _publishCommand(_topicJanelaCmd, "FECHAR"),
                                              text: AppLocalizations.of(context)!.abrir,
                                              icon: Icon(Icons.arrow_upward, color: FlutterTheme.of(context).info, size: 24.0),
                                              options: FlutterButtonOptions(
                                                width: 140.0,
                                                height: 60.0,
                                                color: FlutterTheme.of(context).primary,
                                                textStyle: FlutterTheme.of(context).titleSmall.override(
                                                      fontFamily: 'Inter Tight',
                                                      color: FlutterTheme.of(context).info,
                                                    ),
                                                borderRadius: BorderRadius.circular(8.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Align(
                                          alignment: AlignmentDirectional(0.0, 0.0),
                                          child: Padding(
                                            padding: EdgeInsetsDirectional.fromSTEB(50.0, 10.0, 50.0, 190.0),
                                            child: FlutterButtonWidget(
                                              onPressed: () => _publishCommand(_topicJanelaCmd, "ABRIR"),
                                              text: AppLocalizations.of(context)!.fechar,
                                              icon: Icon(Icons.arrow_downward_sharp, color: FlutterTheme.of(context).info, size: 24.0),
                                              options: FlutterButtonOptions(
                                                width: 140.0,
                                                height: 60.0,
                                                color: Color(0xFF272C32),
                                                textStyle: FlutterTheme.of(context).titleSmall.override(
                                                      fontFamily: 'Inter Tight',
                                                      color: FlutterTheme.of(context).info,
                                                    ),
                                                borderRadius: BorderRadius.circular(8.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsetsDirectional.fromSTEB(16.5, 205.0, 16.5, 0.0),
                                          child: Container(
                                            width: 302.0,
                                            height: 120.0,
                                            decoration: BoxDecoration(
                                              color: Color(0xFF1D2428),
                                              borderRadius: BorderRadius.circular(14.0),
                                            ),
                                            child: Stack(
                                              children: [
                                                Align(
                                                  alignment: AlignmentDirectional(-1.0, -1.0),
                                                  child: Padding(
                                                    padding: EdgeInsetsDirectional.fromSTEB(154.0, 25.0, 0.0, 0.0),
                                                    child: Text(
                                                      '${_posicaoJanela.round()}%',
                                                      style: FlutterTheme.of(context).titleMedium.override(
                                                            fontFamily: 'Inter Tight',
                                                            fontSize: 17,
                                                            color: Colors.white,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                                Align(
                                                  alignment: AlignmentDirectional(1.0, -1.0),
                                                  child: Padding(
                                                    padding: EdgeInsetsDirectional.fromSTEB(200.0, 13.0, 20.0, 0.0),
                                                    child: Switch(
                                                      value: _model.switchValue1!,
                                                      onChanged: (newValue) => setState(() => _model.switchValue1 = newValue),
                                                      activeColor: FlutterTheme.of(context).primaryText,
                                                      activeTrackColor: FlutterTheme.of(context).primary,
                                                      inactiveTrackColor: Color(0xFF98999A),
                                                      inactiveThumbColor: FlutterTheme.of(context).primaryText,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 50.0, 0.0, 0.0),
                                                  child: Slider(
                                                    activeColor: Color(0xFF4B39EF),
                                                    inactiveColor: Colors.white,
                                                    min: 0.0,
                                                    max: 100.0,
                                                    value: _model.slider1Value ?? _posicaoJanela,
                                                    divisions: 10,
                                                    onChanged: !_model.switchValue1!
                                                        ? null
                                                        : (newValue) => setState(() => _model.slider1Value = newValue),
                                                    onChangeEnd: (newValue) {
                                                      if (!_model.switchValue1!) return;
                                                      final pos = newValue.round();
                                                      _publishCommand(_topicJanelaCmd, 'POS:$pos');
                                                    },
                                                  ),
                                                ),
                                                Align(
                                                  alignment: AlignmentDirectional(-1.0, -1.0),
                                                  child: Padding(
                                                    padding: EdgeInsetsDirectional.fromSTEB(20.0, 25.0, 0.0, 0.0),
                                                    child: Text(
                                                      '${AppLocalizations.of(context)!.controleManual}: ',
                                                      style: FlutterTheme.of(context).titleMedium.override(
                                                            fontFamily: 'Inter Tight',
                                                            fontSize: 17,
                                                            color: Colors.white,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsetsDirectional.fromSTEB(16.5, 350.0, 16.5, 34.0),
                                          child: Container(
                                            width: 302.0,
                                            height: 78.0,
                                            decoration: BoxDecoration(
                                              color: Color(0xFF1D2428),
                                              borderRadius: BorderRadius.circular(14.0),
                                            ),
                                            child: Align(
                                              alignment: AlignmentDirectional(-1.0, 0.0),
                                              child: Padding(
                                                padding: EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 18.0),
                                                child: RichText(
                                                  textAlign: TextAlign.left,
                                                  text: TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: '${AppLocalizations.of(context)!.detecaoChuva} ',
                                                        style: FlutterTheme.of(context).titleMedium.override(
                                                              fontFamily: 'Inter Tight',
                                                              color: Colors.white,
                                                              fontSize: 17.0,
                                                            ),
                                                      ),
                                                      TextSpan(
                                                        text: _statusChuva == 'SECO'
                                                            ? AppLocalizations.of(context)!.limpo
                                                            : AppLocalizations.of(context)!.umido,
                                                        style: FlutterTheme.of(context).bodyMedium.override(
                                                              fontFamily: 'Inter',
                                                              color: _statusChuva == 'SECO'
                                                                  ? Color(0xE639D258) 
                                                                  : Color(0xE6E12428), 
                                                              fontSize: 17.0,
                                                              fontWeight: FontWeight.w600,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(24.0, 16.0, 24.0, 24.0),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Color(0xFF1D2428),
                                borderRadius: BorderRadius.circular(14.0),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!.modoAutomatico,
                                          style: FlutterTheme.of(context).titleMedium.override(
                                                fontFamily: 'Inter Tight',
                                                color: Colors.white,
                                              ),
                                        ),
                                        Text(
                                          AppLocalizations.of(context)!.controleClima,
                                          style: FlutterTheme.of(context).bodySmall.override(
                                                fontFamily: 'Inter',
                                                color: Color(0xFF95A1AC),
                                              ),
                                        ),
                                      ],
                                    ),
                                    Switch(
                                      value: _model.switchValue2!,
                                      onChanged: (newValue) {
                                        setState(() => _model.switchValue2 = newValue);
                                        _publishJsonCommand(_topicSensorConfig, {"movJanelaAuto": newValue});
                                      },
                                      activeColor: FlutterTheme.of(context).info,
                                      activeTrackColor: FlutterTheme.of(context).primary,
                                      inactiveTrackColor: Color(0xFF98999A),
                                      inactiveThumbColor: FlutterTheme.of(context).primaryText,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(24.0, 40.0, 24.0, 0.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 309.0,
                                    height: 460.8,
                                    decoration: BoxDecoration(
                                      color: Color(0xFF14181B),
                                      borderRadius: BorderRadius.circular(18.0),
                                    ),
                                    child: Stack(
                                      children: [
                                        Align(
                                          alignment: AlignmentDirectional(0.0, -1.0),
                                          child: Padding(
                                            padding: EdgeInsetsDirectional.fromSTEB(50.0, 35.0, 50.0, 0.0),
                                            child: FlutterButtonWidget(
                                              onPressed: () => _publishCommand(_topicJanelaRealCmd, "FECHAR"),
                                              text: AppLocalizations.of(context)!.abrir,
                                              icon: Icon(Icons.arrow_upward, color: FlutterTheme.of(context).info, size: 24.0),
                                              options: FlutterButtonOptions(
                                                width: 140.0,
                                                height: 60.0,
                                                color: FlutterTheme.of(context).primary,
                                                textStyle: FlutterTheme.of(context).titleSmall.override(
                                                      fontFamily: 'Inter Tight',
                                                      color: FlutterTheme.of(context).info,
                                                    ),
                                                borderRadius: BorderRadius.circular(8.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Align(
                                          alignment: AlignmentDirectional(0.0, 0.0),
                                          child: Padding(
                                            padding: EdgeInsetsDirectional.fromSTEB(50.0, 10.0, 50.0, 190.0),
                                            child: FlutterButtonWidget(
                                              onPressed: () => _publishCommand(_topicJanelaRealCmd, "ABRIR"),
                                              text: AppLocalizations.of(context)!.fechar,
                                              icon: Icon(Icons.arrow_downward_sharp, color: FlutterTheme.of(context).info, size: 24.0),
                                              options: FlutterButtonOptions(
                                                width: 140.0,
                                                height: 60.0,
                                                color: Color(0xFF272C32),
                                                textStyle: FlutterTheme.of(context).titleSmall.override(
                                                      fontFamily: 'Inter Tight',
                                                      color: FlutterTheme.of(context).info,
                                                    ),
                                                borderRadius: BorderRadius.circular(8.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsetsDirectional.fromSTEB(16.5, 205.0, 16.5, 0.0),
                                          child: Container(
                                            width: 302.0,
                                            height: 120.0,
                                            decoration: BoxDecoration(
                                              color: Color(0xFF1D2428),
                                              borderRadius: BorderRadius.circular(14.0),
                                            ),
                                            child: Stack(
                                              children: [
                                                Align(
                                                  alignment: AlignmentDirectional(-1.0, -1.0),
                                                  child: Padding(
                                                    padding: EdgeInsetsDirectional.fromSTEB(154.0, 25.0, 0.0, 0.0),
                                                    child: Text(
                                                      '${_posicaoJanelaReal.round()}%',
                                                      style: FlutterTheme.of(context).titleMedium.override(
                                                            fontFamily: 'Inter Tight',
                                                            fontSize: 17,
                                                            color: Colors.white,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                                Align(
                                                  alignment: AlignmentDirectional(1.0, -1.0),
                                                  child: Padding(
                                                    padding: EdgeInsetsDirectional.fromSTEB(200.0, 13.0, 20.0, 0.0),
                                                    child: Switch(
                                                      value: _model.switchValue3!,
                                                      onChanged: (newValue) => setState(() => _model.switchValue3 = newValue),
                                                      activeColor: FlutterTheme.of(context).primaryText,
                                                      activeTrackColor: FlutterTheme.of(context).primary,
                                                      inactiveTrackColor: Color(0xFF98999A),
                                                      inactiveThumbColor: FlutterTheme.of(context).primaryText,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 50.0, 0.0, 0.0),
                                                  child: Slider(
                                                    activeColor: Color(0xFF4B39EF),
                                                    inactiveColor: Colors.white,
                                                    min: 0.0,
                                                    max: 100.0,
                                                    value: _model.slider2Value ?? _posicaoJanela,
                                                    divisions: 10,
                                                    onChanged: !_model.switchValue3!
                                                        ? null
                                                        : (newValue) => setState(() => _model.slider2Value = newValue),
                                                    onChangeEnd: (newValue) {
                                                      if (!_model.switchValue3!) return;
                                                      final pos = newValue.round();
                                                      _publishCommand(_topicJanelaRealCmd, 'POS:$pos');
                                                    },
                                                  ),
                                                ),
                                                Align(
                                                  alignment: AlignmentDirectional(-1.0, -1.0),
                                                  child: Padding(
                                                    padding: EdgeInsetsDirectional.fromSTEB(20.0, 25.0, 0.0, 0.0),
                                                    child: Text(
                                                      '${AppLocalizations.of(context)!.controleManual}: ',
                                                      style: FlutterTheme.of(context).titleMedium.override(
                                                            fontFamily: 'Inter Tight',
                                                            fontSize: 17,
                                                            color: Colors.white,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsetsDirectional.fromSTEB(16.5, 350.0, 16.5, 34.0),
                                          child: Container(
                                            width: 302.0,
                                            height: 78.0,
                                            decoration: BoxDecoration(
                                              color: Color(0xFF1D2428),
                                              borderRadius: BorderRadius.circular(14.0),
                                            ),
                                            child: Align(
                                              alignment: AlignmentDirectional(-1.0, 0.0),
                                              child: Padding(
                                                padding: EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 18.0),
                                                child: RichText(
                                                  textAlign: TextAlign.left,
                                                  text: TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: '${AppLocalizations.of(context)!.detecaoChuva} ',
                                                        style: FlutterTheme.of(context).titleMedium.override(
                                                              fontFamily: 'Inter Tight',
                                                              color: Colors.white,
                                                              fontSize: 17.0,
                                                            ),
                                                      ),
                                                      TextSpan(
                                                        text: _statusChuva == 'SECO'
                                                            ? AppLocalizations.of(context)!.limpo
                                                            : AppLocalizations.of(context)!.umido,
                                                        style: FlutterTheme.of(context).bodyMedium.override(
                                                              fontFamily: 'Inter',
                                                              color: _statusChuva == 'SECO'
                                                                  ? Color(0xE639D258) 
                                                                  : Color(0xE6E12428), 
                                                              fontSize: 17.0,
                                                              fontWeight: FontWeight.w600,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(24.0, 16.0, 24.0, 24.0),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Color(0xFF1D2428),
                                borderRadius: BorderRadius.circular(14.0),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!.modoAutomatico,
                                          style: FlutterTheme.of(context).titleMedium.override(
                                                fontFamily: 'Inter Tight',
                                                color: Colors.white,
                                              ),
                                        ),
                                        Text(
                                          AppLocalizations.of(context)!.controleClima,
                                          style: FlutterTheme.of(context).bodySmall.override(
                                                fontFamily: 'Inter',
                                                color: Color(0xFF95A1AC),
                                              ),
                                        ),
                                      ],
                                    ),
                                    Switch(
                                      value: _model.switchValue4!,
                                      onChanged: (newValue) {
                                        setState(() => _model.switchValue4 = newValue);
                                        _publishJsonCommand(_topicJanelaRealConfig, {"movJanelaRealAuto": newValue});
                                      },
                                      activeColor: FlutterTheme.of(context).info,
                                      activeTrackColor: FlutterTheme.of(context).primary,
                                      inactiveTrackColor: Color(0xFF98999A),
                                      inactiveThumbColor: FlutterTheme.of(context).primaryText,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Positioned(
                    left: 6.0,
                    top: 0,
                    bottom: 85,
                    child: Center(
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                        iconSize: 20.0,
                        onPressed: () {
                          final prev = (_pageIndex - 1).clamp(0, _totalWindows - 1);
                          _pageController.animateToPage(prev, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    right: 4.0,
                    top: 0,
                    bottom: 85,
                    child: Center(
                      child: IconButton(
                        icon: Icon(Icons.arrow_forward_ios, color: Colors.white),
                        iconSize: 20.0,
                        onPressed: () {
                          final next = (_pageIndex + 1).clamp(0, _totalWindows - 1);
                          _pageController.animateToPage(next, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
                        },
                      ),
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 18.0, 0.0, 300.0),
                  child: Text(
                    _pageIndex == 0
                        ? AppLocalizations.of(context)!.janela
                        : AppLocalizations.of(context)!.janelaPrototipo,
                    style: FlutterTheme.of(context).bodyMedium.override(
                          fontFamily: 'Inter',
                          color: Colors.white,
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(357.0, 22.0, 20.0, 80.0),
                child: InkWell(
                  onTap: () => context.pushNamed('cronojan'),
                  child: Icon(Icons.more_vert, color: Colors.white, size: 22.0),
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(20.0, 22.0, 300.0, 80.0),
                child: InkWell(
                  onTap: () => context.pop(),
                  child: Icon(Icons.arrow_back, color: Colors.white, size: 26.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
