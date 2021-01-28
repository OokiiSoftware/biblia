import 'package:Biblia/auxiliar/import.dart';
import 'package:Biblia/model/import.dart';
import 'package:Biblia/res/import.dart';
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class SelecionarLivroPage extends StatefulWidget {
  final Livro currentLivro;
  SelecionarLivroPage({this.currentLivro});
  @override
  State<StatefulWidget> createState() => _State(currentLivro);
}
class _State extends State<SelecionarLivroPage> {

  //region variaveis

  final Livro currentLivro;
  final List<Livro> livros = Biblia.instance.livrosList;

  // ScrollController scrollController = ScrollController();
  final ItemScrollController itemScrollController = ItemScrollController();

  int inicialScrollIndex = 0;

  //endregion

  _State(this.currentLivro);

  //region overrides

  @override
  void dispose() {
    super.dispose();
    // scrollController.dispose();
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    bool userLogado = FirebaseOki.isLogado;
    UserOki user = FirebaseOki.userOki;

    return Scaffold(
      appBar: AppBar(title: Text('Livros', style: Styles.appBarText)),
      body: ScrollablePositionedList.builder(
        itemScrollController: itemScrollController,
        itemCount: livros.length,
        initialScrollIndex: inicialScrollIndex,
          itemBuilder: (context, index) {
            Livro item = livros[index];
            bool thisLivro = currentLivro == item;

            return ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50/3),
                ),
                child: Container(
                  height: 40,
                  width: 40,
                  color: thisLivro ? Colors.grey : item.isNovoTestamento ? OkiTheme.accent : OkiTheme.accentLight,
                  child: Center(child: Text(item.abreviacao, style: Styles.appBarText)),
                ),
              ),
              title: Text(item.nome),
              trailing: userLogado ? ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(50)),
                child: Container(
                  height: 30,
                  width: 50,
                  color: item.isNovoTestamento ? Colors.blueGrey : Colors.grey,
                  child: Center(child: Text('${user.livrosLidos[item.abreviacao]?.length ?? 0}/${item.capitulosCount}', style: TextStyle(fontSize: 12, color: Colors.white))),
                ),
              ) : null,
              onTap: () => _onItemClick(item),
            );
          }
      ),
    );

    /*return Scaffold(
      appBar: AppBar(title: Text('Livros', style: Styles.appBarText)),
      body: ListView.builder(
        itemCount: livros.length,
          // controller: scrollController,
          itemBuilder: (BuildContext context, int index) {
            Livro item = livros[index];
            bool thisLivro = currentLivro == item.nome;
            return ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50/3),
                ),
                child: Container(
                  height: 40,
                  width: 40,
                  color: thisLivro ? Colors.grey : item.isNovoTestamento ? OkiTheme.accent : OkiTheme.accentLight,
                  child: Center(child: Text(item.abreviacao, style: Styles.appBarText)),
                ),
              ),
              title: Text(item.nome),
              trailing: userLogado ? ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(50)),
                child: Container(
                  height: 30,
                  width: 50,
                  color: item.isNovoTestamento ? Colors.blueGrey : Colors.grey,
                  child: Center(child: Text('${user.livrosLidos[item.abreviacao]?.length ?? 0}/${item.capitulosCount}', style: TextStyle(fontSize: 12, color: Colors.white))),
                ),
              ) : null,
              onTap: () => _onItemClick(item),
            );
          }
      ),
    );*/
  }

  //endregion

  //region metodos

  _init() async {
    // await Future.delayed(Duration(milliseconds: 100));
    // if (!mounted) {
    //   _init();
    //   return;
    // }
    if (currentLivro != null) {
      inicialScrollIndex = livros.indexOf(currentLivro) ?? 0;
      // double position = livros.indexWhere((x) => x.nome == currentLivro).toDouble();
      // scrollController.animateTo(
      //     position * 55,
      //     duration: Duration(milliseconds: 500),
      //     curve: Curves.fastOutSlowIn,
      // );
    }

  }

  _onItemClick(Livro item) {
    if (item == currentLivro) {
      Navigator.pop(context);
      return;
    }
    Biblia.instance.setCurrentLivro(item);
    Navigator.pop(context, item);
  }

  //endregion

}

class SelecionarCapituloPage extends StatefulWidget{
  final Livro livro;
  final Livro livroB;
  final bool isSingleReturn;
  SelecionarCapituloPage(this.livro, {this.livroB, this.isSingleReturn = false});

  @override
  State<StatefulWidget> createState() => _StateCapitulo(livro, livroB, isSingleReturn);
}
class _StateCapitulo extends State<SelecionarCapituloPage> {

  //region variaveis
  final Livro livro;
  final Livro livroB;
  final bool isSingleReturn;
  final Map<int, Capitulo> capitulos = Map();
  //endregion

  _StateCapitulo(this.livro, this.livroB, this.isSingleReturn);

  //region overrides

  @override
  void initState() {
    super.initState();
    if (livroB != null) {
      for (int key in livroB.capitulos.keys) {
        capitulos[key] = livroB.capitulos[key];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(livro.nome, style: Styles.appBarText)),
      body: GridView.builder(
          padding: EdgeInsets.fromLTRB(2, 2, 2, 80),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2
          ),
          itemCount: livro.capitulos.length,
          itemBuilder: (context, index) {
            Capitulo item = livro.capitulos[index +1];
            return GestureDetector(
              child: Container(
                color: getColor(item),
                child: Center(
                  child: Text('${item.key}', style: TextStyle(color: Colors.white)),
                ),
              ),
              onTap: () => _onCapituloClick(item),
            );
          }
      ),
      floatingActionButton: isSingleReturn ? null :
      FloatingActionButton(
        child: Text('OK'),
        onPressed: _onOk,
      ),
    );
  }

  //endregion

  //region metodos

  Color getColor(Capitulo item) {
    return capitulos[item.key] == null ? Colors.grey : Colors.deepOrange;
  }

  void _onCapituloClick(Capitulo item) async {
    if (isSingleReturn) {
      Navigator.pop(context, item);
    } else {
      var result = await Navigate.to(context, SelecionarVersiculoPage(item, capituloB: capitulos[item.key]));
      if (result == null || !(result is List<int>)) return;

      if (result.isEmpty) {
        setState(() {
          capitulos.remove(item.key);
        });
        return;
      }

      Map<int, Versiculo> map = Map();
      for (int versiculo in result)
        map[versiculo] = item.versiculos[versiculo];

      var cap = Capitulo(item.key, map);
      setState(() {
        // capitulos.remove(item.key);
        capitulos[cap.key] = cap;
      });
    }
  }

  void _onOk() {
    Navigator.pop(context, capitulos);
  }

  //endregion

}

class SelecionarVersiculoPage extends StatefulWidget {
  final Capitulo capitulo;
  final Capitulo capituloB;
  SelecionarVersiculoPage(this.capitulo, {this.capituloB});
  @override
  State<StatefulWidget> createState() => _StateVersiculo(capitulo, capituloB);
}
class _StateVersiculo extends State<SelecionarVersiculoPage> {

  //region variaveis
  final Capitulo capitulo;
  final Capitulo capituloB;
  final List<int> selecionados = [];
  //endregion

  _StateVersiculo(this.capitulo, this.capituloB);

  //region overrides

  @override
  void initState() {
    super.initState();
    if (capituloB != null) {
      for (int key in capituloB.versiculos.keys) {
        selecionados.add(key);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${Strings.CAPITULO} ${capitulo.key}', style: Styles.appBarText)),
      body: GridView.builder(
          padding: EdgeInsets.fromLTRB(2, 2, 2, 80),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2
          ),
          itemCount: capitulo.versiculos.length,
          itemBuilder: (context, index) {
            Versiculo item = capitulo.versiculos[index +1];
            return GestureDetector(
              child: Container(
                color: getColor(item),
                child: Center(
                  child: Text('${item.key}', style: TextStyle(color: Colors.white)),
                ),
              ),
              onTap: () => _onVersiculoClick(item),
            );
          }
      ),
      floatingActionButton: FloatingActionButton(
        child: Text('OK'),
        onPressed: _onOk,
      ),
    );
  }

  //endregion

  //region metodos

  Color getColor(Versiculo item) {
    return selecionados.contains(item.key) ? Colors.deepOrange : Colors.grey;
  }

  void _onVersiculoClick(Versiculo item) {
    setState(() {
      if (selecionados.contains(item.key)) {
        selecionados.remove(item.key);
      }
      else
        selecionados.add(item.key);
    });
  }

  void _onOk() {
    Navigator.pop(context, selecionados);
  }

  //endregion

}
