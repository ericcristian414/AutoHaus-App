import '/backend/api_requests/api_calls.dart';
import '../flutter/util.dart';
import '/index.dart';
import 'desenvolvedor_widget.dart' show DesenvolvedorWidget;
import 'package:flutter/material.dart';

class DesenvolvedorModel extends FlutterModel<DesenvolvedorWidget> {
  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (Motor A Tras)] action in Button widget.
  ApiCallResponse? apiResultt1a;
  // Stores action output result for [Backend Call - API (Motor B Tras)] action in Button widget.
  ApiCallResponse? apiResult784;
  // Stores action output result for [Backend Call - API (motor A frente)] action in Button widget.
  ApiCallResponse? apiResultybx;
  // Stores action output result for [Backend Call - API (Tras Janela)] action in Button widget.
  ApiCallResponse? apiResultmdo;
  // Stores action output result for [Backend Call - API (Frente Janela)] action in Button widget.
  ApiCallResponse? apiResultu0l;
  // Stores action output result for [Backend Call - API (Parar motores)] action in Pararmotores widget.
  ApiCallResponse? apiResultoi8;
  // Stores action output result for [Backend Call - API (Motor B Frente)] action in Button widget.
  ApiCallResponse? apiResult5fl;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
