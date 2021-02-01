import 'dart:ui';
import 'package:Biblia/auxiliar/import.dart';
import 'package:flutter/material.dart';
import 'theme.dart';

class Styles {
  // static TextStyle text = TextStyle(color: OkiTheme.text);
  static TextStyle get appBarText => TextStyle(color: Colors.white);
  static TextStyle get normalText => TextStyle(color: OkiTheme.text, fontSize: Config.fontSize);
  static TextStyle get titleText => TextStyle(color: OkiTheme.text, fontSize: Config.fontSize + 5);
  static TextStyle get textEror => TextStyle(color: OkiTheme.textError, fontSize: Config.fontSize);
}
