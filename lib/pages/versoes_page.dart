import 'package:Biblia/auxiliar/import.dart';
import 'package:Biblia/model/import.dart';
import 'package:Biblia/res/import.dart';
import 'package:flutter/material.dart';

class VersoesBibliaPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<VersoesBibliaPage> {

  //region variaveis
  bool _isProgress = false;

  final List<BibliaVersion> data = [];
  final localBiblia = BibliaVersion(
      Config.bibliaLocalVersion,
      'Almeida Corrigida Fiel'
  );
  //endregion

  //region overrides

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(Titles.VERSOES_PAGE, style: Styles.appBarText),
        actions: [
          IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _onAtualizarClick
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          BibliaVersion item = data[index];

          return ListTile(
            title: Text(item.name),
            subtitle: Text(item.version),
            tileColor: item.version == Config.bibliaVersion ? Colors.black45 : null,
            trailing: item.version == Config.bibliaLocalVersion ? null :
            item.isBaixado ?
            IconButton(
              icon: Icon(Icons.delete_forever),
              onPressed: () => _onItemDeleteClick(item),
            ) :
            item.inProgress ?
            CircularProgressIndicator() :
            IconButton(
              icon: Icon(Icons.arrow_circle_down),
              onPressed: () => _onItemDownloadClick(item),
            ),
            onTap: () => _onItemClick(item),
          );
          },
      ),
      floatingActionButton: _isProgress ? CircularProgressIndicator() : null,
    );
  }

  //endregion

  //region metodos

  void _init() async {
    _setIsProgress(true);

    var offData = await Biblia.loadLocal();
    if (offData.isNotEmpty) {
      data.addAll(offData);
    } else
      data.add(localBiblia);

    if (data.length == 1) {
      _onAtualizarClick();
    } else {
      _setIsProgress(false);
      data.sort((a, b) => a.version.compareTo(b.version));
    }
    setState(() {});
  }

  void _onItemClick(BibliaVersion item) async {
    if (!item.isBaixado && item.version != Config.bibliaLocalVersion)
      return;
    if (item.version == Config.bibliaVersion)
      Navigator.pop(context);
    _setIsProgress(true);

    Config.bibliaVersion = item.version;
    if (await Biblia.instance.load(item.version)) {
      Livro livro = Biblia.instance.getLivro(Config.livro);
      Navigator.pop(context, livro);
      // Navigate.toReplacement(context, MainPage(livro: livro));
    }

    _setIsProgress(false);
  }

  void _onItemDownloadClick(BibliaVersion item) async {
    setState(() {
      item.inProgress = true;
    });
    if (await item.baixar()) {
      Log.snack('Baixado');
    } else {
      Log.snack(MyErros.ERRO_GENERICO, isError: true);
    }
    setState(() {});
  }

  void _onItemDeleteClick(BibliaVersion item) async {
    var title = item.name;
    var content = [Text(MyTexts.EXCLUIR_VERSAO_BIBLIA)];
    var result = await DialogBox.dialogSimNao(context, title: title, content: content);
    if (!result.isPositive)
      return;

    if (!await item.delete())
      Log.snack(MyErros.ERRO_GENERICO);
    setState(() {});
  }

  void _onAtualizarClick() async {
    _setIsProgress(true);
    Biblia.baixarVersoes()
        .then((value) {
      if (value.isNotEmpty) {
        data.clear();
        data.add(localBiblia);
        data.addAll(value);

        if (data.length > 1) {
          Biblia.saveLocal(data);
        }
        data.sort((a, b) => a.version.compareTo(b.version));
      }
      _setIsProgress(false);
    }).catchError((e) {
      Log.snack(MyErros.ERRO_GENERICO);
      _setIsProgress(false);
    });
  }

  void _setIsProgress(bool b) {
    if (!mounted) return;
    setState(() {
      _isProgress = b;
    });
  }

  //endregion
}