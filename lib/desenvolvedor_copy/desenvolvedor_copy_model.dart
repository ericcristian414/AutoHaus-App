import '../flutter/util.dart';
import '../flutter/form_field_controller.dart';
import 'desenvolvedor_copy_widget.dart' show DesenvolvedorCopyWidget;
import 'package:flutter/material.dart';

class DesenvolvedorCopyModel extends FlutterModel<DesenvolvedorCopyWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for DropDown widget.
  String? dropDownValue;
  FormFieldController<String>? dropDownValueController;
  // State field(s) for TextField1 widget.
  FocusNode? textField1FocusNode;
  TextEditingController? textField1TextController;
  String? Function(BuildContext, String?)? textField1TextControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textField1FocusNode?.dispose();
    textField1TextController?.dispose();
  }
}
