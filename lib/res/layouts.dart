import 'package:Biblia/model/import.dart';
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
      temp.add(new DropdownMenuItem(value: value, child: new Text(value)));
    }
    return DropdownButton(value: value, disabledHint: Text(value), items: temp, onChanged: onChanged);
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
        decoration: InputDecoration(
            suffixIcon: icon,
            labelText: hint,
            labelStyle: TextStyle(color: textIsEmpty ? OkiTheme.textError : OkiTheme.text)
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
      spanTextList.add(TextSpan(text: '$specialText\n', style: TextStyle(fontWeight: FontWeight.bold, color: _getTextColor(item.marker))));

    textList.add('  ${item.key}: ');
    textList.addAll(normalText.split(specialText));

    textList.forEach((element) {
      spanTextList.add(TextSpan(text: element, style: TextStyle(color: _getTextColor(item.marker))));
      if (inicio != 0 && i > 0)
        spanTextList.add(TextSpan(text: specialText, style: TextStyle(fontWeight: FontWeight.bold, color: _getTextColor(item.marker))));
      i++;
    });
    if (inicio != 0 && spanTextList.length > 0)
      spanTextList.removeAt(spanTextList.length -1);
    return RichText(
        text: TextSpan(
            style: new TextStyle(
              fontSize: 14.0,
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
      spanTextList.add(TextSpan(text: pesquisaText, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)));
    });
    if (spanTextList.length > 0)
      spanTextList.removeAt(spanTextList.length -1);
    return RichText(
        text: TextSpan(
            style: new TextStyle(
              fontSize: 14.0,
              color: OkiTheme.text,
            ),
            children: spanTextList
        )
    );
  }
}
