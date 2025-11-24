import '/backend/api_requests/api_calls.dart';
import '../flutter/util.dart';
import '../flutter/instant_timer.dart';
import '/index.dart';
import 'dart:async';
import 'janela_widget.dart' show JanelaWidget;
import 'package:flutter/material.dart';


class JanelaModel extends FlutterModel<JanelaWidget> {
  ///  State fields for stateful widgets in this page.

  InstantTimer? instantTimer;
  Completer<ApiCallResponse>? apiRequestCompleter;
  // Stores action output result for [Backend Call - API (Abrir Janela)] action in Button widget.
  ApiCallResponse? apiResulte0e;
  // Stores action output result for [Backend Call - API (Fechar Janela)] action in Button widget.
  ApiCallResponse? apiResult4tx;
  // State field(s) for Switch widget.
  bool? switchValue1;

  bool? switchValeu2;

  bool? switchValue3;

  bool? switchValue4;


  // State field(s) for Slider12 widget.
  double? slider1Value;

  double? slider2Value;
  // Stores action output result for [Backend Call - API (Slider Janela)] action in Slider12 widget.
  ApiCallResponse? apiResultjjf;
  // State field(s) for Switch widget.
  bool? switchValue2;
  // Stores action output result for [Backend Call - API (JanelaChuvaOn)] action in Switch widget.
  ApiCallResponse? apiResultok3;
  // Stores action output result for [Backend Call - API (JanelaChuvaOff)] action in Switch widget.
  ApiCallResponse? apiResultz99;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    instantTimer?.cancel();
  }

  /// Additional helper methods.
  Future waitForApiRequestCompleted({
    double minWait = 0,
    double maxWait = double.infinity,
  }) async {
    final stopwatch = Stopwatch()..start();
    while (true) {
      await Future.delayed(Duration(milliseconds: 50));
      final timeElapsed = stopwatch.elapsedMilliseconds;
      final requestComplete = apiRequestCompleter?.isCompleted ?? false;
      if (timeElapsed > maxWait || (requestComplete && timeElapsed > minWait)) {
        break;
      }
    }
  }
}
