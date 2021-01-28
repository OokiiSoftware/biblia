import 'package:Biblia/auxiliar/import.dart';
import 'package:Biblia/res/import.dart';
import 'package:flutter/material.dart';

class InfoPage extends StatefulWidget {
  @override
  _MyState createState() => _MyState();
}
class _MyState extends State<InfoPage> {

  //region overrides

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Titles.INFORMACOES_PAGE, style: Styles.appBarText)),
      body: Center(
        child: _appInfo(),
      ),
    );
  }

  //endregion

  //region Metodos

  Widget _appInfo() {
    var dividerP = Padding(padding: EdgeInsets.only(top: 10, right: 5));
    var dividerG = Padding(padding: EdgeInsets.only(top: 30));
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
        children: [
      //Icone
      Image.asset(OkiIcons.ic_launcher,
        width: 130,
        height: 130,
      ),
      dividerG,
      Text('${AppResources.APP_NAME}'),
      dividerP,
      Text('${Strings.VERSAO} : ${Aplication.packageInfo.version}'),
      dividerG,
      Text(Strings.CONTATOS),
      dividerP,
      GestureDetector(
        child: Text(AppResources.app_email, style: TextStyle(color: OkiTheme.accent)),
        onTap: () {Aplication.openEmail(AppResources.app_email, context);},
      ),
      dividerG,
      Text(Strings.POR),
      dividerP,
      Tooltip(
        message: AppResources.company_name,
        child: Image.asset(OkiIcons.ic_oki_logo,
          width: 80,
          height: 80,
        ),
      ),
    ]);
  }

  //endregion

}