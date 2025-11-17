import '../flutter/util.dart';
import 'objetos_widget.dart' show ObjetosWidget;
import 'package:flutter/material.dart';

class ObjetosModel extends FlutterModel<ObjetosWidget> {
  FocusNode? searchBarFocusNode;
  TextEditingController? searchBarTextController;
  String? Function(BuildContext, String?)? searchBarTextControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    searchBarFocusNode?.dispose();
    searchBarTextController?.dispose();
  }
}


