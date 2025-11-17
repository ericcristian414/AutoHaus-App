import '/backend/api_requests/api_calls.dart';
import '../flutter/util.dart';
import 'velocidades_widget.dart' show VelocidadesWidget;
import 'package:flutter/material.dart';


class VelocidadesModel extends FlutterModel<VelocidadesWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for TextFieldAT widget.
  FocusNode? textFieldATFocusNode;
  TextEditingController? textFieldATTextController;
  String? Function(BuildContext, String?)? textFieldATTextControllerValidator;
  // State field(s) for TextFieldBF widget.
  FocusNode? textFieldBFFocusNode;
  TextEditingController? textFieldBFTextController;
  String? Function(BuildContext, String?)? textFieldBFTextControllerValidator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode1;
  TextEditingController? textController3;
  String? Function(BuildContext, String?)? textController3Validator;
  // State field(s) for TextFieldAF widget.
  FocusNode? textFieldAFFocusNode;
  TextEditingController? textFieldAFTextController;
  String? Function(BuildContext, String?)? textFieldAFTextControllerValidator;
  // State field(s) for TextFieldBT widget.
  FocusNode? textFieldBTFocusNode;
  TextEditingController? textFieldBTTextController;
  String? Function(BuildContext, String?)? textFieldBTTextControllerValidator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode2;
  TextEditingController? textController6;
  String? Function(BuildContext, String?)? textController6Validator;
  // Stores action output result for [Backend Call - API (Velocidade Toldo)] action in Button widget.
  ApiCallResponse? apiResult1ct;
  // Stores action output result for [Backend Call - API (Velocidade Toldo)] action in Button widget.
  ApiCallResponse? apiResult2u2;
  // Stores action output result for [Backend Call - API (Velocidade Janela)] action in Button widget.
  ApiCallResponse? apiResultrsh;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldATFocusNode?.dispose();
    textFieldATTextController?.dispose();

    textFieldBFFocusNode?.dispose();
    textFieldBFTextController?.dispose();

    textFieldFocusNode1?.dispose();
    textController3?.dispose();

    textFieldAFFocusNode?.dispose();
    textFieldAFTextController?.dispose();

    textFieldBTFocusNode?.dispose();
    textFieldBTTextController?.dispose();

    textFieldFocusNode2?.dispose();
    textController6?.dispose();
  }
}
