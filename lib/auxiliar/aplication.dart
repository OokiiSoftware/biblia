import 'dart:ui';
import 'package:Biblia/auxiliar/firebase.dart';
import 'package:Biblia/auxiliar/local_database.dart';
import 'package:Biblia/model/import.dart';
import 'package:Biblia/pages/import.dart';
import 'package:Biblia/res/import.dart';
import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

import 'admin.dart';
import 'estudos.dart';
import 'navigate.dart';
import 'offline_data.dart';
import 'preferences.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';
import 'logs.dart';

class Aplication {
  static const String TAG = 'Aplication';

  static int appVersionInDatabase = 0;
  static PackageInfo packageInfo;

  static bool get isRelease => bool.fromEnvironment('dart.vm.product');
  static Locale get locale => Locale('pt', 'BR');

  static Future<void> init() async {
    Log.d(TAG, 'init', 'iniciando');

    await OfflineData.init();
    await FirebaseOki.init();
    await Preferences.init();
    await Estudos.instance.load();
    await LocalDatabase.instance.load();
    packageInfo = await PackageInfo.fromPlatform();

    Admin.checkAdmin();
    Config.readConfig();
    Log.d(TAG, 'init', 'OK');
  }

  static void setOrientation(List<DeviceOrientation> orientacoes) {
    SystemChrome.setPreferredOrientations(orientacoes);
  }

  static Future<String> buscarAtualizacao() async {
    Log.d(TAG, 'buscarAtualizacao', 'Iniciando');
    int _value = await FirebaseOki.database
        .child(FirebaseChild.VERSAO)
        .once()
        .then((value) => value.value)
        .catchError((e) {
      Log.e(TAG, 'buscarAtualizacao', e);
      return -1;
    });
    // String url;

    Log.d(TAG, 'buscarAtualizacao', 'Web Version', _value, 'Local Version', packageInfo.buildNumber);
    appVersionInDatabase = _value;
    int appVersion = int.parse(packageInfo.buildNumber);

    if (_value > appVersion) {
      // url = FirebaseOki.userOki;
    }

    return null;
  }

  static Future<bool> openUrl(String url, [BuildContext context]) async {
    try {
      if (await canLaunch(url))
        await launch(url);
      else
        throw Exception(MyErros.ABRIR_LINK);
      return true;
    } catch(e) {
      if (context != null)
        Log.snack(MyErros.ABRIR_LINK, isError: true);
      Log.e(TAG, 'openUrl', e);
      return false;
    }
  }

  static void openEmail(String email, [BuildContext context]) async {
    final Uri _emailLaunchUri = Uri(
        scheme: 'mailto',
        path: '$email',
        queryParameters: {
          'subject': 'Anime App'
        }
    );
    try {
      if (await canLaunch(_emailLaunchUri.toString()))
        await launch(_emailLaunchUri.toString());
      else
        throw Exception(MyErros.ABRIR_EMAIL);
    } catch(e) {
      if (context != null)
        Log.snack(MyErros.ABRIR_EMAIL, isError: true);
      Log.e(TAG, 'openUrl', e);
    }
  }

  static void openYouTube(String link, [BuildContext context]) async {
    try {
      if (await canLaunch(link)) {
        await launch(link);
      } else {
        throw 'Could not launch $link';
      }
    } catch(e) {
      if (context != null)
        Log.snack(MyErros.ABRIR_YOUTUBE, isError: true);
      Log.e(TAG, 'openYouTube', e);
    }
  }

  static Future<bool> deleteReferencia(BuildContext context, Referencia item) async {
    var title = MyTexts.EXCLUIR_REFERENCIA_TITLE;
    var content = [OkiText(MyTexts.EXCLUIR_REFERENCIA_MSG)];
    var result = await DialogBox.dialogSimNao(context, title: title, content: content);
    if (result.isPositive) {
      if (await item.delete()) {
        Log.snack('Item excluido.');
        return true;
      } else {
        Log.snack('Erro ao excluir.', isError: true);
        return false;
      }
    }
    return false;
  }

  static Future<bool> checkLogin(BuildContext context) async {
    if (FirebaseOki.userOki == null) {
      var title = 'Login';
      var content = [
        OkiText('Você precisa estar logado para realizar essa ação.'),
        OkiText('Deseja fazer login agora?'),
      ];
      var result = await DialogBox.dialogSimNao(context, title: title, content: content);
      if (result.isPositive) {
        var result = await Navigate.to(context, LoginPage(context));
        if (result == null || !(result is bool) || !result)
          return false;
      } else
        return false;
    }
    return true;
  }

  static Future<bool> addReferenciaComoLido(BuildContext context, Referencia item, bool referenciaLida) async {
    if (!await checkLogin(context))
      return false;

    if (referenciaLida) {
      if (!FirebaseOki.userOki.removeReferencia(item.id)) {
        Log.snack(MyErros.ERRO_ADD_LIDO, isError: true);
        return false;
      }
    } else {
      if (!FirebaseOki.userOki.addReferencia(item)) {
        Log.snack(MyErros.ERRO_ADD_LIDO, isError: true);
        return false;
      }
    }
    return true;
  }

}