import 'package:Biblia/auxiliar/import.dart';
import 'package:Biblia/model/import.dart';
import 'package:Biblia/pages/referencia_page.dart';
import 'package:Biblia/res/import.dart';
import 'package:flutter/material.dart';

class MeusDadosPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<MeusDadosPage> {

  bool _inProgress = false;
  List<Referencia> _data = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(Titles.MINHAS_REFERENCIAS_PAGE, style: Styles.appBarText),
        actions: [
          IconButton(
            tooltip: 'Adicionar',
            icon: Icon(Icons.add),
            onPressed: _onAddReferencia,
          ),
          Padding(padding: EdgeInsets.all(5))
        ],
      ),
      body: ListView.builder(
        itemCount: _data.length,
          itemBuilder: (context, index) {
            Referencia item = _data[index];
            return ListTile(
              title: Text(item.titulo),
              subtitle: Text(item.data.substring(0, item.data.indexOf(' ') ?? 0)),
              trailing: IconButton(
                icon: Icon(Icons.delete_forever),
                onPressed: () => _onDeleteItem(item),
              ),
              onTap: () => _onReferenciaClick(item),
            );
          }
      ),
      floatingActionButton: _inProgress ? CircularProgressIndicator() : null,
    );
  }

  void _init() async {
    _setInProgress(true);

    var user = FirebaseOki.userOki;
    await user.baixarMinhasReferencias();
    _data.addAll(user.minhasReferencias.values);

    _setInProgress(false);
  }

  void _onAddReferencia() async {
    var result = await Navigate.to(context, ReferenciasAddPage());
    if (result != null && result is Referencia)
      setState(() {
        _data.add(result);
      });
  }

  void _onReferenciaClick(Referencia item) async {
    var result = await Navigate.to(context, ReferenciaPage(item));
    if (result != null) {
      if (result is bool && result) {
        setState(() {
          _data.remove(item);
        });
      }
      if (result is Referencia) {
        _data.remove(item);
        _data.add(result);
        setState(() {});
      }
    }
  }

  void _onDeleteItem(Referencia item) async {
    _setInProgress(true);
    if (await Aplication.deleteReferencia(context, item))
      _data.remove(item);
    else
      Log.snack(MyErros.DELETE_REFERENCIA, isError: true);
    _setInProgress(false);
  }

  void _setInProgress(bool b) {
    if (!mounted) return;
    setState(() {
      _inProgress = b;
    });
  }
}












