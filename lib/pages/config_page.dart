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

  bool _isAdmin = false;
  bool _inProgress = false;
  bool _isAutoBackup = false;

  String _currentThema;
  double _currentFontSize;

  //endregion

  //region overrides

  @override
  void initState() {
    super.initState();
    _isAdmin = FirebaseOki.isAdmin;
    _currentThema = Config.theme;
    _isAutoBackup = Config.autoBackup;
    _currentFontSize = Config.fontSize;
  }

  @override
  void deactivate() {
    super.deactivate();
    Config.fontSize = _currentFontSize;
    Log.d(Tags.ConfigPage, 'deactivate');
  }

  @override
  Widget build(BuildContext context) {
    var borderRadius = BorderRadius.all(Radius.circular(5));

    return Scaffold(
      appBar: AppBar(
        title: OkiAppBarText(Titles.CONFIGURACOES_PAGE),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        OkiText('Tema'),
                        Padding(padding: EdgeInsets.only(right: 10)),
                        DropDownMenu(
                          value: _currentThema,
                          items: Arrays.thema,
                          onChanged: _onThemeChanged,
                        ),
                      ],
                    ),
                    OkiText('Tamanho da fonte: ${_currentFontSize.toStringAsFixed(2)}'),
                    Slider(
                      min: 15,
                        max: 25,
                        value: _currentFontSize,
                        onChanged: _onFontSizeChanged
                    )
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OkiText('Backup'),
                    Padding(padding: EdgeInsets.only(top: 10)),

                    CheckboxListTile(
                        title: OkiText('Backup Automatico'),
                        value: _isAutoBackup,
                        onChanged: _onAutoBackupChanged
                    ),
                    OkiText('Ultimo Backup: ${Config.ultimoBackup}'),
                    Divider(),
                    OkiText('Com o backup automatico selecionado, seus dados de leitura serão salvos na nuvem em tempo real'),
                    if (!_isAutoBackup)
                      Center(
                        child: FlatButton(
                          minWidth: 200,
                          color: OkiTheme.accent,
                          child: OkiText('Fazer backup agora'),
                          onPressed: _onFazerBackup,
                        ),
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
                    OkiText('Ajude-nos a melhorar enviando sugestões'),
                    Divider(),
                    FlatButton(
                      minWidth: 200,
                      color: OkiTheme.accent,
                      child: OkiAppBarText(MyTexts.ENVIE_SUGESTAO),
                      onPressed: _onSugestaoCkick,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _inProgress ? CircularProgressIndicator() : null,
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

  void _onFontSizeChanged(double value) {
    setState(() {
      Config.fontSize = value;
      _currentFontSize = value;
    });
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
      _inProgress = b;
    });
  }

  //endregion

}
