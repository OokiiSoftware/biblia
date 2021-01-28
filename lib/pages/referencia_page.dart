import 'package:Biblia/auxiliar/import.dart';
import 'package:Biblia/model/import.dart';
import 'package:Biblia/pages/import.dart';
import 'package:Biblia/res/import.dart';
import 'package:flutter/material.dart';

class ReferenciasPage extends StatefulWidget {
  final Livro livro;
  final int capitulo;
  final int versiculo;
  ReferenciasPage(this.livro, this.capitulo, this.versiculo);
  @override
  State<StatefulWidget> createState() => _State(livro, capitulo, versiculo);
}
class _State extends State<ReferenciasPage> {

  //region variaveis
  // static const String TAG = 'ReferenciasPage';

  final Livro livro;
  final int capitulo;
  final int versiculo;

  bool isIniciado = false;
  bool inProgress = true;
  List<Referencia> referencias = [];
  //endregion

  _State(this.livro, this.capitulo, this.versiculo);

  //region override

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${livro.nome} $capitulo: $versiculo', style: Styles.appBarText)),
      body:referencias.isEmpty ?
      ListTile(title: Text('Sem Referências')) :
      ListView.builder(
        itemCount: referencias.length,
          itemBuilder: (context, index) {
            Referencia item = referencias[index];
            return ListTile(
              title: Text(item.titulo),
              subtitle: Text(item.autor),
              trailing: getTrailingIcon(item),
              onTap: () => _onReferenciaClick(item),
            );
          },
      ),
      floatingActionButton: inProgress ? CircularProgressIndicator() : null,
    );
  }

  //endregion

  //region metodos

  Widget getTrailingIcon(Referencia item) {
    // Log.d('ReferenciasPage', 'getTrailingIcon', item.userId, FirebaseOki.user.uid);
    if (item.userId == FirebaseOki.user?.uid ?? false)
      return IconButton(
        icon: Icon(Icons.delete_forever),
        onPressed: () => _onDeleteItem(item),
      );
    if (FirebaseOki.userOki?.referencias?.containsKey(item.id) ?? false)
      return Icon(
          Icons.circle,
          color: FirebaseOki.userOki.referencias[item.id].toString().compareTo(item.data) >= 0 ?
          Colors.greenAccent : Colors.deepOrangeAccent,
          size: 15
      );
    return null;
  }

  void _init() async {
    String offDataPath = '${livro.abreviacao}_${capitulo}_$versiculo';
    dynamic offData = /*await livro.getLocalReferencias(capitulo, versiculo);*/ OfflineData.read(offDataPath);

    if (offData != null && offData is List<dynamic>) {
      for (var item in offData)
        referencias.add(Referencia.fromJson(item));
      if(!mounted) return;
      setState(() {
        isIniciado = true;
      });
    }

    _setInProgress(true);
    var data = await livro.getReferencias(capitulo, versiculo);

    referencias.clear();
    referencias.addAll(data);

    if(!mounted) return;
    setState(() {
      isIniciado = true;
    });
    _setInProgress(false);

    // LocalDatabase.instance
    //     .child(FirebaseChild.REFERENCIAS)
    //     .child(livro.abreviacao)
    //     .child('$capitulo')
    //     .child('$versiculo')
    //     .set(data);
    if (data.isNotEmpty)
      OfflineData.save(data, offDataPath);
  }

  void _onReferenciaClick(Referencia item) async {
    dynamic result;
    if (item.isYouTube) {
      result = await Navigate.to(context, YouTubePage(item));
    }
    else if (item.descricao.isNotEmpty) {
      result = await Navigate.to(context, ReferenciaPage(item));
    }
    else if (item.url.isNotEmpty) {
      await Aplication.openUrl(item.url, context);
    }

    if (result != null) {
      if (result is bool && result) {
        referencias.remove(item);
      }
      if (result is Referencia) {
        if (item.data.compareTo(result.data) != 0) {
          referencias.remove(item);
          referencias.add(result);
        }
      }
    }
    if(!mounted) return;
    setState(() {});
  }

  void _onDeleteItem(Referencia item) async {
    _setInProgress(true);
    if (await Aplication.deleteReferencia(context, item))
      referencias.remove(item);
    _setInProgress(false);
  }

  _setInProgress(bool b) {
    if(!mounted) return;
    setState(() {
      inProgress = b;
    });
  }

  //endregion

}

class ReferenciaPage extends StatefulWidget {
  final Referencia refecencia;
  ReferenciaPage(this.refecencia);
  @override
  _State2 createState() => _State2(refecencia);
}
class _State2 extends State<ReferenciaPage> {

  //region variaveis

  final Referencia refecencia;

  bool _referenciaLida = false;
  bool _inProgress = false;
  bool _isMyRef = false;
  UserOki _user = FirebaseOki.userOki;

  //endregion

  _State2(this.refecencia);

  //region overrides

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, refecencia);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(Titles.REFERENCIA_PAGE, style: Styles.appBarText),
          actions: [
            if (_isMyRef)...[
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: _onEditClick,
              ),
              IconButton(
                  icon: Icon(Icons.delete_forever),
                  onPressed: _onDelete
              ),
            ]
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text(refecencia.titulo, style: Styles.titleText),
                subtitle: Text('Autor: ${refecencia.autor}'),
              ),
              text(refecencia.descricao),

              if (refecencia.url.isNotEmpty)
                ElevatedButton(
                  child: Text('Abrir Link'),
                  onPressed: () => Aplication.openUrl(refecencia.url),
                ),
            ],
          ),
        ),
        floatingActionButton: _inProgress ? CircularProgressIndicator() :
        _isMyRef ? null : FloatingActionButton.extended(
          label: Text(
              _referenciaLida ? MyTexts.DESMARCAR : MyTexts.MARCAR_COMO_VISTO),
          backgroundColor: _referenciaLida ? Colors.green : null,
          onPressed: _onMarcarComoVisto,
        ),
      ),
    );
  }

  //endregion

  //region metodos

  void _init() {
    _isMyRef = refecencia.userId == FirebaseOki.user?.uid ?? false;
    if (_user?.referencias?.containsKey(refecencia.id) ?? false) {
      _referenciaLida = _user.referencias[refecencia.id].toString().compareTo(refecencia.data) >= 0;
    }
  }

  Widget text(String text) {
    return Container(
      child: Text(text),
    );
  }

  void _onMarcarComoVisto() async {
    _setInProgress(true);
    if (await Aplication.addReferenciaComoLido(context, refecencia, _referenciaLida))
      _referenciaLida = !_referenciaLida;

    if (!mounted) return;
    setState(() {});
    _setInProgress(false);
  }

  void _onDelete() async {
    _setInProgress(true);
    if (await Aplication.deleteReferencia(context, refecencia))
      Navigator.pop(context, true);
    _setInProgress(false);
  }

  void _onEditClick() async {
    var result = await Navigate.to(context, ReferenciasAddPage(referencia: refecencia));
    if (result != null) {
      if (result is Referencia) {
        _setReferencia(result);
      }
    }
  }

  void _setReferencia(Referencia item) {
    refecencia.url = item.url;
    refecencia.data = item.data;
    refecencia.autor = item.autor;
    refecencia.titulo = item.titulo;
    refecencia.descricao = item.descricao;
    setState(() {});
  }

  void _setInProgress(bool b) {
    if (!mounted) return;
    setState(() {
      _inProgress = b;
    });
  }

  //endregion

}

class ReferenciasAddPage extends StatefulWidget {
  final Referencia referencia;
  ReferenciasAddPage({this.referencia});
  @override
  State<StatefulWidget> createState() => _StateAddPage(referencia);
}
class _StateAddPage extends State<ReferenciasAddPage> {

  //region variaveis

  final Referencia referencia;
  final Map<String, Livro> referencias = Map();

  static Referencia refTemp;

  //region bool IsEmpty
  bool tituloIsEmpty = false;
  bool autorIsEmpty = false;
  bool linkIsEmpty = false;
  bool descricaoIsEmpty = false;
  bool referenciasIsEmpty = false;
  //endregion

  //region Controllers
  final TextEditingController cTitulo = TextEditingController();
  final TextEditingController cAutor = TextEditingController();
  final TextEditingController cLink = TextEditingController();
  final TextEditingController cDescricao = TextEditingController();
  //endregion

  bool _inProgress = false;

  //endregion

  _StateAddPage(this.referencia);

  //region override

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        refTemp = criarObj();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(Titles.REFERENCIA_ADD_PAGE, style: Styles.appBarText),
          actions: [
            IconButton(
              tooltip: 'Limpar Campos',
              icon: Icon(Icons.refresh),
              onPressed: _onReload,
            )
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFieldOki(
                  hint: Strings.TITULO,
                  controller: cTitulo,
                  textIsEmpty: tituloIsEmpty,
                  keyboardType: TextInputType.name,
                  onTap: () =>
                      setState(() {
                        tituloIsEmpty = false;
                      })
              ),
              TextFieldOki(
                  hint: Strings.AUTOR,
                  controller: cAutor,
                  textIsEmpty: autorIsEmpty,
                  keyboardType: TextInputType.name,
                  icon: IconButton(
                      icon: Icon(Icons.help),
                      onPressed: _onAutorLinkClick
                  ),
                  onTap: () =>
                      setState(() {
                        autorIsEmpty = false;
                      })
              ),
              TextFieldOki(
                  hint: Strings.LINK,
                  controller: cLink,
                  textIsEmpty: descricaoIsEmpty && linkIsEmpty,
                  icon: IconButton(
                      icon: Icon(Icons.help),
                      onPressed: _onHelpLinkClick
                  ),
                  keyboardType: TextInputType.url,
                  onTap: () =>
                      setState(() {
                        linkIsEmpty = false;
                      })
              ),
              TextFieldOki(
                  hint: Strings.DESCRICAO,
                  controller: cDescricao,
                  textIsEmpty: descricaoIsEmpty && linkIsEmpty,
                  maxLines: 30,
                  keyboardType: TextInputType.multiline,
                  icon: IconButton(
                      icon: Icon(Icons.help),
                      onPressed: _onDescricaoLinkClick
                  ),
                  onTap: () =>
                      setState(() {
                        descricaoIsEmpty = false;
                      })
              ),

              if (referencia == null)
                SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      child: Text(MyTexts.ADD_LIVRO),
                      onPressed: _onAddLivro,
                    )
                )
              else ...[
                  Padding(padding: EdgeInsets.only(top: 10)),
                  Text('Não é possível alterar os livros referenciados.'),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                            'Se você precisa alterar os livros referenciados, '
                                'exclua essa referência clicando no icone ao lado e crie uma nova.'),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_forever),
                        onPressed: _onDeleteItem,
                      )
                    ],
                  ),
                ],

              if (referenciasIsEmpty)
                Text('Adicione referências', style: Styles.textEror),

              for (var item in referencias.values)...[
                ListTile(
                  title: Text(item.nome),
                  subtitle: Text(item.toString(incluirLinvo: false, breakLine: true)),
                  trailing: IconButton(
                    icon: Icon(Icons.delete_forever),
                    onPressed: () => _onReferenciaRemove(item),
                  ),
                  onTap: () => _onReferenciaClick(item),
                ),
              ],
            ],
          ),
        ),
        floatingActionButton: _inProgress ? CircularProgressIndicator() :
        FloatingActionButton(
          child: Icon(Icons.save),
          onPressed: _saveManager,
        ),
      ),
    );
  }

  //endregion

  //region metodos

  void _init() {
    if (referencia == null) {
      if (refTemp == null)
        cAutor.text = Config.autorName;
      else
        _setRef(refTemp);
    } else {
      _setRef(referencia);
    }
  }

  void _saveManager() async {
    Referencia item = criarObj();
    if (!verificar(item)) return;

    _setInProgress(true);
    if (await item.salvar()) {
      Config.autorName = item.autor;
      Navigator.pop(context, item);
      refTemp = null;
    }
    _setInProgress(false);

    if(!mounted) return;
    setState(() {});
  }

  void _setRef(Referencia item) {
    cTitulo.text = item.titulo;
    cAutor.text = item.autor;
    cLink.text = item.url;
    cDescricao.text = item.descricao;

    referencias.addAll(item.livros);
  }

  bool verificar(Referencia item) {
    try {
      tituloIsEmpty = item.titulo.isEmpty;
      autorIsEmpty = item.autor.isEmpty;
      linkIsEmpty = item.url.isEmpty;
      descricaoIsEmpty = item.descricao.isEmpty;
      if (referencia == null)
        referenciasIsEmpty = item.livros.isEmpty;

      setState(() {});

      if (tituloIsEmpty) throw ('');
      if (autorIsEmpty) throw ('');
      if (linkIsEmpty && descricaoIsEmpty) throw ('');
      if (referenciasIsEmpty) throw ('');

      return true;
    } catch(e) {
      return false;
    }
  }

  Referencia criarObj() => Referencia(
    id: randomId(),
    url: cLink.text,
    autor: cAutor.text.trimLeft().trimRight(),
    titulo: cTitulo.text.trimLeft().trimRight(),
    descricao: cDescricao.text.trimLeft().trimRight(),
    livros: referencias,
    userId: FirebaseOki.user.uid,
    data: DataHora.now(),
  );

  String randomId() {
    String id;
    if (referencia == null)
      id = DataHora.now();
    else
      return referencia.id;
    return Cript.encript(id)
        .replaceAll('[', 'a')
        .replaceAll('#', 'q')
        .replaceAll(']', 'w');
  }

  void _onHelpLinkClick() {
    var title = 'Link';
    var content = [
      Text('O que devo colocar.'),
      Text('* Link da página com a explicação dos versículos referenciados.'),
      Text('* Link do vídeo com a explicação dos versículos referenciados.'),
      Divider(),
      Text('O que NÃO devo colocar.'),
      Text('* Páginas com vários links que induzem o usuário a procurar pela explicação.', style: Styles.textEror),
      Text('* Link de \'canais\' do YouTube que induzem o usuário a procurar pelo vídeo com a explicação.', style: Styles.textEror),
    ];
    DialogBox.dialogOK(context, title: title, content: content);
  }

  void _onDescricaoLinkClick() {
    var title = 'Descrição';
    var content = [
      Text('Aqui você pode colocar uma breve explicação do conteúdo do link.'),
      Text('Se não tiver um link, você pode colocar aqui toda a explicação dos versículos referenciados.'),
    ];
    DialogBox.dialogOK(context, title: title, content: content);
  }

  void _onAutorLinkClick() {
    var title = 'Autor';
    var content = [
      Text('Seu nome que será exibido aos usuários.'),
    ];
    DialogBox.dialogOK(context, title: title, content: content);
  }

  void _onAddLivro() async {
    var result = await Navigate.to(context, SelecionarLivroPage());
    if (result == null || !(result is Livro)) return;

    Livro temp = referencias[result.abreviacao];
    var result2 = await Navigate.to(context, SelecionarCapituloPage(result, livroB: temp));
    if (result2 == null || !(result2 is Map<int, Capitulo>)) return;

    if (result2.isEmpty) {
      _onReferenciaRemove(result);
      return;
    }
    var livro = Livro(
      nome: result.nome,
      abreviacao: result.abreviacao,
      capitulos: Map(),
    );

    for (var key in result2.keys)
      livro.capitulos[key] = result2[key];
    if(!mounted) return;
    setState(() {
      referenciasIsEmpty = false;
      referencias[livro.abreviacao] = livro;
    });
  }

  void _onReferenciaClick(Livro item) async {
    Livro livroTemp = Biblia.instance.livros[item.abreviacao];
    var result2 = await Navigate.to(context, SelecionarCapituloPage(livroTemp, livroB: item));
    if (result2 == null || !(result2 is Map<int, Capitulo>)) return;

    if (result2.isEmpty) {
      _onReferenciaRemove(item);
      return;
    }
    var livro = Livro(
      nome: item.nome,
      abreviacao: item.abreviacao,
      capitulos: Map(),
    );

    for (var key in result2.keys)
      livro.capitulos[key] = result2[key];
    if(!mounted) return;
    setState(() {
      referencias.remove(item);
      referencias[livro.abreviacao] = livro;
    });
  }

  void _onReferenciaRemove(Livro item) {
    setState(() {
      referencias.remove(item.abreviacao);
    });
  }

  void _onDeleteItem() async {
    _setInProgress(true);
    if (await Aplication.deleteReferencia(context, referencia)) {
      refTemp = referencia;
      Navigator.pop(context);
      Navigate.to(context, ReferenciasAddPage());
    }
    _setInProgress(false);
  }

  void _onReload() {
    tituloIsEmpty =
        autorIsEmpty =
        linkIsEmpty =
        descricaoIsEmpty =
        referenciasIsEmpty = false;

    cDescricao.text =
        cAutor.text =
        cLink.text =
        cTitulo.text = '';

    referencias.clear();
    setState(() {});
  }

  void _setInProgress(bool b) {
    if (!mounted) return;
    setState(() {
      _inProgress = b;
    });
  }

  //endregion

}
