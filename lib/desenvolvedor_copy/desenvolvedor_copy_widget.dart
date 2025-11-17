import '../flutter/drop_down.dart';
import '../flutter/theme.dart';
import '../flutter/util.dart';
import '../flutter/form_field_controller.dart';
import 'package:flutter/material.dart';
import 'package:auto_haus/main.dart';
import 'package:auto_haus/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'desenvolvedor_copy_model.dart';
export 'desenvolvedor_copy_model.dart';

class DesenvolvedorCopyWidget extends StatefulWidget {
  const DesenvolvedorCopyWidget({super.key});

  static String routeName = 'DesenvolvedorCopy';
  static String routePath = '/desenvolvedorCopy';

  @override
  State<DesenvolvedorCopyWidget> createState() =>
      _DesenvolvedorCopyWidgetState();
}

class _DesenvolvedorCopyWidgetState extends State<DesenvolvedorCopyWidget> {
  late DesenvolvedorCopyModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DesenvolvedorCopyModel());
    
    _model.dropDownValue = FlutterAppState().selectedLanguage;
    _model.dropDownValueController =
    FormFieldController<String>(_model.dropDownValue);

    _model.textField1TextController ??= TextEditingController();
    _model.textField1FocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
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
                  Stack(
                    children: [
                      Stack(
                        children: [
                          Align(
                            alignment: AlignmentDirectional(-1.0, -1.0),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  30.0, 215.0, 0.0, 0.0),
                              child: Text(
                                AppLocalizations.of(context)!.idioma,
                                style: FlutterTheme.of(context)
                                    .titleMedium
                                    .override(
                                      fontFamily: 'Inter Tight',
                                      color: Colors.white,
                                      fontSize: 20.0,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: AlignmentDirectional(0.0, -1.0),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 18.0, 0.0, 0.0),
                              child: Text(
                                AppLocalizations.of(context)!.configuracoes,
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
                                  30.0, 85.0, 0.0, 0.0),
                              child: Text(
                                AppLocalizations.of(context)!.ajustedeIP,
                                style: FlutterTheme.of(context)
                                    .titleMedium
                                    .override(
                                      fontFamily: 'Inter Tight',
                                      color: Colors.white,
                                      fontSize: 20.0,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ),
                          ),
                          Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(19.0, 255.0, 0.0, 0.0),
                                    child: DropDown<String>(
                                      controller: _model.dropDownValueController ??=
                                          FormFieldController<String>(_model.dropDownValue),
                                      options: ['English', 'Português', 'Español'],
                                      onChanged: (val) async {
                                        safeSetState(() => _model.dropDownValue = val);

                                        FlutterAppState().selectedLanguage = val!;
                                        FlutterAppState().update(() {}); 

                                        if (val == 'English') {
                                          MyApp.of(context).setLocale('en');
                                        } else if (val == 'Português') {
                                          MyApp.of(context).setLocale('pt');
                                        } else if (val == 'Español') {
                                          MyApp.of(context).setLocale('es');
                                        }
                                      },
                                      width: 200.0,
                                      height: 45.0,
                                      textStyle: FlutterTheme.of(context).bodyMedium.override(
                                            fontFamily: 'Inter',
                                            fontSize: 15.0,
                                            letterSpacing: 0.0,
                                          ),
                                      hintText: AppLocalizations.of(context)!.selecionar,
                                      icon: Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: FlutterTheme.of(context).secondaryText,
                                        size: 24.0,
                                      ),
                                      fillColor: FlutterTheme.of(context).secondaryBackground,
                                      elevation: 2.0,
                                      borderColor: Colors.transparent,
                                      borderWidth: 1.0,
                                      borderRadius: 8.0,
                                      margin: EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
                                      hidesUnderline: true,
                                      isOverButton: false,
                                      isSearchable: false,
                                      isMultiSelect: false,
                                    ),
                                  ),
                        ],
                      ),
                    ],
                  ),
                  Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(30.0, 125.0, 0.0, 0.0),
                    child: Container(
                      width: 200.0,
                      child: TextFormField(
                        controller: _model.textField1TextController,
                        focusNode: _model.textField1FocusNode,
                        onFieldSubmitted: (_) async {
                          FlutterAppState().esp32ip =
                              _model.textField1TextController.text;
                          FlutterAppState().update(() {});
                        },
                        autofocus: false,
                        textCapitalization: TextCapitalization.none,
                        textInputAction: TextInputAction.done,
                        obscureText: false,
                        decoration: InputDecoration(
                          isDense: true,
                          labelText: AppLocalizations.of(context)!.ipdoesp,
                          labelStyle:
                              FlutterTheme.of(context).bodyMedium.override(
                                    fontFamily: 'Inter',
                                    fontSize: 15.0,
                                    letterSpacing: 0.0,
                                  ),
                          alignLabelWithHint: false,
                          hintText: 'ex: 192.168.178.146',
                          hintStyle:
                              FlutterTheme.of(context).labelMedium.override(
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
                              color: FlutterTheme.of(context).error,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: FlutterTheme.of(context).error,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          filled: true,
                          fillColor:
                              FlutterTheme.of(context).secondaryBackground,
                        ),
                        style: FlutterTheme.of(context).bodyMedium.override(
                              fontFamily: 'Inter',
                              fontSize: 15.0,
                              letterSpacing: 0.0,
                            ),
                        keyboardType: TextInputType.number,
                        cursorColor: Colors.white,
                        validator: _model.textField1TextControllerValidator
                            .asValidator(context),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(30.0, 180.0, 0.0, 0.0),
                child: Text(
                  FlutterAppState().esp32ip,
                  style: FlutterTheme.of(context).bodyMedium.override(
                        fontFamily: 'Inter',
                        letterSpacing: 0.0,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
