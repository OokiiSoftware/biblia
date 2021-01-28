import 'package:Biblia/auxiliar/import.dart';
import 'package:Biblia/model/import.dart';
import 'package:Biblia/res/import.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';

class ConfigPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<ConfigPage> {

  //region Variaveis
  // static const String TAG = 'ConfigPage';

  bool _isAdmin = false;
  bool inProgress = false;
  bool _isAutoBackup = false;

  String _currentThema;

  //endregion

  //region overrides

  @override
  void initState() {
    super.initState();
    _isAdmin = FirebaseOki.isAdmin;
    _currentThema = Config.theme;
    _isAutoBackup = Config.autoBackup;
  }

  @override
  Widget build(BuildContext context) {
    var borderRadius = BorderRadius.all(Radius.circular(5));

    return Scaffold(
      appBar: AppBar(
        title: Text(Titles.CONFIGURACOES_PAGE, style: Styles.appBarText),
        actions: [
          if (_isAdmin)
            IconButton(
              tooltip: Titles.ADMIN_PAGE,
              icon: Icon(Icons.admin_panel_settings),
              onPressed: _gotoAdminPage,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: borderRadius,
              child: Container(
                color: OkiTheme.cardColor,
                padding: EdgeInsets.all(10),
                child: Row(
                  children: [
                    Text('Tema'),
                    Padding(padding: EdgeInsets.only(right: 10)),
                    DropDownMenu(
                      value: _currentThema,
                      items: Arrays.thema,
                      onChanged: _onThemeChanged,
                    ),
                  ],
                ),
              ),
            ),
            if (FirebaseOki.userOki != null)
            ClipRRect(
              borderRadius: borderRadius,
              child: Container(
                color: OkiTheme.cardColor,
                width: double.infinity,
                padding: EdgeInsets.all(10),
                child: Column(
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text('Backup'),
                    ),
                    Padding(padding: EdgeInsets.only(top: 10)),

                    CheckboxListTile(
                        title: Text('Backup Automatico'),
                        value: _isAutoBackup,
                        onChanged: _onAutoBackupChanged
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text('Ultimo Backup: ${Config.ultimoBackup}'),
                    ),
                    if (!_isAutoBackup)
                      FlatButton(
                        minWidth: 200,
                        color: OkiTheme.accent,
                        child: Text('Fazer backup agora'),
                        onPressed: _onFazerBackup,
                      ),
                  ],
                ),
              ),
            ),
            Padding(padding: EdgeInsets.all(5)),
            //Sugestões
            ClipRRect(
              borderRadius: borderRadius,
              child: Container(
                color: OkiTheme.cardColor,
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    Text(
                        'Ajude-nos a melhorar enviando sugestões',
                        textAlign: TextAlign.center),
                    Divider(),
                    FlatButton(
                      minWidth: 200,
                      color: OkiTheme.accent,
                      child: Text(MyTexts.ENVIE_SUGESTAO, style: Styles.appBarText),
                      onPressed: _onSugestaoCkick,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: inProgress ? CircularProgressIndicator() : null,
    );
  }

  //endregion

  //region Metodos

  void onSalvar() async {
    Log.snack(MyTexts.DADOS_SALVOS);
  }

  void _onThemeChanged(String value) async {
    setState(() {
      _currentThema = value;
    });
    Config.theme = value;
    Brightness brightness = OkiTheme.getBrilho(value);
    await DynamicTheme.of(context).setBrightness(brightness);
  }

  void _onAutoBackupChanged(bool value) {
    Config.autoBackup = value;
    setState(() {
      _isAutoBackup = value;
    });
  }

  void _onFazerBackup() async {
    _setInProgress(true);
    if (await FirebaseOki.userOki.saveExternalData()) {
      Log.snack(MyTexts.DADOS_SALVOS);
      Config.ultimoBackup = DataHora.now();
    }
    else
      Log.snack(MyErros.USER_DADOS_SAVE, isError: true);
    _setInProgress(false);
  }

  void _onSugestaoCkick() async {
    var controller = TextEditingController();
    var title = MyTexts.ENVIAR_SUGESTAO_TITLE;
    var content = [
      TextField(
        controller: controller,
        decoration: InputDecoration(
            hintText: MyTexts.DIGITE_AQUI
        ),
      )
    ];
    var result = await DialogBox.dialogCancelOK(context, title: title, content: content);
    var desc = controller.text;
    if (result.isPositive && desc.trim().isNotEmpty) {
      Sugestao item = Sugestao();
      item.idUser = FirebaseOki.user.uid;
      item.data = DataHora.now();
      item.descricao = desc;

      _setInProgress(true);
      if (await item.salvar())
        Log.snack(MyTexts.ENVIE_SUGESTAO_AGRADECIMENTO);
      else
        Log.snack(MyErros.ERRO_GENERICO, isError: true);
      _setInProgress(false);
    }
  }

  void _gotoAdminPage() {
    // Navigate.to(context, AdminPage());
  }

  void _setInProgress(bool b) {
    if(!mounted) return;
    setState(() {
      inProgress = b;
    });
  }

  //endregion

}
