import '/backend/api_requests/api_calls.dart';
import '../flutter/util.dart';
import '../flutter/instant_timer.dart';
import '/index.dart';
import 'dart:async';
import 'toldo_widget.dart' show ToldoWidget;
import 'package:flutter/material.dart';

class ToldoModel extends FlutterModel<ToldoWidget> {
  ///  State fields for stateful widgets in this page.

  InstantTimer? instantTimer;
  Completer<ApiCallResponse>? apiRequestCompleter;
  // Stores action output result for [Backend Call - API (Motor frente)] action in Button widget.
  ApiCallResponse? apiResultrq7;
  // Stores action output result for [Backend Call - API (Motor Tras)] action in Button widget.
  ApiCallResponse? apiResultqqd;
  // State field(s) for container widget.
  bool? switchValue1;
  // State field(s) for Slider1 widget.
  double? slider1Value;
  // Stores action output result for [Backend Call - API (SliderToldo)] action in Slider1 widget.
  ApiCallResponse? apiResultjjf;
  // State field(s) for Switch widget.
  bool? switchValue2;
  // Stores action output result for [Backend Call - API (ToldoChuvaOn)] action in Switch widget.
  ApiCallResponse? apiResultwoe;
  // Stores action output result for [Backend Call - API (ToldoChuvaOff)] action in Switch widget.
  ApiCallResponse? apiResult1x3;

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
