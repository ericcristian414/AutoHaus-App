import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();


  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt')
  ];


  String get janela;

  /// No description provided for @janelaPrototipo.
  ///
  /// In en, this message translates to:
  /// **'Prototype Window'**
  String get janelaPrototipo;

  /// No description provided for @controleManual.
  ///
  /// In en, this message translates to:
  /// **'Manual Control'**
  String get controleManual;

  /// No description provided for @detecaoChuva.
  ///
  /// In en, this message translates to:
  /// **'Rain Detection:'**
  String get detecaoChuva;

  /// No description provided for @modoAutomatico.
  ///
  /// In en, this message translates to:
  /// **'Automatic Mode'**
  String get modoAutomatico;

  /// No description provided for @controleClima.
  ///
  /// In en, this message translates to:
  /// **'Weather-based control'**
  String get controleClima;

  /// No description provided for @abrir.
  ///
  /// In en, this message translates to:
  /// **' Open         '**
  String get abrir;

  /// No description provided for @fechar.
  ///
  /// In en, this message translates to:
  /// **' Close          '**
  String get fechar;

  /// No description provided for @limpo.
  ///
  /// In en, this message translates to:
  /// **'Clean 🌞'**
  String get limpo;

  /// No description provided for @umido.
  ///
  /// In en, this message translates to:
  /// **'Wet 🌦'**
  String get umido;

  /// No description provided for @toldo.
  ///
  /// In en, this message translates to:
  /// **'Awning'**
  String get toldo;

  /// No description provided for @recolher.
  ///
  /// In en, this message translates to:
  /// **'Retract   '**
  String get recolher;

  /// No description provided for @velocidades.
  ///
  /// In en, this message translates to:
  /// **'Speeds'**
  String get velocidades;

  /// No description provided for @motores.
  ///
  /// In en, this message translates to:
  /// **'Motors'**
  String get motores;

  /// No description provided for @configuracoes.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get configuracoes;

  /// No description provided for @dispositivos.
  ///
  /// In en, this message translates to:
  /// **'Devices'**
  String get dispositivos;

  /// No description provided for @procure.
  ///
  /// In en, this message translates to:
  /// **'Search for your devices...'**
  String get procure;

  /// No description provided for @lampada.
  ///
  /// In en, this message translates to:
  /// **'Lamp'**
  String get lampada;

  /// No description provided for @hortas.
  ///
  /// In en, this message translates to:
  /// **'Gardens'**
  String get hortas;

  /// No description provided for @computador.
  ///
  /// In en, this message translates to:
  /// **'Computer'**
  String get computador;

  /// No description provided for @arCondicionado.
  ///
  /// In en, this message translates to:
  /// **'Air Conditioner'**
  String get arCondicionado;

  /// No description provided for @cronoJanela.
  ///
  /// In en, this message translates to:
  /// **'Window Ajustments'**
  String get cronoJanela;

  /// No description provided for @cronoToldo.
  ///
  /// In en, this message translates to:
  /// **'Awning Ajustments'**
  String get cronoToldo;

  /// No description provided for @abreEfecha.
  ///
  /// In en, this message translates to:
  /// **'Scheduled opening and             closing:'**
  String get abreEfecha;

  /// No description provided for @abrirJanela.
  ///
  /// In en, this message translates to:
  /// **'Open Window'**
  String get abrirJanela;

  /// No description provided for @abrirToldo.
  ///
  /// In en, this message translates to:
  /// **'Open Awning'**
  String get abrirToldo;

  /// No description provided for @fecharJanela.
  ///
  /// In en, this message translates to:
  /// **'Close Window'**
  String get fecharJanela;

  /// No description provided for @fecharToldo.
  ///
  /// In en, this message translates to:
  /// **'Close Awning'**
  String get fecharToldo;

  /// No description provided for @motorADianteiroToldo.
  ///
  /// In en, this message translates to:
  /// **'Front Motor A Awning'**
  String get motorADianteiroToldo;

  /// No description provided for @motorBTraseiroToldo.
  ///
  /// In en, this message translates to:
  /// **'Rear Motor B Awning'**
  String get motorBTraseiroToldo;

  /// No description provided for @motorToldo.
  ///
  /// In en, this message translates to:
  /// **'Awning Motor'**
  String get motorToldo;

  /// No description provided for @motorJanela.
  ///
  /// In en, this message translates to:
  /// **'Window Motor'**
  String get motorJanela;

  /// No description provided for @pararMotores.
  ///
  /// In en, this message translates to:
  /// **'Stop Motors'**
  String get pararMotores;

  /// No description provided for @toldoAbrir.
  ///
  /// In en, this message translates to:
  /// **'Awning Open'**
  String get toldoAbrir;

  /// No description provided for @toldoRecolher.
  ///
  /// In en, this message translates to:
  /// **'Awning Retract'**
  String get toldoRecolher;

  /// No description provided for @recolherToldo.
  ///
  /// In en, this message translates to:
  /// **'Retract Awning'**
  String get recolherToldo;

  /// No description provided for @definirVelocidades.
  ///
  /// In en, this message translates to:
  /// **'Set Speeds'**
  String get definirVelocidades;

  /// No description provided for @resetarVelocidades.
  ///
  /// In en, this message translates to:
  /// **'Reset Speeds'**
  String get resetarVelocidades;

  /// No description provided for @ajustedeIP.
  ///
  /// In en, this message translates to:
  /// **'IP Settings'**
  String get ajustedeIP;

  /// No description provided for @idioma.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get idioma;

  /// No description provided for @ipdoesp.
  ///
  /// In en, this message translates to:
  /// **'ESP32 IP'**
  String get ipdoesp;

  /// No description provided for @portoes.
  ///
  /// In en, this message translates to:
  /// **'Gates'**
  String get portoes;

  /// No description provided for @frente.
  ///
  /// In en, this message translates to:
  /// **'Front'**
  String get frente;

  /// No description provided for @tras.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get tras;

  /// No description provided for @ajusteVel.
  ///
  /// In en, this message translates to:
  /// **'Adjustment of the Speeds'**
  String get ajusteVel;

  /// No description provided for @velAFrente.
  ///
  /// In en, this message translates to:
  /// **'Speed A Forward'**
  String get velAFrente;

  /// No description provided for @velATras.
  ///
  /// In en, this message translates to:
  /// **'Speed A Backward'**
  String get velATras;

  /// No description provided for @velBFrente.
  ///
  /// In en, this message translates to:
  /// **'Speed B Forward'**
  String get velBFrente;

  /// No description provided for @velBTras.
  ///
  /// In en, this message translates to:
  /// **'Speed B Backward'**
  String get velBTras;

  /// No description provided for @abrirA.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get abrirA;

  /// No description provided for @fecharA.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get fecharA;

  /// No description provided for @recolherA.
  ///
  /// In en, this message translates to:
  /// **'Retract'**
  String get recolherA;

  /// No description provided for @chuva.
  ///
  /// In en, this message translates to:
  /// **'Rain'**
  String get chuva;

  /// No description provided for @luminosidade.
  ///
  /// In en, this message translates to:
  /// **'Luminosity'**
  String get luminosidade;

  /// No description provided for @selSensor.
  ///
  /// In en, this message translates to:
  /// **'Select sensor'**
  String get selSensor;

  /// No description provided for @controleMotores.
  ///
  /// In en, this message translates to:
  /// **'Motor Control'**
  String get controleMotores;

  /// No description provided for @selecionar.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get selecionar;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'pt': return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
