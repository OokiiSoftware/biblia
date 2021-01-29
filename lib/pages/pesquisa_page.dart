import 'package:Biblia/auxiliar/config.dart';
import 'package:Biblia/auxiliar/import.dart';
import 'package:Biblia/model/import.dart';
import 'package:Biblia/pages/import.dart';
import 'package:Biblia/res/import.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PesquisaPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<PesquisaPage> {

  //region variaveis
  final TextEditingController controller = TextEditingController();
  final pesquisaList = List<PesquisaResult>();
  final FocusNode _focusNode = FocusNode();
  //endregion

  //region override

  @override
  void dispose() {
    super.dispose();
    _focusNode.dispose();
  }

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: FlexibleSpaceBar(
          titlePadding: EdgeInsets.only(left: 45, right: 80),
          title: TextField(
            controller: controller,
            focusNode: _focusNode,
            style: Styles.normalText,
            decoration: InputDecoration(
                hintText: MenuMain.pesquisa,
                hintStyle: Styles.appBarText,
                border: OutlineInputBorder(
                  borderSide: BorderSide(width: 0, style: BorderStyle.none),
                )
            ),
            onSubmitted: (value) {
              _onPesquisarClick();
            },
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Filtro',
              icon: Icon(Icons.filter_alt_outlined),
              onPressed: _onFiltroClick
          ),
          IconButton(
            tooltip: MenuMain.pesquisa,
              icon: Icon(Icons.search),
              onPressed: () {
                FocusScope.of(context).requestFocus(new FocusNode());
                _onPesquisarClick();
              }
          ),
        ],
      ),
      body: pesquisaList.isEmpty ?
      ListTile(title: OkiText('${controller.text.isEmpty ? 'Clique no primeiro ícone para alterar o filtro' : 'Sem Resultados'}')) :
      ListView.builder(
        padding: EdgeInsets.fromLTRB(10, 10, 10, 80),
        itemCount: pesquisaList.length,
        itemBuilder: (context, index) {
          PesquisaResult item = pesquisaList[index];
          return ListTile(
            title: PesquisaLayout(
              item: item,
              pesquisa: controller.text.trimRight().trimLeft(),
            ),
            subtitle: OkiText('${item.livroName} ${item.capitulo}: ${item.versiculo}'),
            onTap: () => _onResultClick(item),
          );
        },
      ),
      floatingActionButton: pesquisaList.isEmpty ? null :
      FloatingActionButton.extended(
          label: OkiText('${pesquisaList.length} Versículos'),
          onPressed: null
      ),
    );
  }

  //endregion

  //region metodos

  Widget _teste(String text) {
    String pesquisa = controller.text.trimLeft().trimRight();

    List<String> list = text.split(pesquisa);
    List<TextSpan> d = [];

    list.forEach((element) {
      d.add(TextSpan(text: element));
      d.add(TextSpan(text: pesquisa, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)));
    });
    d.removeAt(d.length -1);
    return RichText(
        text: TextSpan(
            style: new TextStyle(
              fontSize: Config.fontSize,
              color: OkiTheme.text,
            ),
          children: d
        )
    );
  }

  void _onResultClick(PesquisaResult item) {
    var livro = Biblia.instance.livros[item.livroAbreviacao];
    Navigate.to(context, MainPage(livro: livro, isPesquisa: true, capitulo: item.capitulo -1, versiculo: item.versiculo -1));
  }

  void _onFiltroClick() async {
    await Navigate.to(context, FiltroPage());
    _onPesquisarClick();
  }

  void _onPesquisarClick() {
    String text = controller.text.trimRight().trimLeft();
    if (text.isEmpty) return;

    List<Livro> livros = [];
    // Log.d('TAG', '_onPesquisarClick', PesquisaFiltro.pesquisaType);
    switch(PesquisaFiltro.pesquisaType) {
      case PesquisaType.antigoTestamentoValue:
        livros.addAll(Biblia.instance.livros.values.where((x) => !x.isNovoTestamento));
        break;
      case PesquisaType.novoTestamentoValue:
        livros.addAll(Biblia.instance.livros.values.where((x) => x.isNovoTestamento));
        break;
      case PesquisaType.tudoValue:
        livros.addAll(Biblia.instance.livrosList);
        break;
      case PesquisaType.somenteValue:
        livros.add(Biblia.instance.getLivro(PesquisaFiltro.livro));
        break;
    }
    var data = List<PesquisaResult>();
    for (Livro livro in livros) {
      for (Capitulo capitulo in livro.capitulos.values) {
        for (Versiculo versiculo in capitulo.versiculos.values) {
          if (versiculo.value.toLowerCase().contains(text.toLowerCase())) {
            data.add(PesquisaResult(
              livroName: livro.nome,
              livroAbreviacao: livro.abreviacao,
              capitulo: capitulo.key,
              versiculo: versiculo.key,
              text: versiculo.value,
            ));
          }
        }
      }
    }
    pesquisaList.clear();
    setState(() {
      pesquisaList.addAll(data);
    });
  }

  //endregion
}

class FiltroPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _StateFiltroPage();
}
class _StateFiltroPage extends State<FiltroPage> {

  //region variaveis
  int currentValue = 0;
  bool showDropDownLivo = false;
  String currentLivro = '';

  final List<String> livros = [];
  //endregion

  //region override

  @override
  void initState() {
    super.initState();

    for (var i in Biblia.instance.livrosList)
      livros.add(i.nome);

    currentLivro = PesquisaFiltro.livro;
    _onRadioChanged(PesquisaFiltro.pesquisaType);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: OkiAppBarText(Titles.ALTERAR_FILTRO_PAGE)),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            OkiText('Pesquisar em:'),
            for (int i = 0; i< PesquisaType.toList().length; i++)
              RadioListTile(
                  value: i,
                  groupValue: currentValue,
                  title: OkiText(PesquisaType(i).toString()),
                  onChanged: _onRadioChanged
              ),

              SizedBox(
                width: double.infinity,
                child: DropDownMenu(
                    value: currentLivro,
                    items: livros,
                    onChanged: showDropDownLivo ? _onLivroChanged : null
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: OkiText('OK'),
        onPressed: _onOkClick,
      ),
    );
  }

  //endregion

  //region metodos

  _onRadioChanged(int index) {
    setState(() {
      currentValue = index;
      showDropDownLivo = index == PesquisaType.somenteValue;
    });
  }

  _onLivroChanged(String value) {
    setState(() {
      currentLivro = value;
    });
  }

  _onOkClick() {
    PesquisaFiltro.pesquisaType = currentValue;
    PesquisaFiltro.livro = currentLivro;
    Navigator.pop(context);
  }

  //endregion
}





