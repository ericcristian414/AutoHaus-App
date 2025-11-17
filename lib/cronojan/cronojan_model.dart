import '../flutter/util.dart';
import '../flutter/form_field_controller.dart';
import 'cronojan_widget.dart' show CronojanWidget;
import 'package:flutter/material.dart';

class CronojanModel extends FlutterModel<CronojanWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for Switch widget.
  bool? switchValue;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode1;
  TextEditingController? textController1;
  String? Function(BuildContext, String?)? textController1Validator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode2;
  TextEditingController? textController2;
  String? Function(BuildContext, String?)? textController2Validator;
  // State field(s) for DropDown widget.
  String? dropDownValue;
  FormFieldController<String>? dropDownValueController;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode1?.dispose();
    textController1?.dispose();

    textFieldFocusNode2?.dispose();
    textController2?.dispose();
  }
}
