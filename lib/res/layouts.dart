import 'dart:ui' as ui;
import 'package:Biblia/auxiliar/config.dart';
import 'package:Biblia/model/import.dart';
import 'package:Biblia/res/import.dart';
import 'package:flutter/material.dart';
import 'colors.dart';
import 'icons.dart';
import 'strings.dart';
import 'theme.dart';

class DropDownMenu extends StatelessWidget {
  final List<String> items;
  final Function(String) onChanged;
  final String value;
  DropDownMenu({@required this.items, @required this.onChanged, this.value});

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem<String>> temp = new List();
    for (String value in items) {
      temp.add(new DropdownMenuItem(value: value, child: new OkiText(value)));
    }
    return DropdownButton(value: value, disabledHint: OkiText(value), items: temp, onChanged: onChanged);
  }
}

class TextFieldOki extends StatelessWidget{

  final String hint;
  final TextEditingController controller;
  final Widget icon;
  final bool textIsEmpty;
  final Function onTap;
  final int maxLines;
  final TextInputType keyboardType;

  TextFieldOki({
    this.hint,
    this.controller,
    this.icon,
    this.textIsEmpty = false,
    this.keyboardType,
    this.maxLines = 1,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        minLines: 1,
        keyboardType: keyboardType,
        style: Styles.normalText,
        decoration: InputDecoration(
            suffixIcon: icon,
            labelText: hint,
            labelStyle: TextStyle(color: textIsEmpty ? OkiTheme.textError : OkiTheme.text, fontSize: Config.fontSize)
        ),
        onTap: onTap,
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var padding = Padding(padding: EdgeInsets.only(top: 20));
    return Scaffold(
      backgroundColor: OkiTheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(OkiIcons.ic_launcher_adaptive, width: 170),
            padding,
            Text(AppResources.APP_NAME, style: TextStyle(fontSize: 30, color: OkiColors.textDark)),
          ],
        ),
      ),
    );
  }
}

class VersiculoLayout extends StatelessWidget {
  final Versiculo item;
  VersiculoLayout(this.item);

  @override
  Widget build(BuildContext context) {
    String normalText = item.value.replaceAll('<J>', '').replaceAll('</J>', '');
    String specialText = '';

    List<String> textList = [];
    List<TextSpan> spanTextList = [];

    int i = 0;
    int inicio = normalText.indexOf('<i>');
    int fim = normalText.indexOf('</i>');

    if (normalText.contains('<i>')) {
      specialText = normalText.substring(inicio, fim).replaceAll('<i>', '').replaceAll('</i>', '');
      normalText = normalText.replaceAll('<i>', '').replaceAll('</i>', '');
    }

    if (inicio == 0)
      spanTextList.add(TextSpan(text: '$specialText\n', style: TextStyle(fontWeight: FontWeight.bold, fontSize: Config.fontSize, color: _getTextColor(item.marker))));

    textList.add('  ${item.key}: ');
    textList.addAll(normalText.split(specialText));

    textList.forEach((element) {
      spanTextList.add(TextSpan(text: element, style: TextStyle(color: _getTextColor(item.marker), fontSize: Config.fontSize)));
      if (inicio != 0 && i > 0)
        spanTextList.add(TextSpan(text: specialText, style: TextStyle(fontWeight: FontWeight.bold, fontSize: Config.fontSize, color: _getTextColor(item.marker))));
      i++;
    });
    if (inicio != 0 && spanTextList.length > 0)
      spanTextList.removeAt(spanTextList.length -1);
    return RichText(
        text: TextSpan(
            style: new TextStyle(
              fontSize: Config.fontSize,
              color: OkiTheme.text,
            ),
            children: spanTextList
        )
    );
  }

  Color _getTextColor(Marker marker) {
    if (marker == null || marker == Marker.none)
      return null;
    return Colors.white;
  }

}

class PesquisaLayout extends StatelessWidget {
  final String pesquisa;
  final PesquisaResult item;
  PesquisaLayout({this.item, this.pesquisa});

  @override
  Widget build(BuildContext context) {
    String normalText = item.text.replaceAll('<J>', '').replaceAll('</J>', '').replaceAll('<i>', '').replaceAll('</i>', '');
    String pesquisaText = '';

    List<String> textList = [];
    List<TextSpan> spanTextList = [];

    int inicio = normalText.toLowerCase().indexOf(pesquisa.toLowerCase());
    int fim = pesquisa.length + inicio;

    if (inicio > 0)
      pesquisaText = normalText.substring(inicio, fim);

    textList.addAll(normalText.split(pesquisaText));

    textList.forEach((element) {
      spanTextList.add(TextSpan(text: element));
      spanTextList.add(TextSpan(text: pesquisaText, style: TextStyle(fontWeight: FontWeight.bold, fontSize: Config.fontSize, color: Colors.green)));
    });
    if (spanTextList.length > 0)
      spanTextList.removeAt(spanTextList.length -1);
    return RichText(
        text: TextSpan(
            style: new TextStyle(
              fontSize: Config.fontSize,
              color: OkiTheme.text,
            ),
            children: spanTextList
        )
    );
  }
}

class OkiText extends StatelessWidget {
  final String text;
  OkiText(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(text, style: Styles.normalText);
  }
}
class OkiTitleText extends StatelessWidget {
  final String text;
  OkiTitleText(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(text, style: Styles.titleText);
  }
}
class OkiAppBarText extends StatelessWidget {
  final String text;
  OkiAppBarText(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(text, style: Styles.appBarText);
  }
}
class OkiErrorText extends StatelessWidget {
  final String text;
  OkiErrorText(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(text, style: Styles.textEror);
  }
}

class ShadowText extends StatelessWidget {
  ShadowText(this.text, { this.style }) : assert(text != null);

  final String text;
  final TextStyle style;

  Widget build(BuildContext context) {
    return new ClipRect(
      child: new Stack(
        children: [
          Text(
            text,
            style: style == null ? TextStyle(color: Colors.black.withOpacity(0.5)) :
            style.copyWith(color: Colors.black.withOpacity(0.5)),
          ),
          BackdropFilter(
            filter: new ui.ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
            child: new Text(text, style: style),
          ),
        ],
      ),
    );
  }
}
